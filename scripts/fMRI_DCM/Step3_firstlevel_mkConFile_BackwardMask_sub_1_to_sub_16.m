
%% Skript to define the condition files for the BackwardMask Paradigm in EmoCon Study %%

function [names, onsets, durations] = Step3_firstlevel_mkConFile_BackwardMask_sub_1_to_sub_16(subName)

root = 'C:/Users/jschraeder/Desktop/emocon';                       % Path to the data
projectfolder = 'C:/Users/jschraeder/Desktop/emocon';               % Path to the projectfolder
logDir = fullfile(root,'Behav_data','Logfiles');                            % Path to the csv data

subjects = dir(fullfile(logDir,'*.csv'));                                   % find subjects with csv file generated during the PsychoPy experiment
subs = length(subjects);                                                    % get number of subjects
csv_names = {subjects(1:subs).name};                                        % extract csv file names
csv_names = csv_names';                                                     % convert 1x3 to 3x1

subNumber = extractAfter(subName, 3);                                       % get number of subjects
Index = find(contains(csv_names,subNumber));                                % find row number of subName in "csv_names"

 
logName = csv_names(Index);                                                 % get specific name of csv file for subName
logName = char(logName);                                                    % convert cell to string


%%Output Directory festlegen  
if ~exist(fullfile(projectfolder,'FirstLevel', 'ConFileFolder',subName))    % generate a outputfolder for the conditions file for every participant
    mkdir(fullfile(projectfolder,'FirstLevel', 'ConFileFolder',subName));
end
outputFolder = fullfile(projectfolder,'FirstLevel','ConFileFolder',subName);% define it as output folder

%% Read in Dataset

fileName = fullfile(logDir,logName);                                        % read in the csv files
fileID = fopen(fileName,'r','n','UTF-8');
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s';

fseek(fileID, 3, 'bof'); %open the file
data = textscan(fileID, formatSpec, 'Delimiter', ';', 'TextType', 'string', 'HeaderLines' ,1, 'ReturnOnError', false, 'EndOfLine', '\r\n'); % delimiter for 61 ",", for other ";"
fclose(fileID);

% Get Onsets
MR_Onset_row = double(data{1,37});                                          % time in seconds for the first MR Trigger is in column 37 row 1
ISI_row = double(data{1,43});                                               % first fixation cross row
ISI_start = ISI_row(3,1);                                                   % the first trial starts in row 3 because the first two rows are example trials
MR_Onset = MR_Onset_row(~isnan(MR_Onset_row));                              % delete NaNs in this row
Primer_Onset_row = str2double(data{1,47});                                  % get times in seconds of target onset
Target_Onset_row = str2double(data{1,51});                                  % get times in seconds of target onset
PrimerTime_row = str2double(data{1,17});                                    % get duration of primer
PrimerTime_row = PrimerTime_row*(1/0.12);

Fixcross_Onset_row = str2double(data{1,43});                                % get onset of fixcross

% Get Stimulus Condition
strPrimer_Emotion = data{1,4};                                              % get primer emotion
strTarget_Emotion = data{1,9};                                              % get target emotion
strMask_Condition = data{1,17};                                             % get mask condition (strongly masked = 0.016 primer duration, weakly masked = 150 primer duration; mask is always 66.7ms long)

% Transform Stimulus Condition from string to number
Primer_Emotion = strrep(strPrimer_Emotion, 'neutral', '1');                 % rename primer neutral = 1
Primer_Emotion = strrep(Primer_Emotion, 'sad', '2');                        % rename primer sad = 2
Primer_Emotion = strrep(Primer_Emotion, 'happy', '3');                      % rename primer happy = 3
Primer_Emotion = str2double(Primer_Emotion);                                % transform Primer information sting to double

Target_Emotion = strrep(strTarget_Emotion, 'neutral', '1');                 % rename target neutral = 1
Target_Emotion = strrep(Target_Emotion, 'sad', '2');                        % rename target sad = 2
Target_Emotion = strrep(Target_Emotion, 'happy', '3');                      % rename target happy = 3
Target_Emotion = str2double(Target_Emotion);                                % transform Target information sting to double

Mask_Condition = str2double(strMask_Condition);                             % transform Mask condition information string to double,           


