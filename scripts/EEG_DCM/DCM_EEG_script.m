
%  subData = 'mespmeeg_Sub-115_BackwardMask_Preprocessed.mat'
%  subDir = 'firstLevel'
%  model = 1

spm('defaults','EEG');

% Data and analysis directories
%--------------------------------------------------------------------------


Pbase     = 'C:/Users/juhoffmann/OneDrive - Uniklinik RWTH Aachen/Auswertung/DCM_EEG';       

Pdata     = fullfile(Pbase,'preproc', subData);                             % data directory in Pbase
Panalysis = fullfile(Pbase,subDir);                                         % analysis directory in Pbase

% if model is already estimated, dont do it again
if exist(fullfile(Panalysis,sprintf('DCM_M%d_%s',model,subData)),'file')
    return;
end

% Data filename
%--------------------------------------------------------------------------
DCM.xY.Dfile = Pdata;

% Parameters and options used for setting up model
%--------------------------------------------------------------------------
DCM.options.analysis = 'ERP'; % analyze evoked responses
DCM.options.model    = 'ERP'; % ERP model
DCM.options.spatial  = 'ECD'; % spatial model                               
% equivalent current dipole (ECD) for each source or applying a patch on the cortical surface (IMG);

DCM.options.trials   = [1 2]; % index of ERPs within ERP/ERF file
DCM.options.Tdcm(1)  = 0;     % start of peri-stimulus time to be modelled  relative to the stimulus onset. 
DCM.options.Tdcm(2)  = 200;   % end of peri-stimulus time to be modelled  relative to the stimulus onset. 
DCM.options.Nmodes   = 8;     % nr of modes for data selection
DCM.options.h        = 1;     % nr of DCT components This sets the number of Discrete Cosine Transform (DCT) components to use for detrending the data. A value of 1 implies a minimal amount of detrending.
DCM.options.onset    = 50;    % selection of onset (prior mean)                     It indicates an expectation that the neural response starts around 50 milliseconds after the stimulus. This value is used in the model to help estimate the actual onset time.
DCM.options.D        = 1;     % downsampling
DCM.options.han      = 0;     % no windowing (hanning)                              % reduce the influence of the beginning and end of  the timeseries
DCM.options.multiC   = 1;     % alow multiple Conditions


%--------------------------------------------------------------------------
% Data and spatial model
%--------------------------------------------------------------------------
DCM  = spm_dcm_erp_data(DCM);

%--------------------------------------------------------------------------
% Location priors for dipoles
%--------------------------------------------------------------------------
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

% % fMRI-DCM
% % A- Matrix mit Interhemispherischen Verbindungen 
% a               = [1 1 1 0 1 0; 1 1 0 1 0 1; 1 0 1 1 1 0; 0 1 1 1 0 1; 1 0 1 0 1 1; 0 1 0 1 1 1];
% % ohne interhemisphärische Verbindungen zuzulassen
% a_2             = [1 0 1 0 1 0; 0 1 0 1 0 1; 1 0 1 0 1 0; 0 1 0 1 0 1; 1 0 1 0 1 0; 0 1 0 1 0 1];

DCM.A{1} = zeros(Nareas, Nareas);               % forward connections
DCM.A{2} = zeros(Nareas,Nareas);                % backward connections
DCM.A{3} = zeros(Nareas,Nareas);                % lateral connections
% DCM.A{}(row,column)

% forward connection
DCM.A{1}(3,1)       = 1;
DCM.A{1}(4,2)       = 1;
DCM.A{1}(5,[1,3])   = 1;
DCM.A{1}(6,[2,4])   = 1;

% backward connection
DCM.A{2}(1,[3,5])   = 1;
DCM.A{2}(2,[4,6])   = 1;
DCM.A{2}(3,5)       = 1; 
DCM.A{2}(4,6)       = 1; 

% lateral connections only for half of the model 
if (model == 3) || (model == 4) || (model == 7) || (model == 8)  ||  (model == 11) || (model == 12) || (model == 15) || (model == 16) || (model == 19) || (model == 20) || (model == 23) || (model == 24) 
    DCM.A{3}(1,2) = 1;   
    DCM.A{3}(2,1) = 1; 
    DCM.A{3}(3,4) = 1;   
    DCM.A{3}(4,3) = 1; 
    DCM.A{3}(5,6) = 1;   
    DCM.A{3}(6,5) = 1; 
else % für model 1,2 5,6 9,10 13,14 17,18 21,22 keine lateralen verbindungen annehmen
    DCM.A{3} = zeros(Nareas,Nareas);                
end

%--------------------------------------------------------------------------
% Modulation effects definition
%--------------------------------------------------------------------------
DCM.B{1,1} = eye(6) + DCM.A{1} + DCM.A{2} + DCM.A{3};    % allow self connection and add forward/lateral/back A Matrix

% keine Amydgala/FFA modulation in manchen modellen
if (model == 2) || (model == 4) || (model == 6) || (model == 8) ||  (model == 10) || (model == 12) || (model == 14) || (model == 16) || (model == 18) || (model == 20) || (model == 22) || (model == 24) 
    DCM.B{1,1}(1,3) = 0;
    DCM.B{1,1}(2,3) = 0;
    DCM.B{1,1}(3,1) = 0;
    DCM.B{1,1}(4,2) = 0;
end

%--------------------------------------------------------------------------
% Input definition
% % two inputs for different conditions possible?? 
% define input in V1!
%--------------------------------------------------------------------------
Input_Amygdala = [1; 1; 0; 0; 0; 0];
Input_FFA      = [0; 0; 1; 1; 0; 0];

% für hälfte der Modelle Input in Amygdala, für andere Hälfte Input in FFA
if (model == 1) || (model == 2) || (model == 3) || (model == 4) || (model == 9) || (model == 10) || (model == 11) || (model == 12) || (model == 17) || (model == 18) || (model == 19) || (model == 20) 
    DCM.C{1} = Input_Amygdala; % input für trial 1 (weak/conscious)
    DCM.C{2} = Input_FFA; % input für trial 2 (strong/unconscious)   
else % für model 5,6,7,8 13,14,15,16 21,22,23,24
    DCM.C{1} = Input_Amygdala; % input für trial 1 (weak/conscious)
    DCM.C{2} = Input_Amygdala; % input für trial 2 (strong/unconscious) 
end


%--------------------------------------------------------------------------
% Between trial effects
% trial in comparison with reference. Reference would be "weak", trial would be "strong"                                                                                          
% 
%--------------------------------------------------------------------------
DCM.xU.name{1,1} = 'strong';
DCM.xU.X = [-1; eye(1)];

%--------------------------------------------------------------------------
% Save DCM
%--------------------------------------------------------------------------
DCM.name = sprintf('DCM_M%d_%s',model,subData);
save(DCM.name,'DCM');


% %--------------------------------------------------------------------------
% % Invert                                                                                      % why not inverted here?
% %--------------------------------------------------------------------------
% 
% DCM      = spm_dcm_erp(DCM);
