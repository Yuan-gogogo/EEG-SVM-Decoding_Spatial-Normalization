clc
clear 
tic

%% Import root directory
currentFolder = pwd;
disp(['Current folder path: ', currentFolder]);
currentFolder = strcat(currentFolder,'\');
currentFolder

% Find the position of the last backslash
lastSlashIdx = find(currentFolder == '\', 2, 'last');
% Extract path
parentFolder = currentFolder(1:lastSlashIdx - 0);
disp(parentFolder);

load(strcat(parentFolder,'ComList.mat'))

if ICA_if == 0   % If ICA has been done but components not removed, do it; otherwise, skip
    Ite = 10;

    %% Baseline correction based on bin
    timeBase(1).data = [-200 0];

    %% Folder to process
    PathAB = RawPath;
    List = dir(fullfile(PathAB,'*.set'));           
    setNames = {List.name};
    NumSub = length(setNames);

    for CASE = 1:NumSub

        clear ALLEEG EEG CURRENTSET                             
        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;              

        Route = strcat(PathAB,setNames{CASE});
        NAME = setNames{CASE};
        StrName = strcat(PathAB, NAME);
        EEG = pop_loadset(StrName);

        EEG = eeg_checkset( EEG );
        EEG = pop_iclabel(EEG, 'default');
        EEG = eeg_checkset( EEG );
        EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
        EEG = eeg_checkset( EEG );

        intX = find(EEG.reject.gcompreject);

        EEG = pop_subcomp( EEG, intX, 0);
        EEG = eeg_checkset( EEG );

        PathDoc = ICA_Path;
        [status, msg, msgID] = mkdir(PathDoc);
        SAVENAME = strcat('Data_', string(CASE));
        EEG = pop_saveset( EEG, SAVENAME{1}, PathDoc);
        x = 0;
    end
end









