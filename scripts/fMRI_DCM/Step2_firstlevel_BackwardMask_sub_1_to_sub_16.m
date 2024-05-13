function [matlabbatch]=Step2_firstlevel_BackwardMask_sub_1_to_sub_16(subName)
%-----------------------------------------------------------------------
% Job saved on 22-Mar-2017 20:39:47 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%% Set Paths
addpath('C:/Users/jschraeder/Desktop/emocon/Scripts');                                      % add path 
projectfolder       = 'C:/Users/jschraeder/Desktop/emocon';                                 % define project folder
subDirPreproc       = fullfile(projectfolder, 'Preproc', 'BackwardMask', subName);                  % define preprocessing folder 
subDirSmooth        = fullfile(subDirPreproc);                                                      % find the smoothed images in the preprocessing folder    
outputFirstlevel    = fullfile(projectfolder,'FirstLevel','BackwardMask', subName);                 % define output folder for FirstLevel analysis

% create folder 
if ~exist(outputFirstlevel, 'dir'); mkdir(outputFirstlevel); end                                    % if this output folder doesnt exist, create one     

% Create mulitple condition files with the mkConfile Function 
Step2_firstlevel_mkConFile_BackwardMask_sub_1_to_sub_16(subName);                                                     % call function to create the condition file for this subject
conditionFile       = fullfile(projectfolder,'FirstLevel','ConFileFolder',subName,'ConFile_BackwardMask_DCM.mat');  % save condition file in the confilefolder

% specify files and arrays: functional images, realignment parameter text file
smoothName         = strcat('swau',subName, '_ses-001_task-BackwardMask_run-001_bold.nii');         % name of my smoothed image
subPreprocFiles    = spm_select('expand', fullfile(subDirSmooth, smoothName));                      % select preprocessed files
realignmentName    = strcat('rp_',subName, '_ses-001_task-BackwardMask_run-001_bold.txt');          % name of the file with realignment parameters
realignmentFile    = spm_select('FPListRec',subDirSmooth,realignmentName);                          % select the realignment file

number_smoothed_EpiFiles = length(subPreprocFiles);                                                 % get number of EPI files 
nessesary_smoothed_epiFiles = cellstr(subPreprocFiles(4:number_smoothed_EpiFiles,:));               % get smoothed images into a cellstring      


%% Fill matlab batch 
matlabbatch{1}.spm.stats.fmri_spec.dir = {outputFirstlevel};                                        % define directory to find preprocessed images
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';                                           % units in seconds
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.8;                                                 % TR is 1.8s
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

matlabbatch{1}.spm.stats.fmri_spec.sess.scans =  cellstr(nessesary_smoothed_epiFiles);              % select functional scans 

%% Regressors
matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {});     % you can also include: , 'tmod', {}, 'pmod', {}, 'orth', {}); if this is in your condition file
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {conditionFile};                                    % select the condition file
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {realignmentFile};                              % select the realignment file

%% high pass filter
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});

%% temporal derivative
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

%% Estimate
%matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(outputFirstlevel,'SPM.mat')};
%matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
%matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%% Run matlabbatch
fprintf(1, 'Created matlabbatch for subject %s.\nMatlabbatch is being executed now.\n', subName);   % print information in matlab window
tStart = tic;    
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);
toc(tStart);

cd(outputFirstlevel);                                                                               % go to the output folder
load('SPM.mat');                                                                                    % load the generated SPM.mat file
SPM = spm_spm(SPM);                                                                                 % run the SPM.mat

% write information in matlab window
fprintf(1, 'First-level analysis for subject %s successful.\n', subName);



