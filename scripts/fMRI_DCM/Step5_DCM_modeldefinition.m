function DCM_modeldefinition(subName)

CWD            = pwd;
study_folder   = 'C:/Users/jschraeder/Desktop/emocon';
%script_folder  = '/bif/projects/emocon/Scripts';
sub_folder     = fullfile(study_folder,'FirstLevel','BackwardMask', subName);
SPM_file       = fullfile(sub_folder, 'SPM.mat');
VOIfiles       = {'VOI_FFA_R_1.mat', 'VOI_FFA_L_1.mat', 'VOI_dlPFC_R_1.mat', 'VOI_dlPFC_L_1.mat','VOI_Amygdala_L_1.mat','VOI_Amygdala_R_1.mat'};

tmp         = struct('xyz',[],'name','','Ic',[],'Sess',[],'def','','spec',[],...
                 'str','','XYZmm',[],'X0',[],'y',[],'u',[],'v',[],'s',[]);
options     = struct('nonlinear',0,'two_state',0,'stochastic',0,'centre',0,'endogenous',0,'nograph',1);
DCM         = struct('a',[],'b',[],'c',[],'d',[],'U',[],'Y',[],'xY',tmp,'v',[],'n',[],...
                 'TE',[],'delays',[],'options',options);
clear('tmp','options');

load(SPM_file);


% Load VOIs
for reg=1:length(VOIfiles)
    load(fullfile(sub_folder,VOIfiles{reg}));
    DCM.xY(reg)     = xY;
    DCM.Y.y(:,reg)  = DCM.xY(reg).u;
    DCM.Y.name{reg} = DCM.xY(reg).name;
    clear('Y','xY');
end


DCM.delays     = [0.9 0.9 0.9 0.9 0.9 0.9]';    % halbe TR  (time to repeat)                               
DCM.n          = length(DCM.xY);                % length VOIs
DCM.v          = length(DCM.xY(1).u);           % length images (852)

DCM.Y.dt       = SPM.xY.RT;         % TR
DCM.Y.X0       = DCM.xY(1).X0;      % highpass filter

DCM.Y.Q        = spm_Ce(ones(1,DCM.n)*DCM.v); % Varianzkomponenten

% Define which inputs to include
DCM.U.dt       =  SPM.Sess(1).U(1).dt;
DCM.U.name     = [SPM.Sess(1).U.name]; % name of inputs
DCM.U.u        = [SPM.Sess(1).U(1).u(33:end,1) ...  % U(1) = target_conscious                            % ersten 32 werden für DCM gelöscht
                  SPM.Sess(1).U(2).u(33:end,1)];    % U(2) = target_unconscious

DCM.TE         = 0.028;         % TE in s (time to echo)

DCM.options.nonlinear  = 0;
DCM.options.two_state  = 0;
DCM.options.stochastic = 0;
DCM.options.centre     = 0;
DCM.options.endogenous = 0;
DCM.options.nograph    = 0;


%a         = ones(6);            % matrix with 6x6 ones (fixed connections)
%b         = zeros(6,6,2);                                                   % last number is number of inputs
%c         = [1 1; 1 1; 1 1; 1 1; 1 0; 1 0];                                 % % 6 rows for 6 VOIs, 2 values for 2 inputs  % last numer is number of inputs, first number is number of VOIS% thilos script: zeros(6,2);         
%d         = zeros(6,6); 

% A-Matrix: statische Konnektivität
% B-Matrix: modulatorische Einflüsse der Task effects (Input)
% C-Matrix: Task effect (Input) auf eine bestimmte ROI
% D-Matrix: modulatorische Einflüsse von ROI auf Verbindung zwischen zwei ROIs


%% Create models

% B-Matrix für jeden Input generieren

%      von: Amy L, Amyl R, FFA L, FFA R, dlPFC L, dlPFC R
% nach:
% Amy L 
% Amy R
% FFA L
% FFA R
% dlPFC L
% dlPFC R

% C-Matrix
%           Input 1 (conscious), Input 2 (unconscious)
% Amy L 
% Amy R
% FFA L
% FFA R
% dlPFC L
% dlPFC R

% A- Matrix mit Interhemispherischen Verbindungen 
a               = [1	1	1	0	1	0
1	1	0	1	0	1
1	0	1	1	1	0
0	1	1	1	0	1
1	0	1	0	1	1
0	1	0	1	1	1];
% ohne interhemisphärische Verbindungen zuzulassen
a_2             = [1	0	1	0	1	0
0	1	0	1	0	1
1	0	1	0	1	0
0	1	0	1	0	1
1	0	1	0	1	0
0	1	0	1	0	1];

