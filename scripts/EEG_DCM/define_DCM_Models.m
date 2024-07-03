function define_DCM_Models(subData, model)
%clear  
%subData = 'mespmeeg_sub-027_BackwardMask_Preprocessed.mat';
%model = 1;

%spm('defaults','EEG');

% Data and analysis directories
%--------------------------------------------------------------------------

subName = subData(10:16); 
Pbase     = 'C:\Users\juhoffmann\Desktop\EEG_BIDS\Analysis\DCM'; 


% Output Directory
if ~exist(fullfile(Pbase,'firstlevel',subName))                             % generate a outputfolder for the DCMs for every participant
    mkdir(fullfile(Pbase,'firstlevel',subName));
end
Panalysis = fullfile(Pbase,'firstlevel',subName);                           % define it as output folder
Pdata     = fullfile(Pbase,'sourceinversion', subData);                     % data directory in Pbase

% % if model is already estimated, dont do it again
% if exist(fullfile(Panalysis,sprintf('DCM_model_%02d_of_24_%s.mat',model,subName)),'file')
%     return;
% end

fprintf('Processing %s with model %d\n', subData, model);
% Data filename
%--------------------------------------------------------------------------
DCM.xY.Dfile = Pdata;

% Parameters and options used for setting up model
%--------------------------------------------------------------------------
DCM.options.analysis = 'ERP'; % analyze evoked responses
DCM.options.model    = 'ERP'; % ERP model
DCM.options.spatial  = 'ECD'; % spatial model                               % equivalent current dipole (ECD) for each source or applying a patch on the cortical surface (IMG);

DCM.options.trials   = [1 2]; % index of ERPs within ERP/ERF file
DCM.options.Tdcm(1)  = 0;     % start of peri-stimulus time to be modelled relative to the stimulus onset. 
DCM.options.Tdcm(2)  = 200;   % end of peri-stimulus time to be modelled  relative to the stimulus onset. 
DCM.options.Nmodes   = 8;     % nr of modes for data selection
DCM.options.h        = 1;     % nr of DCT components This sets the number of Discrete Cosine Transform (DCT) components to use for detrending the data. A value of 1 implies a minimal amount of detrending.
DCM.options.onset    = 50;    % selection of onset (prior mean)             It indicates an expectation that the neural response starts around 50 milliseconds after the stimulus. This value is used in the model to help estimate the actual onset time.
DCM.options.D        = 1;     % downsampling
DCM.options.han      = 0;     % no windowing (hanning)                      % reduce the influence of the beginning and end of  the timeseries
DCM.options.multiC   = 1;     % alow multiple Conditions

%--------------------------------------------------------------------------
% Data and spatial model
%--------------------------------------------------------------------------
DCM  = spm_dcm_erp_data(DCM);

%--------------------------------------------------------------------------
% Location priors for dipoles
%--------------------------------------------------------------------------

% same ROIS as fMRI DCM!
DCM.Lpos  = [[-18; -4; -16] [22; -2; -14] [-38; -54; -18] [40; -58; -16] [-36; 16; 40] [34; 26; 40]];
DCM.Sname = {'Amygdala_L'; 'Amygdala_R'; 'FFA_L'; 'FFA_R'; 'dlPFC_L'; 'dlPFC_R'};
Nareas    = size(DCM.Lpos,2);

%--------------------------------------------------------------------------
% Spatial model
%--------------------------------------------------------------------------
DCM = spm_dcm_erp_dipfit(DCM);

%--------------------------------------------------------------------------
% Specify connectivity model
%--------------------------------------------------------------------------
cd(Panalysis)

DCM.A{1} = zeros(Nareas, Nareas);               % forward connections
DCM.A{2} = zeros(Nareas,Nareas);                % backward connections
DCM.A{3} = zeros(Nareas,Nareas);                % lateral connections

% forward connection
DCM.A{1} = [0	0	0	0	0	0
            0	0	0	0	0	0
            1	0	0	0	0	0
            0	1	0	0	0	0
            1	0	1	0	0	0
            0	1	0	1	0	0];
% backward connection
DCM.A{2} = [0	0	1	0	1	0
            0	0	0	1	0	1
            0	0	0	0	1	0
            0	0	0	0	0	1
            0	0	0	0	0	0
            0	0	0	0	0	0];
% lateral connections only for half of the model 
if (model == 3) || (model == 4) || (model == 7) || (model == 8)  ||  (model == 11) || (model == 12) || (model == 15) || (model == 16) || (model == 19) || (model == 20) || (model == 23) || (model == 24) 
    DCM.A{3} = zeros(Nareas,Nareas);  
