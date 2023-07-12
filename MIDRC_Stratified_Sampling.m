%% Stratified sampling algorithim
% Separate an incoming data batch into open and sequestered using
% stratified sampling
% Author: Natalie Baughan, MIDRC TDP 3d
% Contact: nbaughan@uchicago.edu
% Date: May 2023

%% Read in Data

prompt = 'Copy filepath to input data: ';
filepath = input(prompt,'s');
if isempty(filepath)
    filepath = pwd + "/";
%     Example from my computer:
%     filepath = "/Users/nataliebaughan/MIDRC/Input_Data/";
end

prompt = 'Input filename: ';
filename = input(prompt,'s');

% Verify fields read in with correct data type
inputfile = filepath + string(filename);
opts = detectImportOptions(inputfile);
opts = setvartype(opts, 'submitter_id', 'char');  
opts = setvartype(opts, 'age_at_index', 'double'); 
data = readtable(inputfile, opts);

if endsWith(filename, '.xlsx')
    dateStart = 12;
    dateEnd = 5;
elseif endsWith(filename, '.csv')
    dateStart = 11;
    dateEnd = 4;
end


% Check for duplicates - If warning presents, go to merge batch
ptcount = unique(data.submitter_id);
if length(ptcount) ~= height(data)
    fprintf("WARNING: %d duplicate patients in batch \n",(height(data)-length(ptcount)))
end


%% Clean Data
% sex race ethnicity age_at_index covid19_positive site_id modality

for i = 1:size(data,1)
    if data.sex(i) == ""
        data.sex{i} = 'Not Reported';
    end
    if data.ethnicity(i) == ""
        data.ethnicity{i} = 'Not Reported';
    end
    if data.race(i) == ""
        data.race{i} = 'Not Reported';
    end
    if data.covid19_positive(i) == ""
        data.covid19_positive{i} = 'Not Reported';
    end
    if isnan(data.age_at_index(i)) || isempty(data.age_at_index(i))
        % Note: This assumes blank age entries correspond to patients over
        % 89 years old, these entries are given a "dummy number: so they 
        % are grouped accordingly.
        data.age_at_index(i) = 139; 
    end
end

%% Create site ID variable

data.site_id(:) = "Undefined";

for i = 1:height(data)
    temp = strsplit(data.submitter_id{i},'-');
    data.site_id(i) = string(temp{1});
end

%% Data types (cell --> string)

data.sex = string(data.sex);
data.race = string(data.race);
data.ethnicity = string(data.ethnicity);
data.covid19_positive = string(data.covid19_positive);


%% Add collumn that will contain assigned set labels

if any(ismember(data.Properties.VariableNames,'dataset'))
    data.dataset = [];
    data.dataset(:) = "Unassigned";
else
    data.dataset(:) = "Unassigned";
end

FinalTable = data;

%% Modality

M = groupcounts(data,'modality');
data.CR = contains(data.modality,"CR");
data.CT = contains(data.modality,"CT");
data.DX = contains(data.modality,"DX");
data.MR = contains(data.modality,"MR");

modalityNames = ["CR";"CT";"DX";"MR"];
ModalityCount = [sum(data.CR);sum(data.CT);sum(data.DX);sum(data.MR)];
M1 = table(modalityNames,ModalityCount);
M1 = sortrows(M1,2,'descend');
modalityNames = M1.modalityNames;

%% Separate age into CDC groups
% CDC COVID data uses two sets of age groups: 
% (1) age-groups consistent with those used across CDC COVID-19 surveillance pages
% (2) age groups that are routinely included in NCHS morality reports

% Assume 0-17, 18-29, 30-39, 40-49, 50-64, 65-74, 75-84, 85+
% From https://www.cdc.gov/nchs/nvss/vsrr/covid_weekly/index.htm#SexAndAge
data.agec = zeros(length(data.age_at_index),1);
for i = 1:length(data.age_at_index)
    if data.age_at_index(i) <= 17
        data.agec(i) = 1;
    elseif (data.age_at_index(i) > 17 && data.age_at_index(i) <=29)
        data.agec(i) = 2;
    elseif (data.age_at_index(i) > 29 && data.age_at_index(i) <=39)
        data.agec(i) = 3;
    elseif (data.age_at_index(i) > 39 && data.age_at_index(i) <=49)
        data.agec(i) = 4;
    elseif (data.age_at_index(i) > 49 && data.age_at_index(i) <=64)
        data.agec(i) = 5;
    elseif (data.age_at_index(i) > 64 && data.age_at_index(i) <=74)
        data.agec(i) = 6;
    elseif (data.age_at_index(i) > 74 && data.age_at_index(i) <=84)
        data.agec(i) = 7;
    elseif (data.age_at_index(i) > 84 && data.age_at_index(i) <=140)
        data.agec(i) = 8;
    end
end

%% Grab site information and initialize seed
sites = groupcounts(data, 'site_id');
datasave = data;

% Initialize seed
seed = 10;
rng(seed)

%% Split for each site
percSeq = 0.2;

for x = 1:height(sites)
data = datasave(datasave.site_id == sites.site_id(x),:);

% Gather stats
A = groupcounts(data,'agec');
S = groupcounts(data,'sex');
R = groupcounts(data,'race');
E = groupcounts(data,'ethnicity');
C = groupcounts(data, 'covid19_positive');

