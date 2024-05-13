clear all;

DataPath = fullfile('/bif/storage/storage1/projects/emocon/DCM/FirstLevel/BackwardMask');
Subjects = dir(fullfile(DataPath, 's*')); % get subjects


spm_jobman('initcfg');
spm('defaults', 'FMRI');
global defaults;



 for i = 1:2%numel(Subjects)
     PatPath = fullfile(DataPath, Subjects(i).name);
     
%Define contrasts
matlabbatch{1}.spm.stats.con.spmmat = {fullfile(PatPath, 'SPM.mat')};


matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'face';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec = [1 1 1 1 1 1];
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'fixcross';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec = [0 0 0 0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'conscious';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.convec = [1 1 1];
matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'unconscious';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.convec = [0 0 0 1 1 1];
matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'happy';
matlabbatch{1}.spm.stats.con.consess{5}.tcon.convec = [1 0 0 1];
matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'sad';
matlabbatch{1}.spm.stats.con.consess{6}.tcon.convec = [0 1 0 0 1];
matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'neutral';
matlabbatch{1}.spm.stats.con.consess{7}.tcon.convec = [0 0 1 0 0 1];
matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'face>fixcross';
matlabbatch{1}.spm.stats.con.consess{8}.tcon.convec = [1 1 1 1 1 1 -1];
matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = 'conscious>unconscious';
matlabbatch{1}.spm.stats.con.consess{9}.tcon.convec = [1 1 1 -1 -1 -1];
matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{10}.tcon.name = 'fixcross>face';
matlabbatch{1}.spm.stats.con.consess{10}.tcon.convec = [-1 -1 -1 -1 -1 -1 1];
matlabbatch{1}.spm.stats.con.consess{10}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{11}.tcon.name = 'unconscious>conscious';
matlabbatch{1}.spm.stats.con.consess{11}.tcon.convec = [-1 -1 -1 1 1 1];
matlabbatch{1}.spm.stats.con.consess{11}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{12}.tcon.name = 'intro';
matlabbatch{1}.spm.stats.con.consess{12}.tcon.convec = [0 0 0 0 0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{12}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{13}.tcon.name = 'primer';
matlabbatch{1}.spm.stats.con.consess{13}.tcon.convec = [0 0 0 0 0 0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{13}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{14}.fcon.name = 'EOI';
matlabbatch{1}.spm.stats.con.consess{14}.fcon.weights = [1 0 0 0 0 0 0 0 0
                                                        0 1 0 0 0 0 0 0 0
                                                        0 0 1 0 0 0 0 0 0
                                                        0 0 0 1 0 0 0 0 0
                                                        0 0 0 0 1 0 0 0 0
                                                        0 0 0 0 0 1 0 0 0
                                                        0 0 0 0 0 0 1 0 0
                                                        0 0 0 0 0 0 0 1 0
                                                        0 0 0 0 0 0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{14}.fcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{15}.tcon.name = 'all_inputs_one';
matlabbatch{1}.spm.stats.con.consess{15}.tcon.convec = [1 1];
matlabbatch{1}.spm.stats.con.consess{15}.tcon.sessrep = 'none';



matlabbatch{1}.spm.stats.con.delete = 1;


      spm_jobman('run', matlabbatch);
      clear matlabbatch;

  end