% C-Matrix (6 rows for 6 VOIs, 2 values for 2 inputs)
c_input_amy_amy = [1 1; 1 1; 0 0; 0 0; 0 0; 0 0];   % input 1 in amygdala, input 2 in amygdala
c_input_FFA_amy = [0 1; 0 1; 1 0; 1 0; 0 0; 0 0];   % input 1 in FFA, input 2 in amygdala
c_input_PFC_amy = [0 1; 0 1; 0 0; 0 0; 1 0; 1 0];   % input 1 in dlPFC, input 2 in amygdala


b         = zeros(6,6,2);
c         = zeros(6,2);
d         = zeros(6,6,0);


%% Bottom-Up Family 

% model(1).a         = a;
% model(1).b(:,:,1)  = zeros(6,6);
% model(1).b(:,:,2)  = zeros(6,6);
% model(1).c         = c_input_amy_amy; 
% model(1).d         = d;

% mit interhemisphären connection
model(1).a         = a;
model(1).b(:,:,1)  = [1	1	0	0	0	0
1	1	0	0	0	0
1	0	1	1	0	0
0	1	1	1	0	0
1	0	1	0	1	1
0	1	0	1	1	1]; 
model(1).b(:,:,2)  = [1	1	0	0	0	0
1	1	0	0	0	0
1	0	1	1	0	0
0	1	1	1	0	0
1	0	1	0	1	1
0	1	0	1	1	1]; 
model(1).c         = c_input_amy_amy; 
model(1).d         = d;

model(2).a         = a;
model(2).b(:,:,1)  = [0	0	0	0	0	0
0	0	0	0	0	0
0	0	1	1	0	0
0	0	1	1	0	0
0	0	1	0	1	1
0	0	0	1	1	1]; 
model(2).b(:,:,2)  = [1	1	0	0	0	0
1	1	0	0	0	0
1	0	1	1	0	0
0	1	1	1	0	0
1	0	1	0	1	1
0	1	0	1	1	1]; 
model(2).c         = c_input_FFA_amy;
model(2).d         = d;

% ohne interhemisphären connection
model(3).a         = a_2;
model(3).b(:,:,1)  = [1	0	0	0	0	0
0	1	0	0	0	0
1	0	1	0	0	0
0	1	0	1	0	0
1	0	1	0	1	0
0	1	0	1	0	1];
model(3).b(:,:,2)  = [1	0	0	0	0	0
0	1	0	0	0	0
1	0	1	0	0	0
0	1	0	1	0	0
1	0	1	0	1	0
0	1	0	1	0	1];
model(3).c         = c_input_amy_amy;
model(3).d         = d;

model(4).a         = a_2;
model(4).b(:,:,1)  = [0	0	0	0	0	0
0	0	0	0	0	0
0	0	1	0	0	0
0	0	0	1	0	0
0	0	1	0	1	0
0	0	0	1	0	1];
model(4).b(:,:,2)  = [1	0	0	0	0	0
0	1	0	0	0	0
1	0	1	0	0	0
0	1	0	1	0	0
1	0	1	0	1	0
0	1	0	1	0	1];
model(4).c         = c_input_FFA_amy;
model(4).d         = d;


% ohne  Amygdala - FFA connection
% mit interhemisphären connection
model(5).a         = a;
model(5).b(:,:,1)  = [1	1	0	0	0	0
1	1	0	0	0	0
0	0	1	1	0	0
0	0	1	1	0	0
1	0	1	0	1	1
0	1	0	1	1	1]; % effect of input 1 on connections (6x6 matrix, 6 VOIS)
model(5).b(:,:,2)  = [1	1	0	0	0	0
1	1	0	0	0	0
0	0	1	1	0	0
0	0	1	1	0	0
1	0	1	0	1	1
0	1	0	1	1	1]; % effect of input 2 on connections
model(5).c         = c_input_amy_amy; 
model(5).d         = d;

model(6).a         = a;
model(6).b(:,:,1)  = [0	0	0	0	0	0
0	0	0	0	0	0
0	0	1	1	0	0
0	0	1	1	0	0
0	0	1	0	1	1
0	0	0	1	1	1]; 
model(6).b(:,:,2)  = [1	1	0	0	0	0
1	1	0	0	0	0
0	0	1	1	0	0
0	0	1	1	0	0
1	0	1	0	1	1
0	1	0	1	1	1]; 
model(6).c         = c_input_FFA_amy;
model(6).d         = d;

% ohne interhemisphären connection
model(7).a         = a_2;
model(7).b(:,:,1)  = [1	0	0	0	0	0
0	1	0	0	0	0
0	0	1	0	0	0
0	0	0	1	0	0
1	0	1	0	1	0
0	1	0	1	0	1];
model(7).b(:,:,2)  = [1	0	0	0	0	0
0	1	0	0	0	0
0	0	1	0	0	0
0	0	0	1	0	0
1	0	1	0	1	0
0	1	0	1	0	1];
model(7).c         = c_input_amy_amy;
model(7).d         = d;

