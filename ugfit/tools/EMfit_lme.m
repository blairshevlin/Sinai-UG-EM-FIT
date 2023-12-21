function [modout]= EMfit_lme(rootfile,modelID,quickfit)
% 2017; does Expectation-maximation fitting. Originally written by Elsa Fouragnan, modified by MKW.
% Adapted by BRK Shevlin and S Rhoads Dec 2023
% INPUT:       - rootfile: file with all behavioural information necessary for fitting + outputroot
%              - modelID: ID of model to fit
%              - quickfit: wether to lower the convergence criterion for model fitting (makes fitting quicker)
% OUTPUT:      - fitted model
%
%%

%======================================================================================================
% 1) do settings and prepare model
%======================================================================================================

fprintf([rootfile.expname ': Fitting ' modelID ' using EM.']);

% assign input variables
modout      = rootfile.em;
n_subj      = length(rootfile.ID);
fit.ntrials = nan(length(rootfile.beh{1}.offer),1);
for is = 1:n_subj
   fit.ntrials(is) = sum(~isnan(rootfile.beh{is}.offer)); 
end


% define model and fitting params:
if quickfit==1, fit.convCrit= 0.1; else fit.convCrit= 1e-3; end
fit.maxit   = 1000; 
fit.maxEvals= 500;
fit.npar    = get_npar(modelID);   
fit.objfunc = str2func(['mod_' modelID]);                                     % the function used from here downwards
fit.doprior = 1;
fit.dofit   = 0;                                                              % getting the fitted schedule
% Note: reduced TolX to .001 (Original is .001)
fit.options = optimoptions(@fminunc,'Display','off','TolX',.0001,'Algorithm','quasi-newton'); 
if isfield(fit,'maxEvals'),  fit.options = optimoptions(@fminunc,'Display','off','TolX',.0001,'MaxFunEvals', fit.maxEvals,'Algorithm','quasi-newton'); end

% initialise group-level parameter mean and variance
posterior.mu        = abs(.1.*randn(fit.npar,1));                             % start with positive values; define posterior because it is assigned to prior @ beginning of loop
posterior.sigma     = repmat(100,fit.npar,1);

% initialise transient variables:
nextbreak   = 0;
NPL         = [];                                                             % posterior likelihood                                                  
NPL_old     = -Inf;
NLL         = [] ;                                                            % NLL estimate per iteration
NLPrior     = [];                                                             % negative LogPrior estimate per iteration
lme         = [];
%======================================================================================================
% 2) EM FITTING
%======================================================================================================
for iiter = 1:fit.maxit                         
   
   m=[];                                                                      % individual-level parameter mean estimate
   h=[];                                                                      % individual-level parameter variance estimate
   
   % build prior gaussian pdfs to calculate P(h|O):
   prior.mu       = posterior.mu;
   prior.sigma    = posterior.sigma;
   prior.logpdf  = @(x) sum(log(normpdf(x,prior.mu,sqrt(prior.sigma))));      % calculates separate normpdfs per parameter and sums their logs

   
   %======================= EXPECTATION STEP ==============================
   for is = 1:n_subj                                                          
      % fit model, calculate P(Choices | h) * P(h | O) 
      ex=-1; tmp=0;                                                           % ex : exitflag from fminunc, tmp is nr of times fminunc failed to run
      while ex<0                                                              % just to make sure the fitting is done
         q        =.1*randn(fit.npar,1);                                      % free parameters set to random
         beh_is = struct();
         beh_is.offer = rootfile.beh{is}.offer;
         beh_is.choice = rootfile.beh{is}.choice;
         inputfun = @(q)fit.objfunc(beh_is,q,fit.doprior ,fit.dofit,prior);  
         [q,fval,ex,~,~,hessian] = fminunc(inputfun,q,fit.options); 
         if ex<0 ; tmp=tmp+1; fprintf('didn''t converge %i times exit status %i\r',tmp,ex); end         
      end
   
      
      % fitted parameters and their hessians
      m(:,is)              = q;
      h(:,:,is)            = hessian;                                         % inverse of hessian estimates individual-level covariance matrix
      
      % get MAP model fit:
      NPL(is,iiter)     = fval;                                               % non-penalised a posteriori; 	
      NLPrior(is,iiter) = -prior.logpdf(q);    
   end
   

   %======================= MAXIMISATION STEP ==============================
   
   [curmu,cursigma,flagcov,~] = compGauss_ms(m,h);                            % compute gaussians and sigmas per parameter
   if flagcov==1, posterior.mu = curmu; posterior.sigma = cursigma; end       % update only if hessians okay
   if sum(NPL(:,iiter)) == 10000000*length(rootfile.beh)
       flagcov=0; % don't proceed if bad fit for all subjects
       disp('-[badfit]-');
   end
    
   
   if iiter > 2
     L = [];
     for is = 1:n_subj
        try
            hHere = logdet(h(:,:,is) ,'chol');
            L(is)= -NPL(is,iiter-1) - 1/2*log(det(h(:,:,is))) + (fit.npar/2)*log(2*pi); % La Place approximation computed log model evidence - log posterior prob  
            goodHessian(is) = 1;
        catch
           % warning('Hessian is not positive definite');
            try
                hHere = logdet(h(:,:,is));
                L(is) = nan;
                goodHessian(is) = 0;
            catch
                warning('could not calculate');
                goodHessian(is) = -1;
                L(is) = nan;
            end
        end
    end
    L(isnan(L)) = nanmean(L)';
    lme(iiter) = sum(L) - fit.npar*log(n_subj);
   
   % check whether fit has converged
    fprintf([', ',num2str(lme(iiter)),' (',num2str(iiter),')']);
    if abs(lme(iiter)-lme(iiter-1)) < fit.convCrit && flagcov==1            % if  MAP estimate does not improve and covariances were properly computed
        fprintf(' -- converged!!!!! \n');  
        nextbreak=1;                          % stops at end of this loop iteration                                                        
    end
   end

   % execute break if desired
   if nextbreak ==1 
      break 
   end
