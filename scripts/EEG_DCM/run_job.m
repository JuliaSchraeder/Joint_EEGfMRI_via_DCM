% pre-processing
clear

script_folder = 'C:\Users\juhoffmann\Desktop\EEG_BIDS\Analysis\DCM'; 
addpath(script_folder)
addpath 'C:\Users\juhoffmann\Desktop\spm12'

jobDir = 'C:\Users\juhoffmann\Desktop\EEG_BIDS\Analysis\DCM';
dataDir = 'C:\Users\juhoffmann\Desktop\EEG_BIDS\01_BackwardMask\edf';
saveDir = 'C:\Users\juhoffmann\Desktop\EEG_BIDS\Analysis\DCM\preproc';
cd(saveDir);
% C = dir(dataDir);
% s = strfind({C.name},'.edf'); ind = single(find(~cellfun(@isempty,s)));
subjects  = dir(fullfile(dataDir, 's*')); 
spm('defaults','eeg');

for i = 1:length(subjects)

    % Convert, Epoch, Average 
    load(fullfile(jobDir,'Batch_01_Convert_Epoch_Average.mat')); %compute phase locking value -> yes
    matlabbatch{1,1}.spm.meeg.convert.dataset = {fullfile(dataDir,subjects(i).name)}; 
    spm_jobman('run',matlabbatch); clear matlabbatch

    % assign default EEG sensors
    load(fullfile(jobDir,'Batch_02_Assign_default_EEG_sensors.mat'));
    n = sprintf('mespmeeg_%s.mat',subjects(i).name(1:end-4)); % name of epoched, averaged and converted eeg file, remove .edf and write .mat instead
    matlabbatch{1,1}.spm.meeg.preproc.prepare.D = {fullfile(saveDir,n)};
    spm_jobman('run',matlabbatch); clear matlabbatch

    % sensors do not work? - change Channels to EEG before sensor
    % definition and not after!
    
    % common average
    load(fullfile(jobDir,'Batch_03_avgref.mat'));
    matlabbatch{1,1}.spm.meeg.preproc.prepare.D = {fullfile(saveDir,n)};
    spm_jobman('run',matlabbatch); clear matlabbatch

    % head model
    load(fullfile(jobDir,'Batch_04_headmodel.mat'));
    m = sprintf('mespmeeg_%s.mat',subjects(i).name(1:end-4));
    matlabbatch{1,1}.spm.meeg.source.headmodel.D = {fullfile(saveDir,m)};
    spm_jobman('run',matlabbatch); clear matlabbatch
end

fprintf('done!!\n');

%% source inversion
clear
jobDir = 'C:/Users/juhoffmann/OneDrive - Uniklinik RWTH Aachen/Auswertung/DCM_EEG';
dataDir = 'C:/Users/juhoffmann/OneDrive - Uniklinik RWTH Aachen/Auswertung/DCM_EEG/preproc';
%saveDir = 'C:/Users/juhoffmann/OneDrive - Uniklinik RWTH Aachen/Auswertung/DCM_EEG/sourceinversion';

cd(dataDir);
subjects  = dir(fullfile(dataDir, 'm*.mat')); %.mat oder .dat?

addpath 'C:\Users\juhoffmann\Desktop\spm12'
spm('defaults','eeg');

for i = 1:10 %length(ind)    
    % separate source inversion
    load(fullfile(jobDir,'Batch_05_sourceinversion.mat'));
    matlabbatch{1,1}.spm.meeg.source.invert.D = {fullfile(dataDir,subjects(i).name)};
    spm_jobman('run',matlabbatch); clear matlabbatch
end



%% inversion results (source)
clear
jobDir = 'C:/Users/juhoffmann/OneDrive - Uniklinik RWTH Aachen/Auswertung/DCM_EEG';
dataDir = 'C:/Users/juhoffmann/OneDrive - Uniklinik RWTH Aachen/Auswertung/DCM_EEG/preproc';
%saveDir = 'C:/Users/juhoffmann/OneDrive - Uniklinik RWTH Aachen/Auswertung/DCM_EEG/sourceinversion';

cd(dataDir);
subjects  = dir(fullfile(dataDir, 'm*.mat')); 

addpath 'C:\Users\juhoffmann\Desktop\spm12'
spm('defaults','eeg');

for i = 1:10
    % 
    load(fullfile(jobDir,'Batch_06_inversionresults.mat'));
    matlabbatch{1,1}.spm.meeg.source.results.D = {fullfile(dataDir,subjects(i).name)};
    matlabbatch{1,1}.spm.meeg.source.results.woi = [150 200]; % time window of interest             %% Welche Zeiten?! N170 Zeiten
    matlabbatch{1,1}.spm.meeg.source.results.foi = [0 250]; % frequency window of interest
    matlabbatch{1,1}.spm.meeg.source.results.ctype = 'evoked';
    spm_jobman('run',matlabbatch); clear matlabbatch
end





%% convert to images (sensor space)
clear
jobDir = 'C:/Users/juhoffmann/OneDrive - Uniklinik RWTH Aachen/Auswertung/DCM_EEG';
dataDir = 'C:/Users/juhoffmann/OneDrive - Uniklinik RWTH Aachen/Auswertung/DCM_EEG/preproc';

cd(dataDir);
subjects  = dir(fullfile(dataDir, 'm*.mat')); 

addpath 'C:\Users\juhoffmann\Desktop\spm12'
spm('defaults','eeg');

for i=1:10
    D{i} = {fullfile(dataDir,subjects(i).name)};     
    
    clear matlabbatch
    load('C:/Users/juhoffmann/OneDrive - Uniklinik RWTH Aachen/Auswertung/DCM_EEG/convert2image.mat');
    
    % EEG file
    matlabbatch{1,1}.spm.meeg.images.convert2images.D = D{i};
    matlabbatch{1,1}.spm.meeg.images.convert2images.timewin = [150 200];
    matlabbatch{1,1}.spm.meeg.images.convert2images.freqwin = [0 250];
    
    % run
    spm_jobman('run',matlabbatch);
end
fprintf('.. done !!\n');



%% make factorial cells                                                     
% put factor design mat to the workspace
clear
dataDir = 'C:/Users/juhoffmann/OneDrive - Uniklinik RWTH Aachen/Auswertung/DCM_EEG/preproc';
subjects  = dir(fullfile(dataDir, 'm*.mat')); 

addpath 'C:\Users\juhoffmann\Desktop\spm12'
spm('defaults','eeg');

clear D1 D2 
for i=1:10
    dataDir_2 = strcat('sensor_space', subjects(i).name(1:end-4));
    D1(i) = {fullfile(dataDir, dataDir_2,'condition_strong.nii,1')}; 
    D2(i) = {fullfile(dataDir, dataDir_2,'condition_weak.nii,1')}; 
end

% matlabbatch{1,1}.spm.stats.factorial_design.des.t2.scans1 = D2';
% matlabbatch{1,1}.spm.stats.factorial_design.des.t2.scans2 = D3';
matlabbatch{1,1}.spm.stats.factorial_design.des.anova.icell(1).scans = D1';
matlabbatch{1,1}.spm.stats.factorial_design.des.anova.icell(2).scans = D2';
