% Fits UG2 models and does model comparison
% Created by MK Wittmann, October 2018
% Adapted by BRK Shevlin, April 2023
%
%%
%== -I) Prepare workspace: ============================================================================================

clearvars
addpath('models'); 
addpath('tools');

setFigDefaults; 
%%

%%== 0) Load and organise data: ==========================================================================================
% load data:
%indir = 'C:/Users/blair/Documents/Research/Sinai-UG-EM-FIT/example_data/';
load('DATA_COVID_Round1_noFlat_passAttn_Oct20_s100.mat');
% define data set(s) of interest:
expids = {'r1NC',''};
% how to fit RL:
M.dofit     = 1;                                                                                                     % whether to fit or not                                                           
M.doMC      = 1;                                                                                                     % whether to do model comparison or not  
M.quickfit  = 0;   % Shawn tells me that quickfit is too liberal to be trusted, but is fine for testing                                                                                                  % whether to lower the convergence criterion for model fitting (makes fitting quicker) (1=quick fit)
M.omitBMS   = 0;                                                                                                     % omit bayesian model comparison if you don't have SPM instaslled
M.modid     = { %'ms_UG0_f0f_adaptiveNorm', ...
     %'ms_UG1_etaf_f0f_adaptiveNorm',...
      'ms_UG2_etaf_f0f_adaptiveNorm'}; %, ...
      %'ms_UG3_etaf_f0f_adaptiveNorm'}; 
              
                % list of main models to fit

%%
%== I) RUN MODELS: ======================================================================================================
trials = (1:30);
for iexp = 1:numel(expids)
   if M.dofit == 0,  break; end
   cur_exp = expids{iexp};                                                   
   
   %%% EM fit %%%
   for im = 1:numel(M.modid)
      dotry=1;
      while 1==dotry
         try
            close all;
            % If things are not working, run this line manually to set an
            % idea where the error in the code is
            s.(cur_exp).em = EMfit_mean_ms(s.(cur_exp),M.modid{im},M.quickfit,trials);
            %s.(cur_exp).em = EMfit_fmri_ms(s.(cur_exp),M.modid{im},M.quickfit,trials);

            dotry=0;
         catch
            dotry=1; disp('caught');
         end
      end
   end

   %%% calc BICint for EM fit
  for im = 1:numel(M.modid)
      s.(cur_exp).em.(M.modid{im}).fit.bicint =  cal_BICint_ms(s.(cur_exp).em, M.modid{im},trials);     
  end   

end


save('FIT_MeanEM_COVID_R1_NC_t30.mat','s')

%%
load("FIT_MeanEM_COVID_R1_IC_t30_s100.mat")

fit = s.r1IC.em.ms_UG2_etaf_f0f_adaptiveNorm.q;

n_subj = length(s.r1IC.ID);

for i = 1:n_subj
    alpha(i) = norm2alpha(fit(i,1));
    beta(i) = norm2beta(fit(i,2));
    eps(i) = norm2alpha(fit(i,3));
    delta(i) = norm2delta(fit(i,4));
end

histogram(alpha)

histogram(beta)

histogram(eps)

histogram(delta)



