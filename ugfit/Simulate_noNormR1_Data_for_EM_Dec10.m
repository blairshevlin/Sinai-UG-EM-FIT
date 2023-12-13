% Simulate Data
% Created by BRK Shevlin, April 2023
clear
addpath('simulation');

global offer0
global eta
global n

offer0 = 5;
n = 30;             % number of trials
eta = 0.8;          % fixed parameter

%
load("FIT_MeanEM_COVID_R1_t30_Dec1.mat")

fit = s.r1IC.em.ms_UG2_etaf_f0f_adaptiveNorm.q;

nP = length(s.r1IC.ID);

for i = 1:nP
    alpha(i) = norm2alpha(fit(i,1));
    beta(i) = norm2beta(fit(i,2));
    eps(i) = norm2alpha(fit(i,3));
    delta(i) = norm2delta(fit(i,4));
end

IDs = 1:nP;

gen_params = zeros(nP,4);

gen_params(:,1) = alpha;
gen_params(:,2) = beta;
gen_params(:,3) = eps;
gen_params(:,4) = delta;


%%

% Simulate UG0
sim_beh = {};
for i = 1:nP

    [offer, choice] = simulate_noNorm_0step_ic(gen_params(i,:));

    tmp_struct = struct();
    tmp_struct.offer = offer';
    tmp_struct.choice = choice';

    sim_beh{i} = tmp_struct;
    
end


simUG0 = struct();
simUG0.beh = sim_beh;
simUG0.expname = 'simUG0';
simUG0.ID = IDs;
simUG0.params = gen_params;
simUG0.em = {};


%%
% Simulate UG1
sim_beh = {};

for i = 1:nP

    [offer, choice] = simulate_noNorm_1step_ic(gen_params(i,:));

    tmp_struct = struct();
    tmp_struct.offer = offer';
    tmp_struct.choice = choice';

    sim_beh{i} = tmp_struct;
end

simUG1 = struct();
simUG1.beh = sim_beh;
simUG1.expname = 'simUG1';
simUG1.ID = IDs;
simUG1.params = gen_params;
simUG1.em = {};
%%
% Simulate UG2
sim_beh = {};

for i = 1:nP

    [offer, choice] = simulate_noNorm_2step_ic(gen_params(i,:));

    tmp_struct = struct();
    tmp_struct.offer = offer';
    tmp_struct.choice = choice';

    sim_beh{i} = tmp_struct;
end

simUG2 = struct();
simUG2.beh = sim_beh;
simUG2.expname = 'simUG2';
simUG2.ID = IDs;
simUG2.params = gen_params;
simUG2.em = {};
%%
% Simulate UG3
sim_beh = {};

for i = 1:nP

    [offer, choice] = simulate_noNorm_3step_ic(gen_params(i,:));

    tmp_struct = struct();
    tmp_struct.offer = offer';
    tmp_struct.choice = choice';

    sim_beh{i} = tmp_struct;
end

simUG3 = struct();
simUG3.beh = sim_beh;
simUG3.expname = 'simUG3';
simUG3.ID = IDs;
simUG3.params = gen_params;
simUG3.em = {};

%%
% Put into into the s structure
s = struct();
s.simUG0 = simUG0;
s.simUG1 = simUG1;
s.simUG2 = simUG2;
s.simUG3 = simUG3;

save('DATA_Simulated-noNormR1_f0_1285-Subj_30Trials_Dec1.mat', 's');


