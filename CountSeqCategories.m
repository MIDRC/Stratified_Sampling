function [A,R,S,E,C,M,labels] = CountSeqCategories(InputTable)
% Count Age, Race, Sex, Ethnicity, COVID status, and modality info
% Returns data as 6 arrays with categories and order corresponding to the
% reporting file "MIDRC_sequestration_<site_id>_MM_DD_YY.xlsx"

% Assume 0-17, 18-29, 30-39, 40-49, 50-64, 65-74, 75-84, 85+
A = groupcounts(InputTable,'age_at_index',[0 18 30 40 50 65 75 85 140 1000],'IncludeEmptyGroups',true,'IncludeMissingGroups',true);
labels = string(A.disc_age_at_index);
A = A.GroupCount;

R = [sum(InputTable.race == 'American Indian or Alaska Native');...
    sum(InputTable.race == 'Asian'); sum(InputTable.race == 'Black or African American');...
    sum(InputTable.race == 'Native Hawaiian or other Pacific Islander'); ...
    sum(InputTable.race == 'Not Reported');sum(InputTable.race == 'Other'); ...
    sum(InputTable.race == 'White')];
raceLabels = ["American Indian or Alaska Native";"Asian";"Black or African American";"Native Hawaiian or other Pacific Islander";"Not Reported";"Other";"White"];
labels = cat(1,labels,raceLabels);

S = [sum(InputTable.sex == 'Female'); sum(InputTable.sex == 'Male');...
    sum(InputTable.sex == 'Other'); sum(InputTable.sex == 'Not Reported')];
sexLabels = ["Female";"Male";"Other";"Not Reported"];
labels = cat(1,labels,sexLabels);

E = [sum(InputTable.ethnicity == 'Hispanic or Latino'); ... 
    sum(InputTable.ethnicity == 'Not Hispanic or Latino'); ...
    sum(InputTable.ethnicity == 'Not Reported')];
ethnicityLabels = ["Hispanic or Latino";"Not Hispanic or Latino";"Not Reported"];
labels = cat(1,labels,ethnicityLabels);

C = [sum(InputTable.covid19_positive == 'No'); ...
    sum(InputTable.covid19_positive == 'Not Reported');...
    sum(InputTable.covid19_positive == 'Yes')]; 
covidLabels = ["No";"Not Reported";"Yes"];
labels = cat(1,labels,covidLabels);

M = [sum(InputTable.CR);sum(InputTable.CT);sum(InputTable.DX);sum(InputTable.MR)];
modalityLabels = ["CR";"CT";"DX";"MR"];
labels = cat(1,labels,modalityLabels);

end

