
%% Note: please adapt paths and load SPM before
clear

% -------------------------------------------------------------------------
%% Preprocessing Level
% -------------------------------------------------------------------------

DataPath = 'C:/Users/jschraeder/Desktop/emocon/Data/BackwardMask';
subjects = dir(fullfile(DataPath, 's*'));

for i = 1:length(subjects)
   Step1_preproc_DCM_BackwardMask_Julia(subjects(i).name)
end

% -------------------------------------------------------------------------
%% First Level
% -------------------------------------------------------------------------
DataPath = 'C:/Users/jschraeder/Desktop/emocon/Preproc/BackwardMask';
subjects = dir(fullfile(DataPath, 's*'));

for i = 2:10
   Step2_firstlevel_BackwardMask_sub_1_to_sub_16(subjects(i).name)
end

for i = 112:length(subjects)
   Step2_firstlevel_BackwardMask_from_sub_17(subjects(i).name)
end

% -------------------------------------------------------------------------
%% Create Contrasts
% -------------------------------------------------------------------------

% execute Step3_firstlevel_mkConFile_BackwardMask_from_sub_17.m
% execute Step3_firstlevel_mkConFile_BackwardMask_sub_1_to_sub_16.m

% -------------------------------------------------------------------------
%% VOI extraction first 
% -------------------------------------------------------------------------
addpath('C:/Users/jschraeder/Desktop/emocon/Scripts');                  
DataPath = 'C:/Users/jschraeder/Desktop/emocon/FirstLevel/BackwardMask';              
subjects = dir(fullfile(DataPath, 's*'));    


for i = 1:length(subjects)
   Step4_get_VOIs(subjects(i).name)
end
% failed for 'sub-045','sub-054','sub-088','sub-127'

% -------------------------------------------------------------------------
%% DCM Model definition
% -------------------------------------------------------------------------

DataPath = 'C:/Users/jschraeder/Desktop/emocon/FirstLevel/BackwardMask';
subjects = dir(fullfile(DataPath, 's*'));

% delete subjects from subjects matrix 
subjects([36,45,74,110],:) = [];     % 'sub-045','sub-054','sub-088','sub-127'

for i = 1:length(subjects)
   Step5_DCM_modeldefinition(subjects(i).name)
end

