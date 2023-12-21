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

gen_params = zeros(nP,4);
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
       
        % Delta
        temp_delta_IC = norm2delta(normrnd(0.5,1));
        while temp_delta_IC > 2 | temp_delta_IC < -2
            temp_delta_IC = norm2delta(normrnd(0.5,1));
        end
    
        gen_params(i,1) = temp_alpha;
        gen_params(i,2) = temp_beta;
        gen_params(i,4) = temp_delta_IC;

        [offer_ic_0, choice_ic_0] = simulate_0step_ic_noNorm(gen_params(i,1:3));
        if sum(choice_ic_0) ~= 30 && sum(choice_ic_0) ~= 0
            good = good +1;
        end
        [offer_nc_0, choice_nc_0] = simulate_0step_nc_noNorm(gen_params(i,1:3));
        if sum(choice_nc_0) ~= 30 && sum(choice_nc_0) ~= 0
            good = good +1;
        end
       

        [offer_ic_1, choice_ic_1] = simulate_1step_ic_noNorm(gen_params(i,1:4));
        if sum(choice_ic_1) ~= 30 && sum(choice_ic_1) ~= 0
           good = good +1;
        end
        

        [offer_nc_1, choice_nc_1] = simulate_1step_nc_noNorm(gen_params(i,1:4));
        if sum(choice_nc_1) ~= 30 && sum(choice_nc_1) ~= 0
            good = good +1;
        end

        [offer_ic_2, choice_ic_2] = simulate_2step_ic_noNorm(gen_params(i,1:4));
        if sum(choice_ic_2) ~= 30 && sum(choice_ic_2) ~= 0
            good = good +1;
        end

        [offer_nc_2, choice_nc_2] = simulate_2step_nc_noNorm(gen_params(i,1:4));
        if sum(choice_nc_2) ~= 30 && sum(choice_nc_2) ~= 0
            good = good +1;
        end

        [offer_ic_3, choice_ic_3] = simulate_3step_ic_noNorm(gen_params(i,1:4));
        if sum(choice_ic_3) ~= 30 && sum(choice_ic_3) ~= 0
            good = good +1;
        end

        [offer_nc_3, choice_nc_3] = simulate_3step_nc_noNorm(gen_params(i,1:4));
        if sum(choice_nc_3) ~= 30 && sum(choice_nc_3) ~= 0
            good = good +1;
        end

    end

    tmp_struct0_IC = struct();
    tmp_struct1_IC = struct();
    tmp_struct2_IC = struct();
    tmp_struct3_IC = struct();

    tmp_struct0_NC = struct();
    tmp_struct1_NC = struct();
    tmp_struct2_NC = struct();
    tmp_struct3_NC = struct();

    tmp_struct0_IC.offer = {};
    tmp_struct1_IC.offer = {};
    tmp_struct2_IC.offer = {};
    tmp_struct3_IC.offer = {};
    tmp_struct0_IC.choice = {};
    tmp_struct1_IC.choice= {};
    tmp_struct2_IC.choice = {};
    tmp_struct3_IC.choice = {};

    tmp_struct0_NC.offer = {};
    tmp_struct1_NC.offer = {};
    tmp_struct2_NC.offer = {};
    tmp_struct3_NC.offer = {};
    tmp_struct0_NC.choice = {};
    tmp_struct1_NC.choice= {};
    tmp_struct2_NC.choice = {};
    tmp_struct3_NC.choice = {};

    tmp_struct0_IC.offer = offer_ic_0;
    tmp_struct0_NC.offer = offer_nc_0;

    tmp_struct1_IC.offer = offer_ic_1;
    tmp_struct1_NC.offer = offer_nc_1;

    tmp_struct2_IC.offer = offer_ic_2;
    tmp_struct2_NC.offer = offer_nc_2;

    tmp_struct3_IC.offer = offer_ic_3;
    tmp_struct3_NC.offer = offer_nc_3;

    tmp_struct0_IC.choice = choice_ic_0;
    tmp_struct0_NC.choice = choice_nc_0;

    tmp_struct1_IC.choice = choice_ic_1;
    tmp_struct1_NC.choice = choice_nc_1;

    tmp_struct2_IC.choice = choice_ic_2;
    tmp_struct2_NC.choice = choice_nc_2;

    tmp_struct3_IC.choice = choice_ic_3;
    tmp_struct3_NC.choice = choice_nc_3;

    sim_beh_0_IC{i} = tmp_struct0_IC;
    sim_beh_1_IC{i} = tmp_struct1_IC;
    sim_beh_2_IC{i} = tmp_struct2_IC;
    sim_beh_3_IC{i} = tmp_struct3_IC;

    sim_beh_0_NC{i} = tmp_struct0_NC;
    sim_beh_1_NC{i} = tmp_struct1_NC;
    sim_beh_2_NC{i} = tmp_struct2_NC;
    sim_beh_3_NC{i} = tmp_struct3_NC;

