clearvars


addpath('models'); 
addpath('tools');

load('DATA_Simulated_fixedf0_50Subj_30Trials.mat')

%%
% define data set(s) of interest:
expids = {'simUG2f0'}; %'simUG0','simUG1','simUG2','simUG3', ...
    %'simUG0f0','simUG1f0','simUG2f0','simUG3f0'};

% how to fit RL:
M.dofit     = 1;                                                                                                     % whether to fit or not                                                           
M.doMC      = 1;                                                                                                     % whether to do model comparison or not  
M.quickfit  = 0;                                                                                                     % whether to lower the convergence criterion for model fitting (makes fitting quicker) (1=quick fit)
M.omtBMS   = 1;                                                                                                     % omit bayesian model comparison if you don't have SPM instaslled
M.modid     = {'ms_UG2_etaf_f0f_adaptiveNorm'};%{

cur_exp = expids{1};


n_subj = length(s.(cur_exp).ID);

for n = 1:n_subj
    s.(cur_exp).map.("subj"+n) = struct();
end
%%
%nP = 4;
%parpool("local",nP);


for n = 1:n_subj
    disp("Subject "+n)
    cur_subj = "subj"+n;
    dotry=1;
    while 1==dotry
        try
            close all;
            s.(cur_exp).map.(cur_subj) = MAPfit_ms( s.(cur_exp), M.modid{1},M.quickfit, n );
            dotry=0;
        catch
            dotry=1; disp('caught');
        end
    end
    save('MAP_FIT_Simulated_fixedf0_50Subj_30Trials.mat','s')
end

%delete(gcp('nocreate'))
%%
load('MAP_FIT_Simulated_fixedf0_50Subj_30Trials.mat')


param_tru = [s.simUG2f0.params(:,1) s.simUG2f0.params(:,2) s.simUG2f0.params(:,4) s.simUG2f0.params(:,5)] ;

est_params = zeros(size(param_tru,1),size(param_tru,2));

n_subj = length(s.('simUG2f0').ID);

for i = 1:n_subj
    cur_subj = "subj"+i;
   % tmp_params = s.('simUG2f0').map.(cur_subj).(M.modid{1}).q;
   tmp_params = s.('simUG2f0').map.(cur_subj).(M.modid{1}).gauss.mu;

    est_params(i,1) = norm2alpha(tmp_params(1));
    est_params(i,2) = norm2beta(tmp_params(2));
    est_params(i,3) = norm2alpha(tmp_params(3));
    est_params(i,4) = norm2delta(tmp_params(4));
end


%%
% Envy
corrplot([est_params(:,1) param_tru(:,1)    ])
% Temperature
corrplot([est_params(:,2) param_tru(:,2)    ])
% Adaptation
corrplot([est_params(:,3) param_tru(:,3)    ])
% Delta
corrplot([est_params(:,4) param_tru(:,4)    ])



