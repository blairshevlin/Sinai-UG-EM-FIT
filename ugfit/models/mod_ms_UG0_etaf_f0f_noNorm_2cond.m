function [fval,fit] = mod_ms_UG0_etaf_f0f_noNorm_2cond(behavData,q, doprior,dofit,varargin)
% runs standard 0 Step UG Model
% Created MK Wittmann, Oct 2018
% Adapted BRK Shevlin, April 2023
%
% INPUT:    - behavData: behavioural input file
% OUTPUT:   - fval and fitted variables
% 
% 
%
%%
% -------------------------------------------------------------------------------------
% 1 ) Define free parameters
% -------------------------------------------------------------------------------------

if nargin > 4
    prior      = varargin{1};
end

[qt, bounds] = norm2par('ms_UG0_etaf_f0f_noNorm_2cond',q); % transform parameters from gaussian space to model space

% Define free parameters and set unused ones to zero
alpha = qt(1); % envy
if (alpha<min(bounds(:,1)) || alpha>max(bounds(:,1))), fval=10000000; return; end
beta = qt(2); % inverse temperature
if (beta<min(bounds(:,2)) || beta>max(bounds(:,2))), fval=10000000; return; end


fixed = [0.8, 10];
free = {alpha beta};
% -------------------------------------------------------------------------------------
% 2-4) Middle code is specific the the model
% -------------------------------------------------------------------------------------
%changept = findchangepts(behavData.choice, "Statistic","linear");
%if doprior == 1
%    [fval,~,~,ChoiceProb] = lik_UG2_etaf_f0f_adaptiveNorm_v2(behavData.offer, behavData.choice,fixed,free,changept,doprior,prior,q);
%else
%    [fval,~,~,ChoiceProb] = lik_UG2_etaf_f0f_adaptiveNorm_v2(behavData.offer, behavData.choice,fixed,free,changept,doprior);
%end
if doprior == 1
    [fval,~,~,ChoiceProb] = lik_UG0_etaf_f0f_noNorm_2cond(behavData.offer, behavData.choice,fixed,free,doprior,prior,q);
else
    [fval,~,~,ChoiceProb] = lik_UG0_etaf_f0f_noNorm_2cond(behavData.offer, behavData.choice,fixed,free,doprior);

end
% -------------------------------------------------------------------------------------
% 5) Calculate additional Parameters and save: 
% -------------------------------------------------------------------------------------

if dofit ==1
   fit         = struct;
   fit.q = qt;
   fit.xnames  = {'alpha'; 'beta'};
   
   fit.mat    = ChoiceProb;
   fit.names  = {'ChoiceProb'};
end




end

