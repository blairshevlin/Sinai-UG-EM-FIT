clearvars


addpath('models'); 
addpath('tools');



%load('DATA_Simulated_fixedf0_50Subj_30Trials.mat')
load('DATA_NaEtAl_fmri.mat')

%%
% define data set(s) of interest:
expids = {'fmriIC'}; %'simUG0','simUG1','simUG2','simUG3', ...
    %'simUG0f0','simUG1f0','simUG2f0','simUG3f0'};

% how to fit RL:
M.dofit     = 1;                                                                                                     % whether to fit or not                                                           
M.doMC      = 1;                                                                                                     % whether to do model comparison or not  
M.quickfit  = 0;                                                                                                     % whether to lower the convergence criterion for model fitting (makes fitting quicker) (1=quick fit)
M.omtBMS   = 1;                                                                                                     % omit bayesian model comparison if you don't have SPM instaslled
M.modid     = {'ms_UG2_etaf_f0f_adaptiveNorm'};%{

cur_exp = expids{1};


n_subj = length(s.(cur_exp).ID);

for i = 1:n_subj
    s.(cur_exp).map.("subj"+i) = struct();
end
%%
%nP = 4;
%parpool("local",nP);


for i = 1:n_subj
    disp("Subject "+i)
    cur_subj = "subj"+i;
    dotry=1;
    while 1==dotry
        try
            close all;
            s.(cur_exp).map.(cur_subj) = MAPfit_fmri_ms( s.(cur_exp), M.modid{1},M.quickfit, i );
            dotry=0;
        catch
            dotry=1; disp('caught');
        end
    end
    save('MAP_FIT_fMRI_IC_fixedf0_48Subj_40Trials.mat','s')
end

%delete(gcp('nocreate'))
%%
load('MAP_FIT_fMRI_IC_fixedf0_48Subj_40Trials.mat')

n_subj = length(s.(cur_exp).ID);

fit_params = zeros(n_subj,4);

for i = 1:n_subj
    cur_subj = "subj"+i;
    tmp_params = s.(cur_exp).map.(cur_subj).(M.modid{1}).gauss.mu;

    fit_params(i,1) = norm2alpha(tmp_params(1));
    fit_params(i,2) = norm2beta(tmp_params(2));
    fit_params(i,3) = norm2alpha(tmp_params(3));
    fit_params(i,4) = norm2delta(tmp_params(4));
end

%%
ksdensity(fit_params(:,1) )

ksdensity(fit_params(:,2) )

ksdensity(fit_params(:,3) )

ksdensity(fit_params(:,4) )


%%
% Simulate
global offer0
global eta
global n

offer0 = 5;
n = 30;             % number of trials
eta = 0.8;          % fixed parameter
offer_cell = {};
choice_cell = {};

for i = 1:n_subj

    [offer, choice] = simulate_2step_ic([fit_params(i,1) fit_params(i,2) 10 fit_params(i,3) fit_params(i,4)]);
    
    offer_cell{i} = offer;
    choice_cell{i} = choice;
end

% Behavior cells
sim_beh = struct();
sim_beh.offer = offer_cell;
sim_beh.choice = choice_cell; 


simfMRI = struct();
simfMRI.beh = sim_beh;
simfMRI.expname = 'sim_fMRI';
simfMRI.ID = s.(cur_exp).ID;
simfMRI.params = fit_params;
simfMRI.map = struct();

%%
% Fit simulated data
for i = 1:n_subj
    disp("Subject "+i)
    cur_subj = "subj"+i;
    simfMRI.map.(cur_subj) = struct();
    dotry=1;
    while 1==dotry
        try
            close all;
            simfMRI.map.(cur_subj) = MAPfit_ms( simfMRI, M.modid{1},M.quickfit, i);
            dotry=0;
        catch
            dotry=1; disp('caught');
        end
    end
    save('MAP_RECOVER_fMRI_IC_fixedf0_48Subj_40Trials.mat','simfMRI')
end

%%
load('MAP_RECOVER_fMRI_IC_fixedf0_48Subj_40Trials.mat')
n_subj = length(s.(cur_exp).ID);

rec_params = zeros(n_subj,4);

for i = 1:n_subj
    cur_subj = "subj"+i;
    tmp_params = simfMRI.map.(cur_subj).(M.modid{1}).gauss.mu;

    rec_params(i,1) = norm2alpha(tmp_params(1));
    rec_params(i,2) = norm2beta(tmp_params(2));
    rec_params(i,3) = norm2alpha(tmp_params(3));
    rec_params(i,4) = norm2delta(tmp_params(4));
end

%%
% Envy
corrplot([fit_params(:,1) rec_params(:,1)    ])
% Temperature
corrplot([fit_params(:,2) rec_params(:,2)    ])
% Adaptation
corrplot([fit_params(:,3) rec_params(:,3)    ])
% Delta
corrplot([fit_params(:,4) rec_params(:,4)    ])



