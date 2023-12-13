% Convert UG2 to a format for EM procedure
% Created by BRK Shevlin, May 2023
clear;
infile = 'C:/Users/blair/Documents/Research/Sinai-UG-EM-FIT/example_data/beh001.mat';
load(infile);

% Load in table of participants who failed attention check
T = readtable("C:/Users/blair/Documents/Research/Sinai-UG-PTSD/COVID/prolific/bad_ids.csv");

% Number of subejcts and extract participant iDS
possIDs_mat = cell2mat(ID);
possIDs = {};
tot = 0;
for i = 1:size(ID,1)
    tot = tot + 1;
    idx = possIDs_mat(i,:);
    possIDs{tot} = idx;
    
end

% Missing Data
exclude_pids = {'59ad6f1e09709e00013c2ba5','5a501c26eedc32000141f4f2','5d924f2a5b219e00183ae94b','5d4613a2da9cb60001aa4948', '578ba9442fc0d400012c71dc', '5dd3396efd5b2834c06111ac', '56fdff4ee0f9ff000f19c466', '5e761a1c409bdd17b294f631', '5e0cc3cab7b33046d760e96d', '5e78b11ddd11e44315c96cf7', '5c0990b854deae0001ac693c', '5e73b2c44bccf231dc550e9b', '5dcc6284b4cc78902f46ec05', '5e3e54f69e51f80b67c1cc06', '5b975addbb32a6000182d3e2', '5d20fe3d4f2cea001ae5c4dc', '5d58471ffe8768001a31d33a', '5e850b0e390e520ec806b084', '5dd9d18cb043899633ab9cb8', '5e72443b467dff17f098b64d', '5c3282eb47817b0001581512', '5d6fe28a8c1aea0016d8ffb0', '5e6adfd316a997099374a2e7', '5dd0b075c944d1174e6e3c5a', '5c6167386fabd400010977be', '5e2a777e81f6df0d34abbd07', '5dfe37d954ff23adf61a743d', '5e6d7b5d5c4019347585fb29', '5d25df839542a40001a83bf4', '5de8703bead0f17ea717e155'};

%% 
% We only want participants who are non flat in both conditions

tot=0;
for i = 1:size(possIDs,2)

    % Go through IDs and make sure non failed the attention check
    check=ismember(T.x,possIDs{i});
    if sum(check) ~= 0
        fprintf('\nSubject %s (%i) failed attention check',possIDs{i},i);
        continue
    end
    % Go through IDs and make sure not missing data
    check_2= ismember(exclude_pids,possIDs{i});
    if sum(check_2) ~= 0
        fprintf('\nSubject %s (%i) is missing data',possIDs{i},i);
        continue
    end

    if sum(IC_Choice(:,i))==30 || sum(IC_Choice(:,i))==0 || sum(NC_Choice(:,i))==0 || sum(NC_Choice(:,i))==30
        fprintf('\nSubject %s (%i) was a flat responder\n',possIDs{i},i);
        continue
    end

    tot = tot +1;
    keepStruct_IC = struct();
    keepStruct_NC = struct();

    keepStruct_IC.offer = IC_offer(:,i);
    keepStruct_IC.choice = IC_Choice(:,i);

    keepStruct_NC.offer = NC_offer(:,i);
    keepStruct_NC.choice = NC_Choice(:,i);
    
    IC_beh(:,tot) = {keepStruct_IC};
    NC_beh(:,tot) = {keepStruct_NC};

    IC_IDs{tot}= possIDs{i};
    NC_IDs{tot}= possIDs{i};
    
end




%%
% IC condition
r1IC = struct();
r1IC.beh = IC_beh;
r1IC.expname = 'r1IC';
r1IC.ID = IC_IDs;
r1IC.em = {};

% NC condition
r1NC = struct();
r1NC.beh = NC_beh;
r1NC.expname = 'r1NC';
r1NC.ID = NC_IDs;
r1NC.em = {};

% Put into into the s structure
s = struct();
s.r1IC = r1IC;
s.r1NC = r1NC;

save('DATA_COVID_Round1_noFlat-BOTH_passAttn_allData_Nov30.mat','s');


