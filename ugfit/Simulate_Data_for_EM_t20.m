% Convert UG to a format for EM procedure
% Created by BRK Shevlin, April 2023
clear
addpath('simulation');

global offer0
global eta
global n

offer0 = 5;
n = 20;             % number of trials
eta = 0.8;          % fixed parameter

% Number of subejcts
nP = 50;
IDs = 1:nP;

gen_params = rand(nP,5);
gen_params(:,2) = 15*gen_params(:,2);
gen_params(:,3) = 10;%20*gen_params(:,3);  
gen_params(:,5) = 4*gen_params(:,5) - 2;  

% Set floor for beta
for i = 1:nP
    if gen_params(i,2) < 1.5; gen_params(i,2) = 1.5; end
end


%%
% Simulate UG2
offer_cell = {};
choice_cell = {};
for i = 1:nP

    [offer, choice] = simulate_2step_ic(gen_params(i,:));

    offer_cell{i} = offer;
    choice_cell{i} = choice;
end
% Behavior cells
sim_beh = struct();
sim_beh.offer = offer_cell;
sim_beh.choice = choice_cell; 

simUG2 = struct();
simUG2.beh = sim_beh;
simUG2.expname = 'simUG2';
simUG2.ID = IDs;
simUG2.params = gen_params;
simUG2.em = {};


%%
% Put into into the s structure
s = struct();
s.simUG2 = simUG2;

save('DATA_Simulated_50Subj_20Trials_Oct4.mat', 's');


