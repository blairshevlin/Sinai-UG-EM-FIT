function [modout]= MAPfit_fmri_ms(rootfile,modelID,quickfit,subjID)
% 2017; does MAP fitting. Based on EM code written by Elsa Fouragnan, modified by MKW.
% Adapted by BRK Shevlin Sept 2023
% INPUT:       - rootfile: file with all behavioural information necessary for fitting + outputroot
%              - modelID: ID of model to fit
%              - quickfit: wether to lower the convergence criterion for model fitting (makes fitting quicker)
%              - subjID: ID of which subject to fit
% OUTPUT:      - fitted model
%
%%

%======================================================================================================
% 1) do settings and prepare model
%======================================================================================================


fprintf([rootfile.expname ': Fitting ' modelID ' using MAP.']);

% assign input variables
modout      = rootfile.map.("subj"+subjID);
fit.ntrials = sum(~isnan(rootfile.beh{subjID}.offer),'All' ); 

% Extract behavior
beh_is = struct();
beh_is.offer = rootfile.beh{subjID}.offer;
beh_is.choice = rootfile.beh{subjID}.choice;

% define model and fitting params:
if quickfit==1, fit.convCrit= 0.1; else; fit.convCrit= 1e-3; end
fit.maxit   = 800; 
fit.maxEvals= 400;
fit.npar    = get_npar(modelID);   
fit.objfunc = str2func(['mod_' modelID]);                                     % the function used from here downwards
fit.doprior = 1;
fit.dofit   = 0;                                                              % getting the fitted schedule
fit.options = optimoptions(@fminunc,'Display','off','TolX',.0001,'Algorithm','quasi-newton'); 
if isfield(fit,'maxEvals'),  fit.options = optimoptions(@fminunc,'Display','off','TolX',.0001,'MaxFunEvals', fit.maxEvals,'Algorithm','quasi-newton'); end


%======================================================================================================
% 2) MAP FITTING
%======================================================================================================
figure;

% initialise transient variables:
nextbreak   = 0;
NPL         = [];            % posterior likelihood                                                  
NPL_old     = -Inf;
NLL         = [];            % NLL estimate per iteration
NLPrior     = [];            % negative LogPrior estimate per iteration

% initialise subject-level parameter mean and variance
posterior.mu        = abs(.1.*randn(fit.npar,1));    % start with positive values; define posterior because it is assigned to prior @ beginning of loop
posterior.sigma     = repmat(100,fit.npar,1);

for iiter = 1:fit.maxit                         

   % build prior gaussian pdfs to calculate P(h|O):
   prior.mu       = posterior.mu;
   prior.sigma    = posterior.sigma;
   prior.logpdf  = @(x) sum(log(normpdf(x,prior.mu,sqrt(prior.sigma))));      % calculates separate normpdfs per parameter and sums their logs
       
  % fit model, calculate P(Choices | h) * P(h | O) 
  ex=-1; tmp=0;                                                           % ex : exitflag from fminunc, tmp is nr of times fminunc failed to run
  while ex<0  % for catching convergence                                                            % just to make sure the fitting is done
     q        =.01*randn(fit.npar,1);                                      % free parameters set to random

     inputfun = @(q)fit.objfunc(beh_is,q,fit.doprior ,fit.dofit,prior);
     
     good_init = false;

     while (~good_init) % Initial point will only not work if prior is overely-precise, in which case re-initialize the prior to these values one step previously
         try
            [q,fval,ex,~,~,hessian] = fminunc(inputfun,q,fit.options); 
            good_init = true;
         catch err
            prior.mu       = old_posterior_mu;
            prior.sigma    = old_posterior_sigma;
            prior.logpdf  = @(x) sum(log(normpdf(x,prior.mu,sqrt(prior.sigma))));      % calculates separate normpdfs per parameter and sums their logs
            inputfun = @(q)fit.objfunc(beh_is,q,fit.doprior ,fit.dofit,prior);
         end
     end
     if ex<0 ; tmp=tmp+1; fprintf('didn''t converge %i times exit status %i\r',tmp,ex); end   
 end

  
  % fitted parameters and their hessians
  m = q;
  h = hessian; % inverse of hessian estimates individual-level covariance matrix
  
  % get MAP model fit:
  NPL(iiter)     = fval; % non-penalised a posteriori; 	
  NLPrior(iiter) = -prior.logpdf(q);    

   %======================= MAXIMISATION STEP ==============================
   
   [curmu,cursigma,flagcov,~] = compGauss_map(m,h);                           % compute gaussians and sigmas per parameter
   if flagcov==1 && all(cursigma>0)
       old_posterior_mu = posterior.mu; old_posterior_sigma = posterior.sigma;
       posterior.mu = curmu; posterior.sigma = cursigma; 
   end       % update only if hessians okay
   if sum(NPL(iiter)) == 10000000*length(beh_is.offer)
       flagcov=0; % don't proceed if bad fit
       disp('-[badfit]-');
   end
   
   % check whether fit has converged
   %fprintf('.');
   if abs(NPL(iiter)-NPL_old) < fit.convCrit  && flagcov==1            % if  MAP estimate does not improve and covariances were properly computed
      fprintf('...converged!!!!! \n');  nextbreak=1;                          % stops at end of this loop iteration                                                        
   end
   NPL_old = NPL(iiter);
   
       
   % ============== Plot progress (for visualisation only ===================
   
   NLL(iiter) = (NPL(iiter) - NLPrior(iiter));    % compute NLL manually, just for visualisation
   subplot(2,1,1);
   plot(NPL(1:iiter),'b'); hold all;
   plot(NLL(1:iiter),'r'); 
   if iiter==1, leg = legend({'NPL','NLL'},'Autoupdate','off'); end          
   title([rootfile.expname ' - ' strrep(modelID,'_',' ')]);    xlabel('EM iteration');
   setfp(gcf)
   drawnow; 
   
   % execute break if desired
   if nextbreak ==1 
      break 
   end
end

[~,~,~,covmat_out] = compGauss_map(m,h,2);% get covariance matrix to save it below; use method 2 to do that

% say if fit was because of that
if iiter == fit.maxit 
    fprintf('...maximum number of iterations reached');
end

%======================================================================================================
%%% 3) Get values fomodout.(modelID) r best fitting model
%====================================================================================================== 

