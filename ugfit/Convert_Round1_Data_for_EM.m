% Convert UG2 to a format for EM procedure
% Created by BRK Shevlin, May 2023
clear;
infile = 'C:/Users/blair/Documents/Research/Sinai-UG-EM-FIT/example_data/beh001.mat';
load(infile);

% Load in table of participants who failed attention check
T = readtable("C:/Users/blair/Documents/Research/Sinai-UG-PTSD/COVID/prolific/bad_ids.csv");

% Number of subejcts and extract participant iDS
possIDs_mat = cell2mat(ID);

% Go through IDs and make sure non failed the attention check
possIDs = {};
tot = 0;
for i = 1:size(ID,1)
    idx = possIDs_mat(i,:);

    check=ismember(T.x,idx);

    if sum(check)==0
        tot = tot + 1;
        possIDs{tot} = idx;
    end

end

%%

tot=0;
for i = 1:size(possIDs,2)% - 53:size(ID,1)
    if sum(IC_Choice(:,i))==30 || sum(IC_Choice(:,i))==0
        fprintf('\nSubject %s (%i) was a flat responder\n',possIDs{i},i);
        continue
    end
    tot = tot + 1;

    keepID_IC{tot} = possIDs{i};
    keepStruct = struct();
    keepStruct.offer = IC_offer(:,i);
    keepStruct.choice = IC_Choice(:,i);
    
    IC_beh(:,tot) = {keepStruct};
    
end

tot=0;
for i = 1:size(possIDs,2)% - 53:size(ID,1)
    if sum(NC_Choice(:,i))==30 || sum(NC_Choice(:,i))==0
        fprintf('\nSubject %s (%i) was a flat responder\n',possIDs{i},i);
        continue
    end
    tot = tot + 1;

    keepID_NC{tot}= possIDs{i};
    keepStruct = struct();
    keepStruct.offer = NC_offer(:,i);
    keepStruct.choice = NC_Choice(:,i);
    
    NC_beh(:,tot) = {keepStruct};
    
end



IC_IDs = string(keepID_IC);
NC_IDs = string(keepID_NC);

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

save('DATA_COVID_Round1_IC_noFlat_passAttn_Oct17.mat','s');


