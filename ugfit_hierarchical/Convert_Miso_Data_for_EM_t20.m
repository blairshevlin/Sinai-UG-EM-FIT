% Convert UG2 to a format for EM procedure
% Created by BRK Shevlin, May 2023
clear;
addpath('misophonia'); 
indir = 'C:/Users/blair/Documents/Research/Sinai-UG-EM-FIT/misophonia';
infile = 'misophonia_for_Matlab.csv';
data = readtable(infile);


%%
% Number of subejcts and extract participant IDS for each group

% IC Data
IC = data(data.cond == "IC",:);
NC = data(data.cond == "NC",:);

% Only HC
possIDs_IC_hc = cell2mat(unique(IC.prolific_id(IC.miso_group == 0,:)));
possIDs_NC_hc = cell2mat(unique(NC.prolific_id(NC.miso_group == 0,:)));

% Only Miso
possIDs_IC_miso = cell2mat(unique(IC.prolific_id(IC.miso_group == 1,:)));
possIDs_NC_miso = cell2mat(unique(NC.prolific_id(NC.miso_group == 1,:)));


% Restrict to middle 20 trials
IC = IC(IC.trial >= 5 & IC.trial <= 24,:);
NC = NC(NC.trial >= 5  & NC.trial <= 24,:);


%%
% Miso
todata_IC=0;
final_MISO_IC = {};
for i = 1:size(possIDs_IC_miso,1)
    id_idx = possIDs_IC_miso(i,:);

    if sum(IC.choice(strcmp(IC.prolific_id,id_idx),:))==20 || sum(IC.choice(strcmp(IC.prolific_id,id_idx),:))==0
        fprintf('\nSubject %s (%i) was a flat responder\n',possIDs_IC_miso(i,:),i);
        bad_MISO_IC = [bad_MISO_IC id_idx];
        continue
    end
    todata_IC = todata_IC + 1;
    final_MISO_IC{todata_IC} = id_idx;

    keepStruct_IC = struct();
    keepStruct_IC.offer = IC.offer(strcmp(IC.prolific_id,id_idx),:);
    keepStruct_IC.choice = IC.choice(strcmp(IC.prolific_id,id_idx),:);
    IC_beh_miso(:,todata_IC) = {keepStruct_IC};
end

todata_NC=0;
final_MISO_NC = {};
for i = 1:size(possIDs_NC_miso,1)
    id_idx = possIDs_NC_miso(i,:);

    if sum(NC.choice(strcmp(NC.prolific_id,id_idx),:))==20 || sum(NC.choice(strcmp(NC.prolific_id,id_idx),:))==0
        fprintf('\nSubject %s (%i) was a flat responder\n',possIDs_NC_miso(i,:),i);
        bad_MISO_NC = [bad_MISO_NC id_idx];
        continue
    end
    todata_NC = todata_NC + 1;
    final_MISO_NC{todata_NC} = id_idx;

    keepStruct_NC = struct();
    keepStruct_NC.offer = NC.offer(strcmp(NC.prolific_id,id_idx),:);
    keepStruct_NC.choice = NC.choice(strcmp(NC.prolific_id,id_idx),:);
    NC_beh_miso(:,todata_NC) = {keepStruct_NC};
end

% HCs
todatahc_IC=0;
final_HC_IC = {};
for i = 1:size(possIDs_IC_hc,1)
    id_idx = possIDs_IC_hc(i,:);

    if sum(IC.choice(strcmp(IC.prolific_id,id_idx),:))==20 || sum(IC.choice(strcmp(IC.prolific_id,id_idx),:))==0
        fprintf('\nSubject %s (%i) was a flat responder\n',possIDs_IC_hc(i,:),i);
        continue
    end
    todatahc_IC = todatahc_IC + 1;
    final_HC_IC{todatahc_IC} = id_idx;

    keepStruct_IC = struct();
    keepStruct_IC.offer = IC.offer(strcmp(IC.prolific_id,id_idx),:);
    keepStruct_IC.choice = IC.choice(strcmp(IC.prolific_id,id_idx),:);
    IC_beh_hc(:,todatahc_IC) = {keepStruct_IC};
end

todatahc_NC=0;
final_HC_NC = {};
for i = 1:size(possIDs_NC_hc,1)
    id_idx = possIDs_NC_hc(i,:);

    if sum(NC.choice(strcmp(NC.prolific_id,id_idx),:))==20 || sum(NC.choice(strcmp(NC.prolific_id,id_idx),:))==0
        fprintf('\nSubject %s (%i) was a flat responder\n',possIDs_NC_hc(i,:),i);
        continue
    end

    todatahc_NC = todatahc_NC + 1;
    final_HC_NC{todatahc_NC} = id_idx;

    keepStruct_NC = struct();
    keepStruct_NC.offer = NC.offer(strcmp(NC.prolific_id,id_idx),:);
    keepStruct_NC.choice = NC.choice(strcmp(NC.prolific_id,id_idx),:);
    NC_beh_hc(:,todatahc_NC) = {keepStruct_NC};
end


%%
% Create structures

% IC condition
MISO_IC = struct();
MISO_IC.beh = IC_beh_miso;
MISO_IC.expname = 'MISO_IC';
MISO_IC.ID = final_MISO_IC;
MISO_IC.em = {};

HC_IC = struct();
HC_IC.beh = IC_beh_hc;
HC_IC.expname = 'HC_IC';
HC_IC.ID = final_HC_IC;
HC_IC.em = {};

% NC condition
MISO_NC = struct();
MISO_NC.beh = NC_beh_miso;
MISO_NC.expname = 'MISO_NC';
MISO_NC.ID = final_MISO_NC;
MISO_NC.em = {};

HC_NC = struct();
HC_NC.beh = NC_beh_hc;
HC_NC.expname = 'HC_NC';
HC_NC.ID = final_HC_NC;
HC_NC.em = {};

% Put into into the s structure
s = struct();
s.HC_IC = HC_IC;
s.HC_NC = HC_NC;
s.MISO_IC = MISO_IC;
s.MISO_NC = MISO_NC;


%%

save(fullfile(indir, 'DATA_MISO_t20_Oct2_2023.mat'),'s');


