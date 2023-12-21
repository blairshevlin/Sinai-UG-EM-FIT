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
load('Hackathon-Data_Separate-IC-NC_s150_noFlat_noNorm.mat');
% define data set(s) of interest:
expids = {'simUG2_IC'};
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
            s.(cur_exp).em = EMfit_ms(s.(cur_exp),M.modid{im},M.quickfit,[1:30]);
            dotry=0;
         catch
            dotry=1; disp('caught');
         end
      end
   end

   %%% calc BICint for EM fit
 % for im = 1:numel(M.modid)
  %    s.(cur_exp).em.(M.modid{im}).fit.bicint =  cal_BICint_ms(s.(cur_exp).em, M.modid{im},trials);     
  %end   

end
%% 


save('FIT_Hackathon-Data_Separate-IC-NC_s150.mat','s')


%%

%load("FIT_MeanEM_Simulated-R1_f0_1285-Subj_30Trials_Dec1.mat")

gen = s.simUG2_IC.params;

rec = s.simUG2_IC.em.ms_UG2_etaf_f0f_adaptiveNorm.q;

nP = length(s.simUG2_IC.ID);


for i = 1:nP
    alpha(i) = norm2alpha(rec(i,1));
    beta(i) = norm2beta(rec(i,2));
    eps(i) = norm2alpha(rec(i,3));
    delta_IC(i) = norm2delta(rec(i,4));
end

%%
corrplot([gen(:,1) alpha'])
corrplot([gen(:,2) beta'])
corrplot([gen(:,4) eps'])
corrplot([gen(:,5) delta_IC'])














