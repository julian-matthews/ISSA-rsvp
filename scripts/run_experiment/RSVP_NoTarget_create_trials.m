% 11/01/2016 - Julian
% 'No target' version of the RSVP trial creator
% Assembles trials with purely a probe and distractor

function RSVP_NoTarget_create_trials

% Shuffle RNG off clock, record fresh seed & re-seed RNG from record
rng('shuffle');
Exp.RNG_seed = randi(8145060,1,1); % If you get the same seed twice, buy a lotto ticket
rng(Exp.RNG_seed);

% Test an RNG here:
% rng(2074);

% Define stimuli directories
Exp.scene_dir = '../../stimuli_trimmed/';
Exp.trial_prepro_dir = '../../stimuli_trimmed/NoTarget_preprocessed_trials/';

Exp.Gral.subNum = input('Subject number, 01-99:\n','s'); % '01';

Exp.Setup.sessions = 2;
Exp.Setup.runs = 4;

% Number of trials
% Divisible by 4 & 8 for even distribution of targ/probe positions
Exp.Trials = 40;

% Define number of crowd images to draw from (fixed to 160 in test_face_num)
image_num = 160;

% Define number of faces presented from these crowd scenes
% Max varies per image but all have at least 17 faces present
% Currently set to image with greatest number of faces (img #155, 50 faces)
% This ensures an even distribution of faces from all parts of the crowd
face_num = 46;

% Specify mask type:
% If mask_type = 1, mask will be white/black (0 || 255)
% If mask_type = 2, mask will range across white/black (0 : 255)
mask_type = 2;

%% MAKE STIMULI

begin = sprintf('\nReticulating splines:');
disp(begin)

% Load struct of trimmed scene data created with test_face_num.mat
load([Exp.scene_dir 'scene_struct.mat'],'scene');


%% PREPARE TRIALS

disp('Splines reticulated, constructing trials:')

fac_count = 0;

% Create 'massive' struct with all faces & their coords
for crowd = 1: length(scene)
    for face = 1:length(scene(crowd).caras)
        
        % Select just [101x101] faces?
        if size(scene(crowd).caras(face).face_dat,1) == 101 && size(scene(crowd).caras(face).face_dat,2) == 101
        
        fac_count = fac_count + 1;
        
        all_faces(fac_count).face_dat = scene(crowd).caras(face).face_dat;
        all_faces(fac_count).coords = scene(crowd).caras(face).coords;
        
        else
            
            continue
        
        end
        
    end
end

% Random permutation of numbers from 1:length(all_faces)
face_perm = randperm(length(all_faces));

for face = 1:length(all_faces)
    test_faces(face) = all_faces(face_perm(face));
end

%% SELECT ~RANDOM TRIAL TARGETS, DISTRACTORS & PROBES (all 101x101)
% 3719 faces are [101x101], 346 have some other dimensions

% Reset face counter
fac_count = 1;

% Counter to add incorrectly sized faces to end of 'all_faces' struct
% Allows them to be used later as ballast faces
struc_count = 0;

for sesh_num = 1:Exp.Setup.sessions
    for run_num = 1:Exp.Setup.runs
        for tr = 1:Exp.Trials
            
            TR(tr).imgDat_distractor = test_faces(fac_count).face_dat;
            
            fac_count = fac_count + 1;
            
            TR(tr).imgDat_probe = test_faces(fac_count).face_dat;
            
            fac_count = fac_count + 1;
                
        end
        
        % Assign all trial data to this run
        Runs(run_num).TR = TR;
            
    end
        
    % Assign run to session
    Sessions(sesh_num).Runs = Runs;
    
end

%% CREATE TRIAL_FACES STRUCT WITH ALL REMAINING FACES (RE-RANDOMISED)

% Setup counterbalanced target/probe/response conditions
for sesh_num = 1:Exp.Setup.sessions
    
    ball_count = 0;
    
    % Add remaining faces to 'ballast_faces' struct
    for face = fac_count:length(test_faces)
        ball_count = ball_count + 1;
        ballast_faces(ball_count) = test_faces(face);
    end
    
    new_perm = randperm(length(ballast_faces));
    
    for face = 1:length(ballast_faces)
        trial_faces(face) = ballast_faces(new_perm(face));
    end
    
    % Reset face counter
    fac_count = 0;
    
    for run_num = 1:Exp.Setup.runs
        
        % Select from probe condition (-1 -3 -5 -7)
        probe_pos = zeros(1,Exp.Trials);
        probe_pos(1:Exp.Trials/4) = -1;
        probe_pos(((Exp.Trials/4)*1+1):(Exp.Trials/4)*2) = -3;
        probe_pos(((Exp.Trials/4)*2+1):(Exp.Trials/4)*3) = -5;
        probe_pos((Exp.Trials/4)*3+1:end) = -7;
        probe_pos = Shuffle(probe_pos);
        
        % Select target condition (face 8-15)
        targ_pos = zeros(1,Exp.Trials);
        targ_pos(1:Exp.Trials/8) = 8;
        targ_pos(((Exp.Trials/8)*1+1):(Exp.Trials/8)*2) = 9;
        targ_pos(((Exp.Trials/8)*2+1):(Exp.Trials/8)*3) = 10;
        targ_pos(((Exp.Trials/8)*3+1):(Exp.Trials/8)*4) = 11;
        targ_pos(((Exp.Trials/8)*4+1):(Exp.Trials/8)*5) = 12;
        targ_pos(((Exp.Trials/8)*5+1):(Exp.Trials/8)*6) = 13;
        targ_pos(((Exp.Trials/8)*6+1):(Exp.Trials/8)*7) = 14;
        targ_pos(((Exp.Trials/8)*7+1):end) = 15;
        targ_pos = Shuffle(targ_pos);
        
        % Select side for distractor vs. probe response (DP vs. PD)
        response_pos = zeros(1,Exp.Trials);
        response_pos(1:Exp.Trials/2) = 1; % Distractor on left, probe right
        response_pos((Exp.Trials/2)+1:end) = -1; % Probe on left, distractor right
        response_pos = Shuffle(response_pos);
        
        for tr = 1:Exp.Trials
            
            % Grab trials from this run
            run_trials = (tr+(Exp.Trials*(run_num-1)));
            
            % Randomised probe lag for this trial (counterbalanced)
            TR(tr).probe_lag = probe_pos(tr);
            
            % Randomised target lag for this trial (counterbalanced)
            TR(tr).target_lag = targ_pos(tr);
            
            % Randomised response screen for this trial (counterbalanced)
            TR(tr).response_side = response_pos(tr);
            
            % Create [101x101] gaussian blob as mask (values 0 or 255)
            if mask_type == 1
                imgDat_mask = randi(2,101,101)-1;
                imgDat_mask(imgDat_mask == 1) = 255;
                TR(tr).imgDat_mask = imgDat_mask;
            elseif mask_type == 2
                imgDat_mask = randi(255,101,101);
                TR(tr).imgDat_mask = imgDat_mask;
            end
                        
            % Save distractor & probe images 
            TR(tr).imgDat_distractor = Sessions(sesh_num).Runs(run_num).TR(tr).imgDat_distractor;
            
            TR(tr).imgDat_probe = Sessions(sesh_num).Runs(run_num).TR(tr).imgDat_probe;
            
            % Check how many faces are in this trial's crowd scene
            TR(tr).crowd_size = TR(tr).target_lag;
            
            TR(tr).trial_vector = cell(1,TR(tr).target_lag);
            
            for lag = 1:TR(tr).target_lag - 1
                
                fac_count = fac_count + 1;
                TR(tr).trial_vector{lag} = trial_faces(fac_count).face_dat;
                
            end
            
            % Save the soon-to-be replaced probe-position face into the
            % "target" position
            TR(tr).trial_vector{TR(tr).target_lag} = TR(tr).trial_vector{TR(tr).target_lag + TR(tr).probe_lag};
            
            % Substitute in probe texture at right location
            TR(tr).trial_vector{TR(tr).target_lag + TR(tr).probe_lag} = TR(tr).imgDat_probe;
            
        end
        
        Run(run_num).TR = TR;
        
    end
    
    Session(sesh_num).Run = Run;
    
end

%% SAVE TO TRIAL FOLDER

Details.RNG_seed = Exp.RNG_seed;
Details.subNum = Exp.Gral.subNum;
Details.sessions = Exp.Setup.sessions;
Details.runs_per_session = Exp.Setup.runs;
Details.trials_per_run = Exp.Trials;

if ~exist([Exp.trial_prepro_dir Exp.Gral.subNum],'dir');
    mkdir('../../stimuli_trimmed/NoTarget_preprocessed_trials/', Exp.Gral.subNum);
end

disp('*')

for teh_session = 1:Exp.Setup.sessions
    
    sesh_string = mat2str(teh_session);
    
    for teh_run = 1:Exp.Setup.runs
        
        run_string = mat2str(teh_run);
        TR = Session(teh_session).Run(teh_run).TR;
        
        path = [Exp.trial_prepro_dir Exp.Gral.subNum '/' ...
            Exp.Gral.subNum '_s' sesh_string '_r' run_string];
        
        save([path '.mat'], 'Details', 'TR');
        
    end
end

%% PRINT MESSAGE TO INDICATE SAVE

total_trials = Exp.Setup.sessions*Exp.Setup.runs*Exp.Trials;

the_end = sprintf('\nNoTarget version: Created %d sessions of %d runs for subject #%s',...
    Exp.Setup.sessions,Exp.Setup.runs,Exp.Gral.subNum);
the_trials = sprintf('There''s %d trials per run so %d in total',...
    Exp.Trials, total_trials);

disp(the_end)
disp(the_trials)

end