end


%%
simUG0_IC = struct();
simUG0_IC.beh = sim_beh_0_IC;
simUG0_IC.expname = 'simUG0_IC';
simUG0_IC.ID = IDs;
simUG0_IC.params = gen_params;
simUG0_IC.em = {};

simUG0_NC = struct();
simUG0_NC.beh = sim_beh_0_NC;
simUG0_NC.expname = 'simUG0_NC';
simUG0_NC.ID = IDs;
simUG0_NC.params = gen_params;
simUG0_NC.em = {};

simUG1_IC = struct();
simUG1_IC.beh = sim_beh_1_IC;
simUG1_IC.expname = 'simUG1_IC';
simUG1_IC.ID = IDs;
simUG1_IC.params = gen_params;
simUG1_IC.em = {};

simUG1_NC = struct();
simUG1_NC.beh = sim_beh_1_NC;
simUG1_NC.expname = 'simUG1_NC';
simUG1_NC.ID = IDs;
simUG1_NC.params = gen_params;
simUG1_NC.em = {};

simUG2_IC = struct();
simUG2_IC.beh = sim_beh_2_IC;
simUG2_IC.expname = 'simUG2_IC';
simUG2_IC.ID = IDs;
simUG2_IC.params = gen_params;
simUG2_IC.em = {};

simUG2_NC = struct();
simUG2_NC.beh = sim_beh_2_NC;
simUG2_NC.expname = 'simUG2_NC';
simUG2_NC.ID = IDs;
simUG2_NC.params = gen_params;
simUG2_NC.em = {};

simUG3_IC = struct();
simUG3_IC.beh = sim_beh_3_IC;
simUG3_IC.expname = 'simUG3_IC';
simUG3_IC.ID = IDs;
simUG3_IC.params = gen_params;
simUG3_IC.em = {};

simUG3_NC = struct();
simUG3_NC.beh = sim_beh_3_NC;
simUG3_NC.expname = 'simUG3_NC';
simUG3_NC.ID = IDs;
simUG3_NC.params = gen_params;
simUG3_NC.em = {};


%%

% Put into into the s structure
s = struct();
s.simUG0_IC = simUG0_IC;
s.simUG0_NC = simUG0_NC;
s.simUG1_IC = simUG1_IC;
s.simUG1_NC = simUG1_NC;
s.simUG2_IC = simUG2_IC;
s.simUG2_NC = simUG2_NC;
s.simUG3_IC = simUG3_IC;
s.simUG3_NC = simUG3_NC;

count = 0;
params = [];
for i = 1:150
    num_same_resp_ic = sum(s.simUG2_IC.beh{1, i}.choice(1) == s.simUG2_IC.beh{1, i}.choice );
    num_same_resp_nc = sum(s.simUG2_NC.beh{1, i}.choice(1) == s.simUG2_NC.beh{1, i}.choice  );

    if num_same_resp_ic == 30 || num_same_resp_nc == 30
        disp(i)
        params = [params; i, s.simUG2.params(i,:)];
        count = count + 1;
    end
end

%%
save('Hackathon-Data_Separate-IC-NC_s150_noFlat_noNorm.mat', 's');


