% Fits UG2 models and does model comparison
% Created by MK Wittmann, October 2018
% Adapted by BRK Shevlin & S Rhoads, November 2023
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
%load('DATA_COVID_Round1_noFlat-BOTH_passAttn_allData_Nov30.mat');

% define data set(s) of interest:
expids = {'r1NC','r1IC'};
% how to fit RL:
M.dofit     = 1;                                                                                                     % whether to fit or not                                                           
M.doMC      = 1;                                                                                                     % whether to do model comparison or not  
M.quickfit  = 0;   % Shawn tells me that quickfit is too liberal to be trusted, but is fine for testing                                                                                                  % whether to lower the convergence criterion for model fitting (makes fitting quicker) (1=quick fit)
M.omitBMS   = 0;                                                                                                     % omit bayesian model comparison if you don't have SPM instaslled
M.modid     = { %'ms_UG0_f0f_adaptiveNorm', ...
     'ms_UG2_etaf_f0f_adaptiveNorm'};
    %  'ms_UG2_etaf_f0f_noNorm'}; %, ...
      %'ms_UG3_etaf_f0f_adaptiveNorm'}; 
              
                % list of main models to fit

%% Only running 100 subjects
nIDs = 100;

IDs_ic = {};
IDs_nc = {};
r1IC = {};
r1NC = {};
for i = 1:nIDs
    IDs_ic{i} = s.r1IC.ID{i};
    IDs_nc{i} = s.r1NC.ID{i};

    r1IC{i} = s.r1IC.beh{i};
    r1NC{i} = s.r1NC.beh{i};
end

s.r1IC.beh = r1IC;
s.r1NC.neh = r1NC;

s.r1IC.ID = IDs_ic;
s.r1NC.ID = IDs_nc;


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
            s.(cur_exp).em = EMfit_ms(s.(cur_exp),M.modid{im},M.quickfit,trials);
      %      s.(cur_exp).em = EMfit_mean_ms(s.(cur_exp),M.modid{im},M.quickfit,trials);
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


save('FIT_EM_COVID_R1_s100_t30_Dec1_nNorm.mat','s')

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