else % für model 1,2 5,6 9,10 13,14 17,18 21,22 lateralen verbindungen annehmen
    DCM.A{3} = [0	1	0	0	0	0
                1	0	0	0	0	0
                0	0	0	1	0	0
                0	0	1	0	0	0
                0	0	0	0	0	1
                0	0	0	0	1	0];
end

%--------------------------------------------------------------------------
% Modulation effects definition
%--------------------------------------------------------------------------

% DCM.B{1,1} = eye(6) + DCM.A{1} + DCM.A{2} + DCM.A{3};    % allow self connection and add forward/lateral/back A Matrix

% % keine Amydgala/FFA modulation in manchen modellen
% if (model == 2) || (model == 4) || (model == 6) || (model == 8) ||  (model == 10) || (model == 12) || (model == 14) || (model == 16) || (model == 18) || (model == 20) || (model == 22) || (model == 24) 
%     %(row,column)
%     DCM.B{1,1}(1,3) = 0;
%     DCM.B{1,1}(2,4) = 0;
%     DCM.B{1,1}(3,1) = 0;
%     DCM.B{1,1}(4,2) = 0;
% end
% 
% DCM.B{1,2} = DCM.B{1,1};

%% Bottom-Up Family 

if model == 1
    % mit interhemisphären connection
    DCM.B{1,1} =  [1	1	0	0	0	0
1	1	0	0	0	0
1	0	1	1	0	0
0	1	1	1	0	0
1	0	1	0	1	1
0	1	0	1	1	1]; 
elseif model == 2 
    DCM.B{1,1}  = [0	0	0	0	0	0
0	0	0	0	0	0
0	0	1	1	0	0
0	0	1	1	0	0
0	0	1	0	1	1
0	0	0	1	1	1]; 
elseif model == 3
    % ohne interhemisphären connection
    DCM.B{1,1} = [1	0	0	0	0	0
0	1	0	0	0	0
1	0	1	0	0	0
0	1	0	1	0	0
1	0	1	0	1	0
0	1	0	1	0	1];
elseif model == 4 
    DCM.B{1,1} = [0	0	0	0	0	0
0	0	0	0	0	0
0	0	1	0	0	0
0	0	0	1	0	0
0	0	1	0	1	0
0	0	0	1	0	1];
elseif model == 5 
    % ohne  Amygdala - FFA connection
    % mit interhemisphären connection
    DCM.B{1,1} = [1	1	0	0	0	0
1	1	0	0	0	0
0	0	1	1	0	0
0	0	1	1	0	0
1	0	1	0	1	1
0	1	0	1	1	1];
elseif model == 6 
    DCM.B{1,1} = [0	0	0	0	0	0
0	0	0	0	0	0
0	0	1	1	0	0
0	0	1	1	0	0
0	0	1	0	1	1
0	0	0	1	1	1]; 
elseif model == 7 
    % ohne interhemisphären connection
    DCM.B{1,1} = [1	0	0	0	0	0
0	1	0	0	0	0
0	0	1	0	0	0
0	0	0	1	0	0
1	0	1	0	1	0
0	1	0	1	0	1];
elseif model == 8 
    DCM.B{1,1} = [0	0	0	0	0	0
0	0	0	0	0	0
0	0	1	0	0	0
0	0	0	1	0	0
0	0	1	0	1	0
0	0	0	1	0	1];

%% Top-Down Family
% mit interhemisphären connection
elseif model == 9 
    DCM.B{1,1}  = [1	1	1	0	1	0
1	1	0	1	0	1
0	0	1	1	1	0
0	0	1	1	0	0
0	0	0	0	1	1
0	0	0	0	1	1]; 
elseif model == 10
    DCM.B{1,1}  = [1	1	1	0	1	0
1	1	0	1	0	1
0	0	1	1	1	0
0	0	1	1	0	1
0	0	1	0	1	1
0	0	0	1	1	1]; 
elseif model == 11
% ohne interhemisphären connection
    DCM.B{1,1} = [1	0	1	0	1	0
0	1	0	1	0	1
0	0	1	0	1	0
0	0	0	1	0	0
0	0	0	0	1	0
0	0	0	0	0	1];
elseif model == 12
    DCM.B{1,1} = [1	0	1	0	1	0
0	1	0	1	0	1
0	0	1	0	1	0
0	0	0	1	0	1
0	0	1	0	1	0
0	0	0	1	0	1];
elseif model == 13
% ohne Amygdala - FFA connection
% mit interhemisphären connection
    DCM.B{1,1} = [1	1	0	0	1	0
1	1	0	0	0	1
0	0	1	1	1	0
0	0	1	1	0	0
0	0	0	0	1	1
0	0	0	0	1	1]; 
elseif model == 14
    DCM.B{1,1} = [1	1	0	0	1	0
1	1	0	0	0	1
0	0	1	1	1	0
0	0	1	1	0	1
0	0	1	0	1	1
0	0	0	1	1	1]; 
elseif model == 15
% ohne interhemisphären connection
    DCM.B{1,1} = [1	0	0	0	1	0
0	1	0	0	0	1
0	0	1	0	1	0
0	0	0	1	0	0
0	0	0	0	1	0
0	0	0	0	0	1];
elseif model == 16
    DCM.B{1,1} = [1	0	0	0	1	0
0	1	0	0	0	1
0	0	1	0	1	0
0	0	0	1	0	1
0	0	1	0	1	0
0	0	0	1	0	1];