model(8).a         = a_2;
model(8).b(:,:,1)  = [0	0	0	0	0	0
0	0	0	0	0	0
0	0	1	0	0	0
0	0	0	1	0	0
0	0	1	0	1	0
0	0	0	1	0	1];
model(8).b(:,:,2)  = [1	0	0	0	0	0
0	1	0	0	0	0
0	0	1	0	0	0
0	0	0	1	0	0
1	0	1	0	1	0
0	1	0	1	0	1];
model(8).c         = c_input_FFA_amy;
model(8).d         = d;



%% Top-Down Family

% mit interhemisphären connection
model(9).a         = a;
model(9).b(:,:,1)  = [1	1	1	0	1	0
1	1	0	1	0	1
0	0	1	1	1	0
0	0	1	1	0	0
0	0	0	0	1	1
0	0	0	0	1	1]; 
model(9).b(:,:,2)  = [1	1	0	0	0	0
1	1	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0]; 
model(9).c         = c_input_PFC_amy; 
model(9).d         = d;

model(10).a         = a;
model(10).b(:,:,1)  = [1	1	1	0	1	0
1	1	0	1	0	1
0	0	1	1	1	0
0	0	1	1	0	1
0	0	1	0	1	1
0	0	0	1	1	1]; 
model(10).b(:,:,2)  = [1	1	0	0	0	0
1	1	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0]; 
model(10).c         = c_input_FFA_amy;
model(10).d         = d;

% ohne interhemisphären connection
model(11).a         = a_2;
model(11).b(:,:,1)  = [1	0	1	0	1	0
0	1	0	1	0	1
0	0	1	0	1	0
0	0	0	1	0	0
0	0	0	0	1	0
0	0	0	0	0	1];
model(11).b(:,:,2)  = [1	0	0	0	0	0
0	1	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0];
model(11).c         = c_input_PFC_amy;
model(11).d         = d;

model(12).a         = a_2;
model(12).b(:,:,1)  = [1	0	1	0	1	0
0	1	0	1	0	1
0	0	1	0	1	0
0	0	0	1	0	1
0	0	1	0	1	0
0	0	0	1	0	1];
model(12).b(:,:,2)  = [1	0	0	0	0	0
0	1	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0];
model(12).c         = c_input_FFA_amy;
model(12).d         = d;

% ohne Amygdala - FFA connection
% mit interhemisphären connection
model(13).a         = a;
model(13).b(:,:,1)  = [1	1	0	0	1	0
1	1	0	0	0	1
0	0	1	1	1	0
0	0	1	1	0	0
0	0	0	0	1	1
0	0	0	0	1	1]; 
model(13).b(:,:,2)  = [1	1	0	0	0	0
1	1	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0]; 
model(13).c         = c_input_PFC_amy; 
model(13).d         = d;

model(14).a         = a;
model(14).b(:,:,1)  = [1	1	0	0	1	0
1	1	0	0	0	1
0	0	1	1	1	0
0	0	1	1	0	1
0	0	1	0	1	1
0	0	0	1	1	1]; 
model(14).b(:,:,2)  = [1	1	0	0	0	0
1	1	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0]; 
model(14).c         = c_input_FFA_amy;
model(14).d         = d;

% ohne interhemisphären connection
model(15).a         = a_2;
model(15).b(:,:,1)  = [1	0	0	0	1	0
0	1	0	0	0	1
0	0	1	0	1	0
0	0	0	1	0	0
0	0	0	0	1	0
0	0	0	0	0	1];
model(15).b(:,:,2)  = [1	0	0	0	0	0
0	1	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0];
model(15).c         = c_input_PFC_amy;
model(15).d         = d;

model(16).a         = a_2;
model(16).b(:,:,1)  = [1	0	0	0	1	0
0	1	0	0	0	1
0	0	1	0	1	0
0	0	0	1	0	1
0	0	1	0	1	0
0	0	0	1	0	1];
model(16).b(:,:,2)  = [1	0	0	0	0	0
0	1	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0
0	0	0	0	0	0];
model(16).c         = c_input_FFA_amy;
model(16).d         = d;


%% Mix Family

% mit interhemisphären connection
model(17).a         = a;
model(17).b(:,:,1)  = [1	1	1	0	1	0
1	1	0	1	0	1
0	0	1	1	1	0
0	0	1	1	0	1
1	0	0	0	1	1
0	1	0	0	1	1];
model(17).b(:,:,2)  = [1	1	0	0	1	0
1	1	0	0	0	1
1	0	1	1	0	0
0	1	1	1	0	0
1	0	1	0	1	1
0	1	0	1	1	1];
model(17).c         = c_input_PFC_amy; 
model(17).d         = d;

