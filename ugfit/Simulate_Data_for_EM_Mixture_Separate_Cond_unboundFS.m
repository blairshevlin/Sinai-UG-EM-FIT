% Simulate UG Data 
% First generates parameters in Gaussian Space before converting to native
% parameter space
% 2cond means that both conditions share all params except for delta
% Created by BRK Shevlin, December 14 2023
clear
addpath('simulation');
addpath('tools');

global offer0
global eta
global n

offer0 = 5;
n = 30;             % number of trials
eta = 0.8;          % fixed parameter

% Number of subejcts
nP = 150;
IDs = 1:nP;

% simulate in Gaussian space for alpha, delta IC and delta NC
gen_params = normrnd(0,1,nP,5);

% Change to gamma distribution for beta param
gen_params(:,2) = gamrnd(1,5,nP,1);

% Change to beta distribution for epsilon
gen_params(:,4) = betarnd(1.1,1.1,nP,1);

%%

% Conver to proper parameter spaces
for i = 1:nP

    % Alpha
    temp_alpha = norm2alpha(gen_params(i,1));
    while temp_alpha > 0.95 | temp_alpha < 0.05
        temp_alpha = norm2alpha(normrnd(0,1));
    end
    gen_params(i,1) = temp_alpha;
    
    % Beta
    temp_beta = gen_params(i,2);
    while temp_beta > 15 | temp_beta < 0.75
        temp_beta = gamrnd(1,5);
    end
    gen_params(i,2) = temp_beta;

    % Initial Norm (fixed)
    gen_params(i,3) = 10;

    % Epsilon
    temp_epsilon = gen_params(i,4);
    while temp_epsilon > 0.95 | temp_epsilon < 0.05
        temp_epsilon = betarnd(1.1,1.1,1);
    end
    gen_params(i,4) = temp_epsilon;

    % Delta IC
    temp_delta_IC = norm2delta(gen_params(i,5));
    while temp_delta_IC > 2 | temp_delta_IC < -2
        temp_delta_IC = norm2delta(normrnd(0,1));
    end
    gen_params(i,5) = temp_delta_IC;

end


%%

% Simulate UG0
sim_beh_IC = {};
sim_beh_NC = {};

for i = 1:nP

    % Can ignore delta for these
    [offer_ic, choice_ic] = simulate_0step_ic_unboundFS(gen_params(i,1:4));
    [offer_nc, choice_nc] = simulate_0step_nc_unboundFS(gen_params(i,1:4));

    tmp_struct_IC = struct();
    tmp_struct_NC = struct();

    tmp_struct_IC.offer = offer_ic;
    tmp_struct_NC.offer = offer_nc;

    tmp_struct_IC.choice = choice_ic;
    tmp_struct_NC.choice = choice_nc;

    sim_beh_IC{i} = tmp_struct_IC;
    sim_beh_NC{i} = tmp_struct_NC;
    
end


simUG0_IC = struct();
simUG0_IC.beh = sim_beh_IC;
simUG0_IC.expname = 'simUG0_IC';
simUG0_IC.ID = IDs;
simUG0_IC.params = gen_params;
simUG0_IC.em = {};

simUG0_NC = struct();
simUG0_NC.beh = sim_beh_NC;
simUG0_NC.expname = 'simUG0_NC';
simUG0_NC.ID = IDs;
simUG0_NC.params = gen_params;
simUG0_NC.em = {};
%%
% Simulate UG1
sim_beh_IC = {};
sim_beh_NC = {};

for i = 1:nP

    [offer_ic, choice_ic] = simulate_1step_ic_unboundFS(gen_params(i,1:5));
    [offer_nc, choice_nc] = simulate_1step_nc_unboundFS(gen_params(i,1:5));

    tmp_struct_IC = struct();
    tmp_struct_NC = struct();

    tmp_struct_IC.offer = offer_ic;
    tmp_struct_NC.offer = offer_nc;

    tmp_struct_IC.choice = choice_ic;
    tmp_struct_NC.choice = choice_nc;

    sim_beh_IC{i} = tmp_struct_IC;
    sim_beh_NC{i} = tmp_struct_NC;
end

simUG1_IC = struct();
simUG1_IC.beh = sim_beh_IC;
simUG1_IC.expname = 'simUG1_IC';
simUG1_IC.ID = IDs;
simUG1_IC.params = gen_params;
simUG1_IC.em = {};

simUG1_NC = struct();
simUG1_NC.beh = sim_beh_NC;
simUG1_NC.expname = 'simUG1_NC';
simUG1_NC.ID = IDs;
simUG1_NC.params = gen_params;
simUG1_NC.em = {};
%%
% Simulate UG2
sim_beh_IC = {};
sim_beh_NC = {};

for i = 1:nP

    [offer_ic, choice_ic] = simulate_2step_ic_unboundFS(gen_params(i,1:5));
    [offer_nc, choice_nc] = simulate_2step_nc_unboundFS(gen_params(i,1:5));

    tmp_struct_IC = struct();
    tmp_struct_NC = struct();

    tmp_struct_IC.offer = offer_ic;
    tmp_struct_NC.offer = offer_nc;

    tmp_struct_IC.choice = choice_ic;
    tmp_struct_NC.choice = choice_nc;

    sim_beh_IC{i} = tmp_struct_IC;
    sim_beh_NC{i} = tmp_struct_NC;
end

simUG2_IC = struct();
simUG2_IC.beh = sim_beh_IC;
simUG2_IC.expname = 'simUG2_IC';
simUG2_IC.ID = IDs;
simUG2_IC.params = gen_params;
simUG2_IC.em = {};

simUG2_NC = struct();
simUG2_NC.beh = sim_beh_NC;
simUG2_NC.expname = 'simUG2_NC';
simUG2_NC.ID = IDs;
simUG2_NC.params = gen_params;
simUG2_NC.em = {};
%%
% Simulate UG3
sim_beh_IC = {};
sim_beh_NC = {};

for i = 1:nP

    [offer_ic, choice_ic] = simulate_3step_ic_unboundFS(gen_params(i,1:5));
    [offer_nc, choice_nc] = simulate_3step_nc_unboundFS(gen_params(i,1:5));

    tmp_struct_IC = struct();
    tmp_struct_NC = struct();

    tmp_struct_IC.offer = offer_ic;
    tmp_struct_NC.offer = offer_nc;

    tmp_struct_IC.choice = choice_ic;
    tmp_struct_NC.choice = choice_nc;

    sim_beh_IC{i} = tmp_struct_IC;
    sim_beh_NC{i} = tmp_struct_NC;

end

simUG3_IC = struct();
simUG3_IC.beh = sim_beh_IC;
simUG3_IC.expname = 'simUG3_IC';
simUG3_IC.ID = IDs;
simUG3_IC.params = gen_params;
simUG3_IC.em = {};

simUG3_NC = struct();
simUG3_NC.beh = sim_beh_NC;
simUG3_NC.expname = 'simUG3_NC';
simUG3_NC.ID = IDs;
simUG3_NC.params = gen_params;
simUG3_NC.em = {};

%%
% Put into into the s structure
s = struct();

% Controllable
s.simUG0_IC = simUG0_IC;
s.simUG1_IC = simUG1_IC;
s.simUG2_IC = simUG2_IC;
s.simUG3_IC = simUG3_IC;

% Uncontrollable
s.simUG0_NC = simUG0_NC;
s.simUG1_NC = simUG1_NC;
s.simUG2_NC = simUG2_NC;
s.simUG3_NC = simUG3_NC;

save('Hackathon-Data_Separate-IC-NC_s150_unboundFS.mat', 's');


