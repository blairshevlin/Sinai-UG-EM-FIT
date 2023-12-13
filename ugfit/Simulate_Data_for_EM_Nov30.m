% Convert UG to a format for EM procedure
% Created by BRK Shevlin, April 2023
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


gen_params = zeros(nP,5);

%%

for i = 1:nP
    gen_params(i,1) = betarnd(1.1,1.1);
    % Alpha is bound [0,1]
    while gen_params(i,1) > 1.0 || gen_params(i,1) < 0
        gen_params(i,1) = betarnd(1.1,1.1);
    end
      % Beta is bound [0, 15]
    % But, practically use floor of 1.5
    gen_params(i,2) = gamrnd(1.2,5);
    while gen_params(i,2) > 15 || gen_params(i,2) < 1.5
        gen_params(i,2) = gamrnd(1.2,5);
    end

  gen_params(i,3) = 10;
   % Epsilon is bound [0,1]
   gen_params(i,4) = betarnd(1.1,1.1);
    while gen_params(i,4) > 1.0 || gen_params(i,4) < 0
        gen_params(i,4) = betarnd(1.1,1.1);
    end
    % Delta is bound [-2,2]
    gen_params(i,5) = abs(2 * rand(1));
    while gen_params(i,5) > 2 || gen_params(i,5) < 0
        gen_params(i,5) = abs(2 * rand(1));
    end
end

%%

% Simulate UG0
sim_beh = {};
for i = 1:nP

    [offer, choice] = simulate_0step_ic(gen_params(i,:));

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

    [offer, choice] = simulate_1step_ic(gen_params(i,:));

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

    [offer, choice] = simulate_2step_ic(gen_params(i,:));

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

    [offer, choice] = simulate_3step_ic(gen_params(i,:));

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

save('DATA_Simulated_f0_250Subj_30Trials_Nov30.mat', 's');


