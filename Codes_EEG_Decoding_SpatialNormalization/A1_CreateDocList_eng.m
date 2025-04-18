clc
clear
close all
tic

%% CreateDocList:
% RawData
currentFolder = pwd;
RawPath = strcat(currentFolder,'\0_RawData\');
[status, msg, msgID] = mkdir(RawPath);
disp('Please place files in the 0_RawData folder')
disp('Press any key to continue')
pause

PathAB = RawPath;
List= dir(fullfile(PathAB,'*.set'));                  % Only reading .set files to prevent reading other files!
setNames = {List.name};
NumSub = length(setNames);

CASE = 1
clear ALLEEG EEG CURRENTSET                           % Clear workspace in advance
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;              %  Keep only ALLCOM recording function
Route = strcat(PathAB,setNames{CASE})
NAME = setNames{CASE};
StrName = strcat(PathAB, NAME);
EEG = pop_loadset(StrName);

fs = EEG.srate;
% TimeLine = EEG.times;
% save TimeLine.mat TimeLine

chanlocs = EEG.chanlocs;
save chanlocs.mat chanlocs
clearvars -except fs RawPath 




%% Define
%% - Most Important: Define the Component of Interest for This Experiment -
NumComponent = '9';                       %% Current experiment number (for ordering - not important)
NameComponent = 'Orientation'
PerSam = 10 ;                             %% Define PerSam value: number of trials to average when partially randomizing trials

NameElec = 'Oz'                           % If focusing on LRN, this is the first electrode of interest (e.g., C3)

% For components like LRP or N2pc that focus on two electrodes, enter the second electrode here (right then left: C3/C4; PO7/PO8)
if strcmp(NameComponent, 'LRP') || strcmp(NameComponent, 'N2pc')
    NameElec2 = ''               % If focusing on LRN, this is the second electrode of interest (e.g., C4)
end

            
%% Define channel range for decoding (e.g., when focusing on channels 1-27)
ChanLength = [1:27]
% ChanLength = [1:27 33:64]     

TimeWin_Component = [100 500]             %% ERP time window of interest
timewin = [-500 1500]                     %% Epoch time range
timeba  = [-500 0]                        %% Baseline period
XLIM = timewin;                           %% Plot axis - can be set to the time window of interest or other custom time range

ICA_if = 1;                               %% Set to 1 if ICA has been performed and components removed; 0 if ICA done but components not removed

iteration = 50;                           % - Number of decoding iterations -
decodingPoints = 2;                       %% When epochs are long and sampling rate is high, set this to perform SVM training/testing every 2 points. For basic experiments, set to 1.







%% - Auto-generated -
%% - Create TimeLine - 
num_points = round(diff(timewin) / 1000 * fs);
% Create time vector
TimeLine = linspace(timewin(1), timewin(2), num_points);
len = length(TimeLine)

TimeLine_DecodingPoints = TimeLine(1:decodingPoints:end);
disp(TimeLine); % Display time vector
save TimeLine.mat TimeLine TimeLine_DecodingPoints

% Time window corresponding PointRange
A = find(TimeLine_DecodingPoints >= TimeWin_Component(1));
TimeWinPoint(1) = A(1)
B = find(TimeLine_DecodingPoints <= TimeWin_Component(2));
TimeWinPoint(2) = B(end)

%% Define time window and baseline
timeX = (cat(2,timeba, fliplr(timeba))).';   %Note: Without transpose - patch won't recognize correct format
TIMEstr = strcat(string(timewin(1)),'To',string(timewin(2)))


%% - Import Chanlocs; TimeLine - 
load('chanlocs.mat')
Elecindex = find(strcmp({chanlocs.labels}, NameElec));

if exist('NameElec2', 'var') && ischar(NameElec2)
    Elecindex2 = find(strcmp({chanlocs.labels}, NameElec2));
end




%% - Import Bin - 
%% New import procedure to ensure cell format
BinPath_Normal = strcat('BDF_', NameComponent, '.txt');
fileID = fopen(BinPath_Normal, 'r'); % Open file
CharData = textscan(fileID, '%s', 'Delimiter', '\n');      % Read each line as separate string
fclose(fileID);                                            % Close file
CharData = CharData{1};    

disp(CharData);
IM_Length = length(CharData)/3

for ii = 1:IM_Length
BinNa(ii).name = CharData{(2+ (ii-1)*3)}
end




%% Concatenate strings
% Extract all name field values
names = {BinNa(:).name};
% Use strjoin to concatenate with " - " delimiter
result = strjoin(names, '-')
% Display result
disp(result);

%% Define Bin type and dataset name
if length(result) > 10
    % Extract letter portions
    lettersOnly = regexp(BinNa(1).name, '[a-zA-Z]+', 'match'); % Match letter portions

    % Concatenate all matched portions (if multiple segments)
    lettersOnly = strjoin(lettersOnly, '');
    BinL = strcat(lettersOnly,'-',string(IM_Length))
else
    BinL = result
end
LenBin = length(BinL)
BinN = IM_Length            % Number of bin types in each bin file
ChanceLine = 1/BinN *100;
ChanceLine = round(ChanceLine, 2)

Na{1} = '1_Origin'
Na{2} = '2_Before'
Na{3} = '3_After'
clear CharData BinList fileID 

%% Create data file paths
currentFolder = pwd;
disp(['Current folder path: ', currentFolder]);

% AllData_scripts
AllData_scripts = strcat(currentFolder,'\0_0_AllData_scripts')
[status, msg, msgID] = mkdir(AllData_scripts)

% AfterICA
ICA_Path = strcat(currentFolder,'\0_1_AfterICA\')
[status, msg, msgID] = mkdir(ICA_Path)

% BEST
BEST_Path = strcat(currentFolder,'\0_2_BEST\')
[status, msg, msgID] = mkdir(BEST_Path)

BEST_Path2 = char(strcat(BEST_Path,'-Bin_',BinL,'_',TIMEstr))   
[status, msg, msgID] = mkdir(BEST_Path2)

%% Create code file paths
WithinPathA = strcat(currentFolder,'\1_WithinSub_','Data_scripts\A0_scripts\')
[status, msg, msgID] = mkdir(WithinPathA)

BetweenPathA = strcat(currentFolder,'\2_BetweenSub_','Data_scripts\A0_scripts\')
[status, msg, msgID] = mkdir(BetweenPathA )

% Create Figure folders
WithinPathB = strcat(currentFolder,'\A1_WithinSub_','Figure\')
[status, msg, msgID] = mkdir(WithinPathB)

BetweenPathB = strcat(currentFolder,'\A2_BetweenSub_','Figure\')
[status, msg, msgID] = mkdir(BetweenPathB )

CrossFigure = strcat(currentFolder,'\A3_CrossBetweenWithin_','Figure\')
[status, msg, msgID] = mkdir(CrossFigure )

%% Create data storage paths
WithinDocA = strcat(currentFolder,'\1_WithinSub_','Data_scripts\0_MVPC\')
[status, msg, msgID] = mkdir(WithinDocA)

BetweenDocA = strcat(currentFolder,'\2_BetweenSub_','Data_scripts\0_DataList_AllData\')
[status, msg, msgID] = mkdir(BetweenDocA)

BetweenDocB = strcat(currentFolder,'\2_BetweenSub_','Data_scripts\1_DataList_TrainTest\')
[status, msg, msgID] = mkdir(BetweenDocB)

%% Define colorRange and line widths etc.
%% Color
lw = [0.8 0.02 1.5 2]         %Line widths
ft = [10 12 15]

colorRange = {'#000000';...
    '#f51161';...
    '#0057fa';...
    '#707070';...
    '#707070'}

%% Font
Ftitle = 12;
Flabel = 12;
fle = 8;

%% Save overview information
clear NAME
NameCom = strcat('ComList.mat');
save (NameCom)