% Split 
% Assumes all unique patients
% Separate on C, A, R, G, E, and modality
open = [];
seq = [];
i = 1;
count = zeros(height(C)*height(A)*height(R)*height(S)*height(E),5);
for modality = 1:height(modalityNames)
    % Select all patients with given modality inclusive of multiples
    tempm = data(data.(modalityNames(modality)) == 1,:);
    % Remove these from data such that they are not selected again
    data(data.(modalityNames(modality)) == 1,:) = [];
    for covidgroup = 1:height(C)
        tempc = tempm(tempm.covid19_positive == C.covid19_positive(covidgroup),:);
        for agegroup = 0:max(A.agec) % Accounts for age group zero (not reported)
            temp1 = tempc(tempc.agec == agegroup,:);
            for racegroup = 1:height(R)
                temp2 = temp1(temp1.race == R.race(racegroup),:);
                for sexgroup = 1:height(S)
                    temp3 = temp2(temp2.sex == S.sex(sexgroup),:);
                    for ethnicitygroup = 1:height(E)
                        temp4 = temp3(temp3.ethnicity == E.ethnicity(ethnicitygroup),:);
                        count(i,:) = [height(temp4),agegroup,racegroup,sexgroup,ethnicitygroup];
                        i = i + 1;
                        if size(temp4,1) > 0
                            if size(temp4,1) < 5
                                % Create a list of uniformly distributed random numbers 
                                % [0,1] the length of the number of cases in that strata
                                list = rand(size(temp4,1),1);
                                for n = 1:length(list)
                                    if list(n) > percSeq % If rand(n) >0.2 assign train
                                        open = [open; temp4(n,:)];
                                    else             % If rand(n) <=0.2 assign test
                                        seq = [seq; temp4(n,:)];
                                    end
                                end
                            else
                                rows = size(temp4,1);
                                % Shuffle the order of cases in this strata and than assign
                                % the first 80% to train and the last 20% to test
                                idx = randperm(rows);  
                                open = [open; temp4(idx(1:round(rows*(1-percSeq))),:)];  
                                seq = [seq; temp4(idx(round(rows*(1-percSeq))+1:end),:)];
                            end
                        end
                    end
                end
            end
        end
    end
end

% Write results in Final Table

for i = 1:height(open)
    idx = find(strcmp(FinalTable.submitter_id, open.submitter_id(i)));
    FinalTable.dataset(idx) = "Open";
end

for i = 1:height(seq)
    idx = find(strcmp(FinalTable.submitter_id, seq.submitter_id(i)));
    FinalTable.dataset(idx) = "Seq";
end


end

idx = find(strcmp(FinalTable.dataset, "Unassigned"));
if ~isempty(idx)
    fprintf("Warning: %d patients did not fall in sequestration criteria \n",length(idx))
    fprintf("Assigning to open dataset \n")
    FinalTable.dataset(idx) = "Open";
end

%% Check for duplicate patients

ptcount = unique(FinalTable.submitter_id);
if length(ptcount) ~= height(FinalTable)
    fprintf("WARNING: %d duplicate patients in batch \n",(height(FinalTable)-length(ptcount)))
    count = zeros(height(FinalTable),1);
    for i = 1:height(FinalTable)
        for j = 1:height(FinalTable)
            if strcmp(FinalTable.submitter_id{i},FinalTable.submitter_id{j})
                count(i) = count(i) + 1;
            end
        end
    end
    dupidx = find(count > 1);
    datadup = FinalTable(dupidx,:);
end


%% Write completed file

writetable(FinalTable,"COMPLETED_" + filename(1:end-dateEnd) + ".csv")

%% Write results to data evaluation sheet
% One per batch

    % Filename "MIDRC_sequestration_data_<recieved date>_<site_id>_<date ran>.xlsx"
    evalsheet = "Evaluation_" + filename(1:end-dateEnd) +".xlsx";
    copyfile("Blank_Evaluation_Spreadsheet.xlsx", evalsheet)
    
    InputTable = FinalTable;
    [A,R,S,E,C,M] = CountSeqCategories(InputTable);
    writematrix(A,evalsheet,'Sheet',2,'Range','B5:B13')
    writematrix(R,evalsheet,'Sheet',2,'Range','B15:B21')
    writematrix(S,evalsheet,'Sheet',2,'Range','B23:B26')
    writematrix(E,evalsheet,'Sheet',2,'Range','B28:B30')
    writematrix(C,evalsheet,'Sheet',2,'Range','B32:B34')
    writematrix(M,evalsheet,'Sheet',2,'Range','B36:B39')
    
    open = InputTable(InputTable.dataset == "Open",:);
    [A,R,S,E,C,M] = CountSeqCategories(open);
    writematrix(A,evalsheet,'Sheet',2,'Range','F5:F13')
    writematrix(R,evalsheet,'Sheet',2,'Range','F15:F21')
    writematrix(S,evalsheet,'Sheet',2,'Range','F23:F26')
    writematrix(E,evalsheet,'Sheet',2,'Range','F28:F30')
    writematrix(C,evalsheet,'Sheet',2,'Range','F32:F34')
    writematrix(M,evalsheet,'Sheet',2,'Range','F36:F39')
    
    seq = InputTable(InputTable.dataset == "Seq",:);
    [A,R,S,E,C,M] = CountSeqCategories(seq);
    writematrix(A,evalsheet,'Sheet',2,'Range','J5:J13')
    writematrix(R,evalsheet,'Sheet',2,'Range','J15:J21')
    writematrix(S,evalsheet,'Sheet',2,'Range','J23:J26')
    writematrix(E,evalsheet,'Sheet',2,'Range','J28:J30')
    writematrix(C,evalsheet,'Sheet',2,'Range','J32:J34')
    writematrix(M,evalsheet,'Sheet',2,'Range','J36:J39')



    