end
[~,~,~,covmat_out] = compGauss_ms(m,h,2);% get covariance matrix to save it below; use method 2 to do that

% say if fit was because of that
if iiter == fit.maxit 
    fprintf('...maximum number of iterations reached');
end

%======================================================================================================
%%% 3) Get values for best fitting model
%====================================================================================================== 


% fill in general information
modout.(modelID) = {}; % clear field;
modout.(modelID).date            = date;
modout.(modelID).behaviour       = rootfile.beh;                                          % copy behaviour here, just in case
modout.(modelID).q               = m';
modout.(modelID).qnames          = {};                                                    % fill in below
modout.(modelID).hess            = h;
modout.(modelID).gauss.mu        = posterior.mu;
modout.(modelID).gauss.sigma     = posterior.sigma;
modout.(modelID).gauss.cov       = covmat_out;
%modout.(modelID).gauss.corr      = corrcov(covmat_out);
try
    modout.(modelID).gauss.corr      = corrcov(covmat_out);
catch
    disp('covariance mat not square, symmetric, or positive semi-definite');
    modout.(modelID).gauss.corr      = eye(length(q));
end
modout.(modelID).fit.npl         = NPL(:,iiter);                                          % note: this is the negative joint posterior likelihood
modout.(modelID).fit.NLPrior     = NLPrior(:,iiter);
modout.(modelID).fit.nll         = NPL(:,iiter) - NLPrior(:,iiter); 
[modout.(modelID).fit.aic,modout.(modelID).fit.bic] = aicbic(-modout.(modelID).fit.nll,fit.npar,fit.ntrials); 
modout.(modelID).fit.lme         = lme;
modout.(modelID).fit.goodHessian = goodHessian; 
modout.(modelID).fit.convCrit    = fit.convCrit;
modout.(modelID).ntrials         = fit.ntrials;

% Taken from Shawn Rhoads
% make sure you know if BIC is positive or negative! and replace lme with
% bic if covariance in negative.
% error check that BICs are in similar range

% get subject specifics
fit.dofit   = 1;
fit.doprior = 0;

for is = 1:n_subj
   % For UG structure
   beh_is = struct();
   beh_is.offer = rootfile.beh{is}.offer(trials);
   beh_is.choice = rootfile.beh{is}.choice(trials);
   [nll_check,subfit]            = fit.objfunc(beh_is,m(:,is),fit.doprior,fit.dofit); 
   % group values
   modout.(modelID).qnames       = subfit.xnames;
   modout.(modelID).fit.lme(is,1)= -NPL(is,iiter) - 1/2*log(det(h(:,:,is))) + (fit.npar/2)*log(2*pi); % La Place approximation computed log model evidence - log posterior prob
   % subj values
   modout.(modelID).sub{is}.mat  = subfit.mat;
   modout.(modelID).sub{is}.names= subfit.names; 
   
   % errorchecks:
   %if real(modout.(modelID).fit.lme(is)) ~= modout.(modelID).fit.lme(is); disp('LME not a real number.'); error('LME is not a real number (subject %d)', is); end
   if abs(modout.(modelID).fit.nll(is)-nll_check) >.0000000001, disp('ERROR'); keyboard; end % check nll calculation
end

%======================================================================================================
%%% 4)  plot correlation between parameters:
%====================================================================================================== 
% ADAPTED from Shawn Rhoads
% Added by BRK Shevlin April 2023


figure;
imagesc(modout.(modelID).gauss.corr)
colorbar
colormap jet
caxis([-1 1])
title('Parameter Correlation Matrix');
set(gca,'Xtick',1:fit.npar,'XTickLabel',modout.(modelID).qnames, 'TickLabelInterpreter', 'none')
set(gca,'Ytick',1:fit.npar,'YTickLabel',modout.(modelID).qnames, 'TickLabelInterpreter', 'none')
%set_default_fig_properties(gca,gcf)

figpath=['figs/'];
% save:
if ~isdir(figpath), mkdir(figpath); end;
figname=[figpath modelID '_correl.jpg' ];
saveas(gcf,figname); close all;







end
   