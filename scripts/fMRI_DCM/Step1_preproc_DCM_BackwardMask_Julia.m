function Step1_preproc_DCM_BackwardMask_Julia(subName)
addpath '/bif/storage/storage1/projects/emocon/Scripts'                     % add path of scripts

%define Paths
processing_folder    = '/bif/storage/storage1/projects/emocon/DCM/';        % find project folder
study_folder   = '/bif/storage/storage1/projects/emocon/Data/BIDS';         % find Bids Data
script_folder  = '/bif/storage/storage1/projects/emocon/Scripts/DCM';       % find script folder


%Go to project folder
cd (processing_folder)                                                      % go to my project folder
CWD            = pwd;                                                       % define my project folder as CWD to come back if script is finished

%create Outputpath for every subject 
if ~exist(fullfile(processing_folder, 'Preproc', 'BackwardMask', subName), 'dir')   % create folder for preprocessing files for each participant if this doesnt exist
mkdir(fullfile(processing_folder, 'Preproc', 'BackwardMask', subName));
end
preprocDir = fullfile(processing_folder, 'Preproc', 'BackwardMask', subName);       % define this as my output for the preprocessing files


spm('Defaults','fMRI');
spm_jobman('initcfg');
clear matlabbatch

%select batch with fieldmapping, realignment, coregistration, normalisation
%and smooting
preprocfile    = fullfile(script_folder, 'Step1_Preprocessing_DCM.mat');              % open the preprocessing matlab batch
load(preprocfile);

%% Select epi files
epiPath = fullfile(study_folder,subName,'ses-001', 'func');                 %path with my functional data
epiName = strcat(subName,'_ses-001_task-BackwardMask_run-001_bold.nii');    %name of the file i want to preprocess (niftis from BackwardMask task)
epiZipName = strcat(subName,'_ses-001_task-BackwardMask_run-001_bold.nii.gz'); %name of the file i have to unzip to get my nifti files from BackwardMask task
gunzip(fullfile(epiPath, epiZipName));                                      %unzip Epi images

epiFileArrayAll = spm_select('expand', fullfile(epiPath,epiName));          %selects all EPI files
number_EpiFiles = length(epiFileArrayAll);                                  %get number of EPI files 
nessesary_epiFiles = cellstr(epiFileArrayAll(4:number_EpiFiles,:));         %take all EPI files (change the "1" if you want to exclude the first images, but change this in the firstLevel Script too!!
first_epiFile = cellstr(epiFileArrayAll(4,:));                              %take only the very first EPI for Fieldmap analysis


%% Select anatomy file
anatomyPath = fullfile(study_folder,subName,'ses-001', 'anat');             %path with my anatomic image
anatName = strcat(subName,'_ses-001_run-001_T1w.nii');                      %name of my anatomic image
anatZipName = strcat(subName,'_ses-001_run-001_T1w.nii.gz');                %name of the file i have to unzip to get my anantomic image

gunzip(fullfile(anatomyPath,anatZipName));                                  %unzip the compressed nifti file
anatomyFile= spm_select('ExtFPList', anatomyPath,anatName);                 %select anatomy file

%% Select fieldmap files
greyfieldPath = fullfile(study_folder,subName,'ses-001', 'fmap');           %path of my fieldmap data
cd (greyfieldPath)                                                          %go to the folder with my fieldmap data

filename = strcat(subName,'_ses-001_magnitude1.nii.gz');                    %name of the unziped magnitude file

if isfile(filename)                                                         %if this unzipped file exist, unzip all fieldmap files!
fmapZipName1 = strcat(subName,'_ses-001_magnitude1.nii.gz');
gunzip(fullfile(greyfieldPath,fmapZipName1));                               %unzip magnitude 1 file
fmapZipName2 = strcat(subName,'_ses-001_magnitude2.nii.gz');
gunzip(fullfile(greyfieldPath,fmapZipName2));                               %unzip magnitude 2 file
fmapZipName3 = strcat(subName,'_ses-001_phasediff.nii.gz');
gunzip(fullfile(greyfieldPath,fmapZipName3));                               %unzip phasediff file
end
cd (processing_folder)                                                      %go back to the project folder

magnName = strcat(subName,'_ses-001_magnitude1.nii');                       %name of my magnitude file
magPath = fullfile(greyfieldPath,magnName);                                 %path of my magnitude file
magnitudeFile = spm_select('expand',magPath);                               %select my magnitude file in spm


phaseName = strcat(subName,'_ses-001_phasediff.nii');                       %name of my phasediff file
phasePath = fullfile(greyfieldPath,phaseName);                              %path to my phasediff file
phaseFile = spm_select('expand',phasePath);                                 %select the phasediff file in spm


%% Define Batch Inputs
%Fieldmap
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase     = {phaseFile};                    %select my phasediff file
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = {magnitudeFile};                %select my magnitude file
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.session.epi                   = first_epiFile;                  %take the first epi image
%Realignment
matlabbatch{2}.spm.spatial.realignunwarp.data.scans                               = cellstr(nessesary_epiFiles);    %take the epi files i want
%Slice time correction
%Coregistration
matlabbatch{4}.spm.spatial.coreg.estwrite.source                                  = cellstr(anatomyFile);           %take the anatomic image

%% Move files to Preprocessing Folder %%
matlabbatch{7}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = {preprocDir}; %move files to output folder


%save Batch in preproc Dir
cd(preprocDir)                                                              %go back to my project folder
preproc_filename = sprintf('preproc_%s.mat',subName);                       %name the preprocessing file name (.mat file)
save(preproc_filename, 'matlabbatch')                                       %save the preprocessing as matlab batch

%run created Batch
spm_jobman('run', matlabbatch); 

%move back to starting directory
cd(CWD);

