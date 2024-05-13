function Step4_get_VOIs(subName)

%% Adapt paths if necessary!! %%
%%

%addpath('/bif/storage/storage1/projects/emocon/Scripts/DCM');                  


% Define Paths
processing_folder    = 'C:/Users/jschraeder/Desktop/emocon';        % find project folder
script_folder  = 'C:/Users/jschraeder/Desktop/emocon/Scripts';       % find script folder
firstlevel_path = 'C:/Users/jschraeder/Desktop/emocon/FirstLevel/BackwardMask/';  


% Go to project folder
cd (processing_folder)                                                      % go to my project folder
CWD            = pwd;    

% % Create outputpath for every subject 
% if ~exist(fullfile(firstlevel_path, subName), 'dir')                        % create folder for preprocessing files for each participant if this doesnt exist
% mkdir(fullfile(firstlevel_path, subName));
% end

spm('Defaults','fMRI');
spm_jobman('initcfg');
clear matlabbatch

spm_mat_dir = fullfile(firstlevel_path, subName, 'SPM.mat');
amygdala_r_dir = fullfile(script_folder,'rAmy.nii,1');
amygdala_l_dir = fullfile(script_folder,'lAmy.nii,1');

dlPFC_L_mask_dir = fullfile(script_folder, 'lDLPFC.nii,1');
dlPFC_R_mask_dir = fullfile(script_folder, 'rDLPFC.nii,1');


%% Amygdala R

matlabbatch{1}.spm.util.voi.spmmat = {spm_mat_dir};
matlabbatch{1}.spm.util.voi.adjust = 0;
matlabbatch{1}.spm.util.voi.session = 1;
matlabbatch{1}.spm.util.voi.name = 'Amygdala_R';                        
matlabbatch{1}.spm.util.voi.roi{1}.mask.image = {amygdala_r_dir};
matlabbatch{1}.spm.util.voi.roi{1}.mask.threshold = 0.05;
matlabbatch{1}.spm.util.voi.expression = 'i1';


%% Amygdala L

matlabbatch{2}.spm.util.voi.spmmat = {spm_mat_dir};
matlabbatch{2}.spm.util.voi.adjust = 0;
matlabbatch{2}.spm.util.voi.session = 1;
matlabbatch{2}.spm.util.voi.name = 'Amygdala_L';                        
matlabbatch{2}.spm.util.voi.roi{1}.mask.image = {amygdala_l_dir};
matlabbatch{2}.spm.util.voi.roi{1}.mask.threshold = 0.05;
matlabbatch{2}.spm.util.voi.expression = 'i1';



%% dlPFC L

matlabbatch{3}.spm.util.voi.spmmat = {spm_mat_dir};
matlabbatch{3}.spm.util.voi.adjust = 0;
matlabbatch{3}.spm.util.voi.session = 1;
matlabbatch{3}.spm.util.voi.name = 'dlPFC_L';                        
matlabbatch{3}.spm.util.voi.roi{1}.mask.image = {dlPFC_L_mask_dir};
matlabbatch{3}.spm.util.voi.roi{1}.mask.threshold = 0.05;
matlabbatch{3}.spm.util.voi.expression = 'i1';


%% dlPFC R

matlabbatch{4}.spm.util.voi.spmmat = {spm_mat_dir};
matlabbatch{4}.spm.util.voi.adjust = 0;
matlabbatch{4}.spm.util.voi.session = 1;
matlabbatch{4}.spm.util.voi.name = 'dlPFC_R';                        
matlabbatch{4}.spm.util.voi.roi{1}.mask.image = {dlPFC_R_mask_dir};
matlabbatch{4}.spm.util.voi.roi{1}.mask.threshold = 0.05;
matlabbatch{4}.spm.util.voi.expression = 'i1';



%% FFA L 

matlabbatch{5}.spm.util.voi.spmmat = {spm_mat_dir};
matlabbatch{5}.spm.util.voi.adjust = 0;
matlabbatch{5}.spm.util.voi.session = 1;
matlabbatch{5}.spm.util.voi.name = 'FFA_L';                        
% matlabbatch{5}.spm.util.voi.roi{1}.mask.image = {fusiform_l_dir};
% matlabbatch{5}.spm.util.voi.roi{1}.mask.threshold = 0.05;
% define ROI as sphere
matlabbatch{5}.spm.util.voi.roi{1}.sphere.centre = [-38 -54 -18];           % coordinates from contrast: main effect of consciousness --- [-38 -58 -14] coordinates  https://www.researchgate.net/figure/MNI-coordinates-of-face-selective-regions_tbl1_320444099       
matlabbatch{5}.spm.util.voi.roi{1}.sphere.radius = 5;                       % other regions have 5mm sphere too, all regions should have the same size                             
matlabbatch{5}.spm.util.voi.roi{1}.sphere.move.fixed = 1;

matlabbatch{5}.spm.util.voi.expression = 'i1';


%% FFA R

matlabbatch{6}.spm.util.voi.spmmat = {spm_mat_dir};
matlabbatch{6}.spm.util.voi.adjust = 0;
matlabbatch{6}.spm.util.voi.session = 1;
matlabbatch{6}.spm.util.voi.name = 'FFA_R';                        
% matlabbatch{6}.spm.util.voi.roi{1}.mask.image = {fusiform_r_dir};
% matlabbatch{6}.spm.util.voi.roi{1}.mask.threshold = 0.05;
% define ROI as sphere
matlabbatch{6}.spm.util.voi.roi{1}.sphere.centre = [40 -58 -16];            % coordinates form contrast: main effect of consciousness --- [40 -55 -12] coordinates  https://www.researchgate.net/figure/MNI-coordinates-of-face-selective-regions_tbl1_320444099       
matlabbatch{6}.spm.util.voi.roi{1}.sphere.radius = 5;                       % other regions have 5mm sphere too, all regions should have the same size                   
matlabbatch{6}.spm.util.voi.roi{1}.sphere.move.fixed = 1;

matlabbatch{6}.spm.util.voi.expression = 'i1';



%% execute batch
% run created Batch
spm_jobman('run', matlabbatch); 

% print info
fprintf(1, 'VOI extraction for subject %s successful.\n', subName);

% move back to starting directory
cd(CWD);


