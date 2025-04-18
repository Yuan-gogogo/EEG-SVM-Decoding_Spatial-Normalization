clc
clear 
tic

%% Get current folder
currentFolder = pwd;
disp(['Current folder path: ', currentFolder]);
currentFolder = strcat(currentFolder,'\');
currentFolder

% Find the position of the last backslash
lastSlashIdx = find(currentFolder == '\', 2, 'last');
% Extract parent path
parentFolder = currentFolder(1:lastSlashIdx - 0);
disp(parentFolder);

load(strcat(parentFolder,'ComList.mat'))

%% Determine working folder
if ICA_if == 0
    PathAB = ICA_Path;
else
    PathAB = RawPath;
end

List = dir(fullfile(PathAB,'*.set'));  % Only read .set files to prevent other files from being loaded
setNames = {List.name};
NumSub = length(setNames);

TiBEST = BEST_Path;

%% WORKING LOOP
for CASE = 1:NumSub  % Loop through all subjects
    % for CASE = 1:1  % test - one subject only
    % eeglab

    %% Load data
    clear ALLEEG EEG CURRENTSET  % Clear variables
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;  % Start EEGLAB and keep ALLCOM for history

    Route = strcat(PathAB,setNames{CASE});
    NAME = setNames{CASE};
    StrName = strcat(PathAB, NAME);
    EEG = pop_loadset(StrName);

    %% Create eventlist
    PathEventList = currentFolder;
    NameEventList = strcat(PathEventList,'eventlist_test.txt');
    [status, msg, msgID] = mkdir(PathEventList);
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
        NameEventList);

    %% Import binlist
    BinFileX = strcat(parentFolder,BinPath_Normal);
    EEG  = pop_binlister( EEG , 'BDF', BinFileX, 'IndexEL', 1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );

    %% Epoch segmentation -- TimeWindow & Baseline
    EEG = pop_epochbin( EEG , timewin,  timeba);
    EEG = eeg_checkset( EEG );

    %% Create .best file.
    % Here, 'DSindex' marks the current dataset -- class corresponds to number of bin types.
    % Note: for the same .set file, different bin types should be saved into different .best files.
    eeglab redraw  % IMPORTANT: if not refreshing the GUI, evalin won't retrieve dataset info from the EEGLAB GUI
    currdata = evalin('base', 'CURRENTSET');  % Get the index of the currently loaded dataset

    BEST = pop_extractbest( ALLEEG , 'Bins', [1:int8(BinN)], 'Criterion', 'good', 'DSindex', currdata, 'ExcludeBoundary', 'on', 'Tooltype', 'erplab' );

    PathBEST = BEST_Path2;
    BName = strcat(int2str(CASE),'.best');
    [status, msg, msgID] = mkdir(PathBEST);  % Create and verify the save path

    % (1) Note: The dataset name in 'bestname' may need modification.
    % (2) Also modify the filename inside 'filename' if necessary.
    BEST = pop_savemybest(BEST, 'filename', BName, 'filepath', PathBEST, 'overwriteatmenu', 'on');
end
