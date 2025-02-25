%-----------------------------------------------------------------------
%% Find FirstLevel Contrasts
clear  
%cwd = pwd;
base = 'I:/Analysis/DCM_fMRI/';
data = fullfile(base,'FirstLevel/BackwardMask/');      


% HC excluded participants: sub-005,sub-013, sub-016, sub-058, sub-063, sub-101, sub-105 (movement), sub-078 (checked 25.09.2023) 05.04.24
% ->,'sub-017',,'sub-045','sub-054','sub-088','sub-127'
% MDD excluded participants: sub-020, sub-042, sub-094 (movement), sub-060, sub-061(checked 25.09.2023)

Subjects = {'sub-004','sub-006','sub-010','sub-011','sub-014','sub-015','sub-018','sub-019','sub-021','sub-022','sub-024','sub-025'...
,'sub-027','sub-028','sub-029','sub-030','sub-031','sub-032','sub-033','sub-034','sub-041','sub-043','sub-046','sub-047','sub-050','sub-051'...
,'sub-052','sub-053','sub-055','sub-056','sub-057','sub-059','sub-062','sub-068','sub-069','sub-070','sub-071','sub-073','sub-074','sub-079'...
,'sub-080','sub-083','sub-085','sub-086','sub-089','sub-090','sub-091','sub-093','sub-096','sub-103','sub-119','sub-123'...
,'sub-125','sub-126'...
,'sub-007','sub-008','sub-009','sub-012','sub-026','sub-035','sub-036','sub-037','sub-038','sub-039','sub-040','sub-044','sub-048'...
,'sub-049','sub-064','sub-065','sub-066','sub-067','sub-072','sub-075','sub-076','sub-077','sub-081','sub-082','sub-084','sub-087','sub-092'...
,'sub-095','sub-097','sub-098','sub-099','sub-100','sub-102','sub-104','sub-106','sub-107','sub-108','sub-109','sub-110','sub-111','sub-112','sub-113','sub-114'...
,'sub-115','sub-116','sub-117','sub-118','sub-120','sub-121','sub-122','sub-124','sub-128','sub-129','sub-130','sub-131'};

for i = 1:numel(Subjects)    
    iSessionOrder = 1;
    subName = Subjects{i}; 
    j = 1;
        	for k = 1:24 %number of models
                matlabbatch{1,1}.spm.dcm.bms.inference.sess_dcm{1,i}(1,iSessionOrder).dcmmat{k, 1}...
                = sprintf('I:/Analysis/DCM_fMRI/FirstLevel/BackwardMask/%s/DCM_model_%02d_of_24.mat', subName, k);
            end
end

results = fullfile(base,"results/BMS/All/");
matlabbatch{1}.spm.dcm.bms.inference.dir = cellstr(results); 
matlabbatch{1}.spm.dcm.bms.inference.model_sp = {''};
matlabbatch{1}.spm.dcm.bms.inference.load_f = {''};
matlabbatch{1}.spm.dcm.bms.inference.method = 'FFX';
matlabbatch{1}.spm.dcm.bms.inference.family_level.family(1).family_name = 'Bottom_Up';
matlabbatch{1}.spm.dcm.bms.inference.family_level.family(1).family_models = [1
                                                                            2
                                                                            3
                                                                            4
                                                                            5
                                                                            6
                                                                            7
                                                                            8];
matlabbatch{1}.spm.dcm.bms.inference.family_level.family(2).family_name = 'Top_Down';
matlabbatch{1}.spm.dcm.bms.inference.family_level.family(2).family_models = [9
                                                                            10
                                                                            11
                                                                            12
                                                                            13
                                                                            14
                                                                            15
                                                                            16];
matlabbatch{1}.spm.dcm.bms.inference.family_level.family(3).family_name = 'Mix';
matlabbatch{1}.spm.dcm.bms.inference.family_level.family(3).family_models = [17
                                                                            18
                                                                            19
                                                                            20
                                                                            21
                                                                            22
                                                                            23
                                                                            24];
matlabbatch{1}.spm.dcm.bms.inference.bma.bma_yes.bma_all = 'famwin';
matlabbatch{1}.spm.dcm.bms.inference.verify_id = 1;

% Save created Batch
cd(results)
save('DCM_24_Models_BMS_All', 'matlabbatch');

% Run created Batch
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

%cd(cwd)