% Delete first two example rows and NaNs in last row:
Primer_Onset_row([1,2,363],:) = [];
Target_Onset_row([1,2,363],:) = [];
PrimerTime_row([1,2,363],:) = [];
Mask_Condition([1,2,363],:) = [];
Primer_Emotion([1,2,363],:) = [];
Target_Emotion([1,2,363],:) = [];
Fixcross_Onset_row([1,2,363],:) = [];

% Substract Onsets with MR Onset
Target_Onset_row = Target_Onset_row - MR_Onset - 5.4; % discard first three epi images (3x1,8s = 5,4)
Primer_Onset_row = Primer_Onset_row - MR_Onset - 5.4;
Fixcross_Onset_row = Fixcross_Onset_row - MR_Onset- 5.4;


%% Get Onsets

% Condition onset is onset of target. Onsets are taken from the
% Target_Onset_row and depend on the primer, target and mask condition

% Mask Condition = 2 --> strongly masked trial (0.016ms = 2 frames)
% Mask Condition = 18 --> weakly masked trial (150ms = 18 frames)


% onset_target_happy_conscious          = Target_Onset_row(Target_Emotion == 3 & Mask_Condition == 18);
% onset_target_sad_conscious            = Target_Onset_row(Target_Emotion == 2 & Mask_Condition == 18);
% onset_target_neutral_conscious        = Target_Onset_row(Target_Emotion == 1 & Mask_Condition == 18);
% onset_target_happy_unconscious        = Target_Onset_row(Target_Emotion == 3 & Mask_Condition == 2);
% onset_target_sad_unconscious          = Target_Onset_row(Target_Emotion == 2 & Mask_Condition == 2);
% onset_target_neutral_unconscious      = Target_Onset_row(Target_Emotion == 1 & Mask_Condition == 2);


onset_target_conscious          = Target_Onset_row(Mask_Condition == 18);
onset_target_unconscious        = Target_Onset_row(Mask_Condition == 2);
onset_target_happy              = Target_Onset_row(Target_Emotion == 3);
onset_target_sad                = Target_Onset_row(Target_Emotion == 2);
onset_target_neutral            = Target_Onset_row(Target_Emotion == 1);
onset_target                    = Target_Onset_row;

onset_primer = Primer_Onset_row;
onset_intro = 0;
onset_fixcross = Fixcross_Onset_row;

%% Get Durations

duration_primer = PrimerTime_row/1000;                                      % PrimerTime_row is in ms, not in seconds. Therefore divide it with 1000
duration_intro = ISI_start - MR_Onset;                                      % substract the start of the experiment with MR onset to get the duration of the instruction


% for i = length(Fixcross_Onset_row)
%     a{i,:} = double(0.3); 
% end

duration_fixcross = 0.3;
duration_target = 0.3;

%% Create cells for Conditionsfile

% names{1} = 'happy_conscious';                                       
% names{2} = 'sad_conscious';
% names{3} = 'neutral_conscious';
% names{4} = 'happy_unconscious';
% names{5} = 'sad_unconscious';
% names{6} = 'neutral_unconscious'; 

names{1} = 'target_conscious';                                       
names{2} = 'target_unconscious';
names{3} = 'target_happy';
names{4} = 'target_sad';
names{5} = 'target_neutral';
names{6} = 'target'; 

names{7} = 'fixcross'; 
names{8} = 'intro'; 
names{9} = 'primer';                                                      

onsets{1} = onset_target_conscious;                                
onsets{2} = onset_target_unconscious;
onsets{3} = onset_target_happy;
onsets{4} = onset_target_sad;                                
onsets{5} = onset_target_neutral;
onsets{6} = onset_target;
onsets{7} = onset_fixcross;                                
onsets{8} = onset_intro;
onsets{9} = onset_primer;

durations{1} = duration_target;                            
durations{2} = duration_target;
durations{3} = duration_target;
durations{4} = duration_target;
durations{5} = duration_target;
durations{6} = duration_target;
durations{7} = duration_fixcross;
durations{8} = duration_intro;
durations{9} = duration_primer;

save(fullfile(outputFolder,'ConFile_BackwardMask_DCM'), 'names', 'onsets','durations');
end