%% Mix Family
elseif model == 17 
% mit interhemisphären connection
    DCM.B{1,1} = [1	1	1	0	1	0
1	1	0	1	0	1
0	0	1	1	1	0
0	0	1	1	0	1
1	0	0	0	1	1
0	1	0	0	1	1];
elseif model == 18
    DCM.B{1,1}  = [1	1	1	0	1	0
1	1	0	1	0	1
0	0	1	1	1	0
0	0	1	1	0	1
1	0	1	0	1	1
0	1	0	1	1	1]; 
elseif model == 19
    DCM.B{1,1}  = [1	0	1	0	1	0
0	1	0	1	0	1
0	0	1	0	1	0
0	0	0	1	0	1
1	0	0	0	1	0
0	1	0	0	0	1];
elseif model == 20 
    DCM.B{1,1} = [1	0	1	0	1	0
0	1	0	1	0	1
0	0	1	0	1	0
0	0	0	1	0	1
1	0	1	0	1	0
0	1	0	1	0	1];
elseif model == 21
% ohne Amygdala - FFA connection
% mit interhemisphären connection
    DCM.B{1,1} = [1	1	0	0	1	0
1	1	0	0	0	1
0	0	1	1	1	0
0	0	1	1	0	1
1	0	0	0	1	1
0	1	0	0	1	1];
elseif model == 22
    DCM.B{1,1}  = [1	1	0	0	1	0
1	1	0	0	0	1
0	0	1	1	1	0
0	0	1	1	0	1
1	0	1	0	1	1
0	1	0	1	1	1]; 
elseif model == 23
    DCM.B{1,1} = [1	0	0	0	1	0
0	1	0	0	0	1
0	0	1	0	1	0
0	0	0	1	0	1
1	0	0	0	1	0
0	1	0	0	0	1];
elseif model == 24
    DCM.B{1,1} = [1	0	0	0	1	0
0	1	0	0	0	1
0	0	1	0	1	0
0	0	0	1	0	1
1	0	1	0	1	0
0	1	0	1	0	1];
end

%--------------------------------------------------------------------------
% Input definition
%--------------------------------------------------------------------------

%DCM.C = [1; 1; 0; 0; 0; 0];

Input_Amygdala = [1; 1; 0; 0; 0; 0];
Input_FFA      = [0; 0; 1; 1; 0; 0];
Input_DLPFC    = [0; 0; 0; 0; 1; 1];

% für hälfte der Modelle Input 2 in  FFA, für andere Hälfte Input in Amygdala
if (model == 2) || (model == 4) || (model == 6) || (model == 8) || (model == 10) || (model == 12) || (model == 14) || (model == 16) || (model == 18) || (model == 20) || (model == 22) || (model == 24)  
    DCM.C  = Input_FFA;                
elseif (model == 1) || (model == 3) || (model == 5) || (model == 7)
    DCM.C = Input_Amygdala;     
elseif (model == 9) || (model == 11) || (model == 13) || (model == 15) || (model == 17) || (model == 19) || (model == 21) || (model == 23)
    DCM.C = Input_DLPFC;
end

%--------------------------------------------------------------------------
% Between trial effects
% trial in comparison with reference. Reference would be "weak", trial would be "strong"
%--------------------------------------------------------------------------
DCM.xU.name{1,1} = 'weak'; %conscious
DCM.xU.name{1,2} = 'strong'; %unconscious
DCM.xU.X = [1 -1; -1 1];

%--------------------------------------------------------------------------
% Save DCM
%--------------------------------------------------------------------------
DCM.name = sprintf(('EEG_DCM_model_%02d_of_24.mat'),model); 
save(DCM.name,'DCM');

% %--------------------------------------------------------------------------
% % Invert                                                                                      
% %--------------------------------------------------------------------------
DCM      = spm_dcm_erp(DCM);

end