% fill in general information

modout.(modelID) = {}; % clear field;
modout.(modelID).date            = date;
modout.(modelID).behaviour       = beh_is;                                          % copy behaviour here, just in case
modout.(modelID).q               = m';
modout.(modelID).qnames          = {};                                                    % fill in below
modout.(modelID).hess            = h;
modout.(modelID).gauss.mu        = posterior.mu;
modout.(modelID).gauss.sigma     = posterior.sigma;
modout.(modelID).gauss.cov       = covmat_out;
try
    modout.(modelID).gauss.corr      = corrcov(covmat_out);
catch
    disp('covariance mat not square, symmetric, or positive semi-definite');
    modout.(modelID).gauss.corr      = eye(length(q));
end
modout.(modelID).fit.npl         = NPL(iiter);                                          % note: this is the negative joint posterior likelihood
modout.(modelID).fit.NLPrior     = NLPrior(iiter);
modout.(modelID).fit.nll         = NPL(iiter) - NLPrior(iiter); 
[modout.(modelID).fit.aic,modout.(modelID).fit.bic] = aicbic(-modout.(modelID).fit.nll,fit.npar,fit.ntrials); 
modout.(modelID).fit.lme         = [];
modout.(modelID).fit.convCrit    = fit.convCrit;
modout.(modelID).ntrials         = fit.ntrials;

% Taken from Shawn Rhoads
% make sure you know if BIC is positive or negative! and replace lme with
% bic if covariance in negative.
% error check that BICs are in similar range

% get subject specifics
fit.dofit   = 1;
fit.doprior = 0;

% ==================== %
% Jan 2020: Pat & Miriam from mfit_optimize_hierarchical.m from Sam Gershman

       
try
   hHere = logdet(h ,'chol');
   L = -NPL(iiter) - 1/2*log(det(h)) + (fit.npar/2)*log(2*pi); % La Place approximation computed log model evidence - log posterior prob  
   goodHessian = 1;
catch
   warning('Hessian is not positive definite');
   try
       hHere = logdet(h);
       L = nan;
       goodHessian = 0;
   catch
       warning('could not calculate');
       goodHessian = -1;
       L = nan;
   end
end

L(isnan(L)) = nanmean(L)';
modout.(modelID).fit.lme = L;
modout.(modelID).fit.goodHessian = goodHessian; 

% For UG structure
% beh_is = struct();
% beh_is.offer = rootfile.beh.offer{subjID};
% beh_is.choice = rootfile.beh.choice{subjID};
%[nll_check,subfit]            = fit.objfunc(beh_is,m,fit.doprior,fit.dofit); 
%modout.(modelID).mat  = subfit.mat;
%modout.(modelID).names= subfit.names; 

% errorchecks:
%if real(modout.(modelID).fit.lme(is)) ~= modout.(modelID).fit.lme(is); disp('LME not a real number.'); error('LME is not a real number (subject %d)', is); end
% if abs(modout.(modelID).fit.nll(is)-nll_check) >.0000000001, disp('ERROR'); keyboard; end % check nll calculation


end

%======================================================================================================
%%% 4)  plot correlation between parameters:
%====================================================================================================== 
% ADAPTED from Shawn Rhoads
% Added by BRK Shevlin April 2023


%figure;
%imagesc(modout.(modelID).gauss.corr)
%colorbar
%colormap jet
%caxis([-1 1])
%title('Parameter Correlation Matrix');
%set(gca,'Xtick',1:fit.npar,'XTickLabel',modout.(modelID).qnames, 'TickLabelInterpreter', 'none')
%set(gca,'Ytick',1:fit.npar,'YTickLabel',modout.(modelID).qnames, 'TickLabelInterpreter', 'none')
%set_default_fig_properties(gca,gcf)

%figpath=['figs/'];
% save:
%if ~isdir(figpath), mkdir(figpath); end;
%figname=[figpath modelID '_correl.jpg' ];
%saveas(gcf,figname); close all;

   