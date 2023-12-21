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
n = 40;             % number of trials
eta = 0.8;          % fixed parameter

% Number of subejcts
nP = 150;
IDs = 1:nP;

% simulate in Gaussian space for alpha, delta IC and delta NC
gen_params = zeros(nP,6);


%%

% Conver to proper parameter spaces
for i = 1:nP
    fprintf(['Subject' num2str(i)])
    % Run while loops to make sure there are no flat responders

    n_while = 0;
    good = 0;

    % 0-Step
    while good < 8
        good = 0;
        n_while = n_while + 1 ;
        fprintf(['\nIteration ' num2str(n_while)])

         % Alpha
        temp_alpha = norm2alpha(normrnd(0,1));
        while temp_alpha > 0.95 | temp_alpha < 0.05
            temp_alpha = norm2alpha(normrnd(0,1));
        end
    
        % Beta
        temp_beta = gamrnd(1,5);
        while temp_beta > 15 | temp_beta < 0.75
            temp_beta = gamrnd(1,5);
        end
    
        % Initial Norm (fixed)
        gen_params(i,3) = 10;
    
        % Epsilon
        temp_epsilon = betarnd(1.1,1.1,1);
        while temp_epsilon > 0.95 | temp_epsilon < 0.05
            temp_epsilon = betarnd(1.1,1.1,1);
        end
    
        % Delta IC
        temp_delta_IC = norm2delta(normrnd(0.5,1));
        while temp_delta_IC > 2 | temp_delta_IC < -2
            temp_delta_IC = norm2delta(normrnd(0.5,1));
        end
    
        % Delta NC
        temp_delta_NC = norm2delta(normrnd(0.5,1));
        while temp_delta_NC > 2 | temp_delta_NC < -2
            temp_delta_NC = norm2delta(normrnd(0.5,1));
        end
    
        gen_params(i,1) = temp_alpha;
        gen_params(i,2) = temp_beta;
        gen_params(i,4) = temp_epsilon;
        gen_params(i,5) = temp_delta_IC;
        gen_params(i,6) = temp_delta_NC;

        [offer_ic_0, choice_ic_0] = simulate_0step_ic(gen_params(i,1:4));
        if sum(choice_ic_0) ~= 40 && sum(choice_ic_0) ~= 0
            good = good +1;
        end
        [offer_nc_0, choice_nc_0] = simulate_0step_nc(gen_params(i,1:4));
        if sum(choice_nc_0) ~= 40 && sum(choice_nc_0) ~= 0
            good = good +1;
        end
        

        [offer_ic_1, choice_ic_1] = simulate_1step_ic(gen_params(i,1:5));
        if sum(choice_ic_1) ~= 40 && sum(choice_ic_1) ~= 0
           good = good +1;
        end
        

        [offer_nc_1, choice_nc_1] = simulate_1step_nc(gen_params(i,[1:4,6]));
        if sum(choice_nc_1) ~= 40 && sum(choice_nc_1) ~= 0
            good = good +1;
        end

        [offer_ic_2, choice_ic_2] = simulate_2step_ic(gen_params(i,1:5));
        if sum(choice_ic_2) ~= 40 && sum(choice_ic_2) ~= 0
            good = good +1;
        end

        [offer_nc_2, choice_nc_2] = simulate_2step_nc(gen_params(i,[1:4,6]));
        if sum(choice_nc_2) ~= 40 && sum(choice_nc_2) ~= 0
            good = good +1;
        end

        [offer_ic_3, choice_ic_3] = simulate_3step_ic(gen_params(i,1:5));
        if sum(choice_ic_3) ~= 40 && sum(choice_ic_3) ~= 0
            good = good +1;
        end

        [offer_nc_3, choice_nc_3] = simulate_3step_nc(gen_params(i,[1:4,6]));
        if sum(choice_nc_3) ~= 40 && sum(choice_nc_3) ~= 0
            good = good +1;
        end

    end

    tmp_struct0 = struct();
    tmp_struct1 = struct();
    tmp_struct2 = struct();
    tmp_struct3 = struct();

    tmp_struct0.offer = {};
    tmp_struct1.offer = {};
    tmp_struct2.offer = {};
    tmp_struct3.offer = {};
    tmp_struct0.choice = {};
    tmp_struct1.choice= {};
    tmp_struct2.choice = {};
    tmp_struct3.choice = {};

    tmp_struct0.offer{1} = offer_ic_0;
    tmp_struct0.offer{2} = offer_nc_0;

    tmp_struct1.offer{1} = offer_ic_1;
    tmp_struct1.offer{2} = offer_nc_1;

    tmp_struct2.offer{1} = offer_ic_2;
    tmp_struct2.offer{2} = offer_nc_2;

    tmp_struct3.offer{1} = offer_ic_3;
    tmp_struct3.offer{2} = offer_nc_3;

    tmp_struct0.choice{1} = choice_ic_0;
    tmp_struct0.choice{2} = choice_nc_0;

    tmp_struct1.choice{1} = choice_ic_1;
    tmp_struct1.choice{2} = choice_nc_1;

    tmp_struct2.choice{1} = choice_ic_2;
    tmp_struct2.choice{2} = choice_nc_2;

    tmp_struct3.choice{1} = choice_ic_3;
    tmp_struct3.choice{2} = choice_nc_3;

    sim_beh_0{i} = tmp_struct0;
    sim_beh_1{i} = tmp_struct1;
    sim_beh_2{i} = tmp_struct2;
    sim_beh_3{i} = tmp_struct3;

end


%%
simUG0 = struct();
simUG0.beh = sim_beh_0;
simUG0.expname = 'simUG0_2cond';
simUG0.ID = IDs;
simUG0.params = gen_params;
simUG0.em = {};

simUG1 = struct();
simUG1.beh = sim_beh_1;
simUG1.expname = 'simUG1_2cond';
simUG1.ID = IDs;
simUG1.params = gen_params;
simUG1.em = {};

simUG2 = struct();
simUG2.beh = sim_beh_2;
simUG2.expname = 'simUG2_2cond';
simUG2.ID = IDs;
simUG2.params = gen_params;
simUG2.em = {};

simUG3 = struct();
simUG3.beh = sim_beh_3;
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

count = 0;
params = [];
for i = 1:150
    num_same_resp_ic = sum(s.simUG2.beh{1, i}.choice{1, 1}(1) == s.simUG2.beh{1, i}.choice{1, 1}  );
    num_same_resp_nc = sum(s.simUG2.beh{1, i}.choice{1, 2}(1) == s.simUG2.beh{1, i}.choice{1, 2}  );

    if num_same_resp_ic == 40 || num_same_resp_nc == 40
        disp(i)
        params = [params; i, s.simUG2.params(i,:)];
        count = count + 1;
    end
end

%%
save('Hackathon-Data_Combined-IC-NC_s150_noFlat_t40.mat', 's');


