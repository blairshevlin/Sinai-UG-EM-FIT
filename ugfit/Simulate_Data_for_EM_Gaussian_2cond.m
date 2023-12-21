% Simulate UG Data 
% First generates parameters in Gaussian Space before converting to native
% parameter space
% 2cond means that both conditions share all params except for delta
% Created by BRK Shevlin, December 14 2023
clear
addpath('simulation');

global offer0
global eta
global n

offer0 = 5;
n = 30;             % number of trials
eta = 0.8;          % fixed parameter

% Number of subejcts
nP = 250;
IDs = 1:nP;

% simulate in Gaussian space
gen_params = normrnd(0,1,nP,6);

% Conver to proper parameter spaces
for i = 1:nP

    % Alpha
    gen_params(i,1) = norm2alpha(gen_params(i,1));
    % Beta
    gen_params(i,2) = norm2beta(gen_params(i,2));
    % Initial Norm (fixed)
    gen_params(i,3) = 10;
    % Epsilon
    gen_params(i,4) = norm2alpha(gen_params(i,4));
    % Delta IC
    gen_params(i,5) = norm2delta(gen_params(i,5));
    % Delta NC
    gen_params(i,6) = norm2delta(gen_params(i,6));

end


%%

% Simulate UG0
sim_beh = {};
for i = 1:nP

    % Can ignore delta for these
    [offer_ic, choice_ic] = simulate_0step_ic(gen_params(i,1:4));
    [offer_nc, choice_nc] = simulate_0step_nc(gen_params(i,1:4));

    tmp_struct = struct();

    tmp_struct.offer = {};
    tmp_struct.offer{1} = offer_ic;
    tmp_struct.offer{2} = offer_nc;

    tmp_struct.choice = {};
    tmp_struct.choice{1} = choice_ic;
    tmp_struct.choice{2} = choice_nc;

    sim_beh{i} = tmp_struct;
    
end


simUG0 = struct();
simUG0.beh = sim_beh;
simUG0.expname = 'simUG0_2cond';
simUG0.ID = IDs;
simUG0.params = gen_params;
simUG0.em = {};


%%
% Simulate UG1
sim_beh = {};

for i = 1:nP

    [offer_ic, choice_ic] = simulate_1step_ic(gen_params(i,1:5));
    [offer_nc, choice_nc] = simulate_1step_nc(gen_params(i,[1:4,6]));

    tmp_struct = struct();

    tmp_struct.offer = {};
    tmp_struct.offer{1} = offer_ic;
    tmp_struct.offer{2} = offer_nc;

    tmp_struct.choice = {};
    tmp_struct.choice{1} = choice_ic;
    tmp_struct.choice{2} = choice_nc;

    sim_beh{i} = tmp_struct;
end

simUG1 = struct();
simUG1.beh = sim_beh;
simUG1.expname = 'simUG1_2cond';
simUG1.ID = IDs;
simUG1.params = gen_params;
simUG1.em = {};
%%
% Simulate UG2
sim_beh = {};

for i = 1:nP

    [offer_ic, choice_ic] = simulate_2step_ic(gen_params(i,1:5));
    [offer_nc, choice_nc] = simulate_2step_nc(gen_params(i,[1:4,6]));

    tmp_struct = struct();

    tmp_struct.offer = {};
    tmp_struct.offer{1} = offer_ic;
    tmp_struct.offer{2} = offer_nc;

    tmp_struct.choice = {};
    tmp_struct.choice{1} = choice_ic;
    tmp_struct.choice{2} = choice_nc;

    sim_beh{i} = tmp_struct;
end

simUG2 = struct();
simUG2.beh = sim_beh;
simUG2.expname = 'simUG2_2cond';
simUG2.ID = IDs;
simUG2.params = gen_params;
simUG2.em = {};
%%
% Simulate UG3
sim_beh = {};

for i = 1:nP

    [offer_ic, choice_ic] = simulate_3step_ic(gen_params(i,1:5));
    [offer_nc, choice_nc] = simulate_3step_nc(gen_params(i,[1:4,6]));

    tmp_struct = struct();

    tmp_struct.offer = {};
    tmp_struct.offer{1} = offer_ic;
    tmp_struct.offer{2} = offer_nc;

    tmp_struct.choice = {};
    tmp_struct.choice{1} = choice_ic;
    tmp_struct.choice{2} = choice_nc;

    sim_beh{i} = tmp_struct;
end

simUG3 = struct();
simUG3.beh = sim_beh;
simUG3.expname = 'simUG3_2cond';
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

save('DATA_Simulated-Gauss_f0_250Subj_2cond_30Trials_Dec15.mat', 's');