model(18).a         = a;
model(18).b(:,:,1)  = [1	1	1	0	1	0
1	1	0	1	0	1
0	0	1	1	1	0
0	0	1	1	0	1
1	0	1	0	1	1
0	1	0	1	1	1]; 
model(18).b(:,:,2)  = [1	1	1	0	1	0
1	1	0	1	0	1
0	0	1	1	1	0
0	0	1	1	0	1
1	0	1	0	1	1
0	1	0	1	1	1]; 
model(18).c         = c_input_FFA_amy;
model(18).d         = d;

% ohne interhemisphären connection
model(19).a         = a_2;
model(19).b(:,:,1)  = [1	0	1	0	1	0
0	1	0	1	0	1
0	0	1	0	1	0
0	0	0	1	0	1
1	0	0	0	1	0
0	1	0	0	0	1];
model(19).b(:,:,2)  = [1	0	0	0	1	0
0	1	0	0	0	1
1	0	1	0	0	0
0	1	0	1	0	0
1	0	1	0	1	0
0	1	0	1	0	1];
model(19).c         = c_input_PFC_amy;
model(19).d         = d;

model(20).a         = a_2;
model(20).b(:,:,1)  = [1	0	1	0	1	0
0	1	0	1	0	1
0	0	1	0	1	0
0	0	0	1	0	1
1	0	1	0	1	0
0	1	0	1	0	1];
model(20).b(:,:,2)  = [1	0	1	0	1	0
0	1	0	1	0	1
0	0	1	0	1	0
0	0	0	1	0	1
1	0	1	0	1	0
0	1	0	1	0	1
];
model(20).c         = c_input_FFA_amy;
model(20).d         = d;

% ohne Amygdala - FFA connection
% mit interhemisphären connection
model(21).a         = a;
model(21).b(:,:,1)  = [1	1	0	0	1	0
1	1	0	0	0	1
0	0	1	1	1	0
0	0	1	1	0	1
1	0	0	0	1	1
0	1	0	0	1	1];
model(21).b(:,:,2)  = [1	1	0	0	1	0
1	1	0	0	0	1
0	0	1	1	0	0
0	0	1	1	0	0
1	0	1	0	1	1
0	1	0	1	1	1];
model(21).c         = c_input_PFC_amy; 
model(21).d         = d;

model(22).a         = a;
model(22).b(:,:,1)  = [1	1	0	0	1	0
1	1	0	0	0	1
0	0	1	1	1	0
0	0	1	1	0	1
1	0	1	0	1	1
0	1	0	1	1	1]; 
model(22).b(:,:,2)  = [1	1	0	0	1	0
1	1	0	0	0	1
0	0	1	1	1	0
0	0	1	1	0	1
1	0	1	0	1	1
0	1	0	1	1	1]; 
model(22).c         = c_input_FFA_amy;
model(22).d         = d;

% ohne interhemisphären connection
model(23).a         = a_2;
model(23).b(:,:,1)  = [1	0	0	0	1	0
0	1	0	0	0	1
0	0	1	0	1	0
0	0	0	1	0	1
1	0	0	0	1	0
0	1	0	0	0	1];
model(23).b(:,:,2)  = [1	0	0	0	1	0
0	1	0	0	0	1
0	0	1	0	0	0
0	0	0	1	0	0
1	0	1	0	1	0
0	1	0	1	0	1];
model(23).c         = c_input_PFC_amy;
model(23).d         = d;

model(24).a         = a_2;
model(24).b(:,:,1)  = [1	0	0	0	1	0
0	1	0	0	0	1
0	0	1	0	1	0
0	0	0	1	0	1
1	0	1	0	1	0
0	1	0	1	0	1];
model(24).b(:,:,2)  = [1	0	0	0	1	0
0	1	0	0	0	1
0	0	1	0	1	0
0	0	0	1	0	1
1	0	1	0	1	0
0	1	0	1	0	1];
model(24).c         = c_input_FFA_amy;
model(24).d         = d;

%% Save models

DCM_raw       = DCM;

cd(sub_folder);

% save every generated model in .mat file
for i=1:length(model)
    DCM.a      = model(i).a;
    DCM.b      = model(i).b;
    DCM.c      = model(i).c;
    DCM.d      = model(i).d;
    if (~isempty(DCM.d))
       DCM.options.nonlinear  = 1; % falls man noch D-Matrix hinzufügen möchte, muss man ein nicht lineares Model annehmen
    end
    DCMfilename = sprintf('DCM_model_%02d_of_24.mat',i);
    DCM         = spm_dcm_estimate(DCM); % estimate DCM
    save(DCMfilename, 'DCM');
    DCM         = DCM_raw;
end

cd(CWD);
