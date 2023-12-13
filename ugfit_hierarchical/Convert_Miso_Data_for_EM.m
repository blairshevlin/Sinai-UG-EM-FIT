% Convert UG2 to a format for EM procedure
% Created by BRK Shevlin, May 2023
clear;
addpath('misophonia'); 
indir = 'C:/Users/blair/Documents/Research/Sinai-UG-EM-FIT/misophonia';
infile = 'misophonia_for_Matlab.csv';
data = readtable(infile);


%%
% Number of subejcts and extract participant IDS for each group

% Only HC
possIDs_hc = cell2mat(unique(data.prolific_id(data.miso_group == 0,:)));

% Only Miso
possIDs_miso = cell2mat(unique(data.prolific_id(data.miso_group == 1,:)));

% IC Data
IC = data(data.cond == "IC",:);
NC = data(data.cond == "NC",:);

trials = 1:30;
IC = IC(IC.trial > 4 & IC.trial < 26,:);

%%
% Miso
todata_IC=0;
for i = 1:size(possIDs_miso,1)
    id_idx = possIDs_miso(i,:);

    if sum(IC.choice(strcmp(IC.prolific_id,id_idx),:))==max(trials) || sum(IC.choice(strcmp(IC.prolific_id,id_idx),:))==0
        fprintf('\nSubject %s (%i) was a flat responder\n',possIDs_miso(i,:),i);
        continue
    end
    todata_IC = todata_IC + 1;

    keepStruct_IC = struct();
    keepStruct_IC.offer = IC.offer(strcmp(IC.prolific_id,id_idx),trials);
    keepStruct_IC.choice = IC.choice(strcmp(IC.prolific_id,id_idx),trials);
    IC_beh_miso(:,todata_IC) = {keepStruct_IC};
end

todata_NC=0;
for i = 1:size(possIDs_miso,1)
    id_idx = possIDs_miso(i,:);

    if sum(NC.choice(strcmp(NC.prolific_id,id_idx),trials))==max(trials) || sum(NC.choice(strcmp(NC.prolific_id,id_idx),trials))==0
        fprintf('\nSubject %s (%i) was a flat responder\n',possIDs_miso(i,:),i);
        continue
    end
    todata_NC = todata_NC + 1;

    keepStruct_NC = struct();
    keepStruct_NC.offer = NC.offer(strcmp(NC.prolific_id,id_idx),trials);
    keepStruct_NC.choice = NC.choice(strcmp(NC.prolific_id,id_idx),trials);
    NC_beh_miso(:,todata_NC) = {keepStruct_NC};
end


% HCs
todatahc_IC=0;
for i = 1:size(possIDs_hc,1)
    id_idx = possIDs_miso(i,:);

    if sum(IC.choice(strcmp(IC.prolific_id,id_idx),trials))==max(trials) || sum(IC.choice(strcmp(IC.prolific_id,id_idx),trials))==0
        fprintf('\nSubject %s (%i) was a flat responder\n',possIDs_miso(i,:),i);
        continue
    end
    todatahc_IC = todatahc_IC + 1;

    keepStruct_IC = struct();
    keepStruct_IC.offer = IC.offer(strcmp(IC.prolific_id,id_idx),trials);
    keepStruct_IC.choice = IC.choice(strcmp(IC.prolific_id,id_idx),trials);
    IC_beh_hc(:,todatahc_IC) = {keepStruct_IC};
end

todatahc_NC=0;
for i = 1:size(possIDs_hc,1)
    id_idx = possIDs_miso(i,:);

    if sum(NC.choice(strcmp(NC.prolific_id,id_idx),max(trials)))==30 || sum(NC.choice(strcmp(NC.prolific_id,id_idx),trials))==0
        fprintf('\nSubject %s (%i) was a flat responder\n',possIDs_miso(i,:),i);
        continue
    end
    todatahc_NC = todatahc_NC + 1;

    keepStruct_NC = struct();
    keepStruct_NC.offer = NC.offer(strcmp(NC.prolific_id,id_idx),trials);
    keepStruct_NC.choice = NC.choice(strcmp(NC.prolific_id,id_idx),trials);
    NC_beh_hc(:,todatahc_NC) = {keepStruct_NC};
end



%%
% Create structures

% IC condition
MISO_IC = struct();
MISO_IC.beh = IC_beh_miso;
MISO_IC.expname = 'MISO_IC';
MISO_IC.ID = possIDs_miso;
MISO_IC.em = {};

HC_IC = struct();
HC_IC.beh = IC_beh_hc;
HC_IC.expname = 'HC_IC';
HC_IC.ID = possIDs_hc;
HC_IC.em = {};

% NC condition
MISO_NC = struct();
MISO_NC.beh = NC_beh_miso;
MISO_NC.expname = 'MISO_NC';
MISO_NC.ID = possIDs_miso;
MISO_NC.em = {};

HC_NC = struct();
HC_NC.beh = NC_beh_hc;
HC_NC.expname = 'HC_NC';
HC_NC.ID = possIDs_hc;
HC_NC.em = {};

% Put into into the s structure
s = struct();
s.HC_IC = HC_IC;
s.HC_NC = HC_NC;
s.MISO_IC = MISO_IC;
s.MISO_NC = MISO_NC;


%%

save(fullfile(indir, 'DATA_MISO_t20_Oct2_2023.mat'),'s');


