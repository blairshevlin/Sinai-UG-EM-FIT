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
nP = 150;
IDs = 1:nP;

% simulate in Gaussian space for alpha, delta IC and delta NC
gen_params = normrnd(0,1,nP,6);

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

    % Delta NC
    temp_delta_NC = norm2delta(gen_params(i,6));
    while temp_delta_NC > 2 | temp_delta_NC < -2
        temp_delta_NC = norm2delta(normrnd(0,1));
    end
    gen_params(i,6) = temp_delta_NC;

end


%%

% Simulate UG0
sim_beh = {};
for i = 1:nP

    % Can ignore delta for these
    [offer_ic, choice_ic] = simulate_0step_ic(gen_params(i,1:4));
    while sum(choice_ic) == 0 || sum(choice_ic) == length(choice_ic)
        [offer_ic, choice_ic] = simulate_0step_ic(gen_params(i,1:4));
    end
    [offer_nc, choice_nc] = simulate_0step_nc(gen_params(i,1:4));
    while sum(choice_nc) == 0 || sum(choice_nc) == length(choice_nc)
        [offer_nc, choice_nc] = simulate_0step_nc(gen_params(i,1:4));
    end

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
    while sum(choice_ic) == 0 || sum(choice_ic) == length(choice_ic)
        [offer_ic, choice_ic] = simulate_1step_ic(gen_params(i,1:5));
    end

    [offer_nc, choice_nc] = simulate_1step_nc(gen_params(i,[1:4,6]));
    while sum(choice_nc) == 0 || sum(choice_nc) == length(choice_nc)
        [offer_nc, choice_nc] = simulate_1step_nc(gen_params(i,1:4));
    end

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
    while sum(choice_ic) == 0 || sum(choice_ic) == length(choice_ic)
        [offer_ic, choice_ic] = simulate_2step_ic(gen_params(i,1:5));
    end

    [offer_nc, choice_nc] = simulate_2step_nc(gen_params(i,[1:4,6]));
    while sum(choice_nc) == 0 || sum(choice_nc) == length(choice_nc)
        [offer_nc, choice_nc] = simulate_2step_nc(gen_params(i,1:4));
    end

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
    while sum(choice_ic) == 0 || sum(choice_ic) == length(choice_ic)
        [offer_ic, choice_ic] = simulate_3step_ic(gen_params(i,1:5));
    end

    [offer_nc, choice_nc] = simulate_3step_nc(gen_params(i,[1:4,6]));
    while sum(choice_nc) == 0 || sum(choice_nc) == length(choice_nc)
        [offer_nc, choice_nc] = simulate_3step_nc(gen_params(i,1:4));
    end

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

save('Hackathon-Data_Combined-IC-NC_s150_noFlat.mat', 's');


