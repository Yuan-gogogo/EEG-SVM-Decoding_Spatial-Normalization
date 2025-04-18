clc
clear 
tic




currentFolder = pwd;
disp(['当前文件夹路径为: ', currentFolder]);
currentFolder = strcat(currentFolder,'\');
currentFolder

% 找到最后一个斜杠的位置
lastSlashIdx = find(currentFolder == '\', 2, 'last');
% 提取路径
parentFolder = currentFolder(1:lastSlashIdx - 0);
disp(parentFolder);

load(strcat(parentFolder,'ComList.mat'))






%% 执行文件夹
if ICA_if == 0

    PathAB = ICA_Path
else
    PathAB = RawPath
end
List= dir(fullfile(PathAB,'*.set'));           % 这里只读.set， 防止其他文件被读入！
setNames = {List.name};
NumSub = length(setNames)

TiBEST = BEST_Path;


%% WORKING!

for CASE = 1:NumSub                                  % 被试数
    % for CASE = 1:1                                  % test - 被试数 = 1
    % eeglab
    %% 导入数据
    clear ALLEEG EEG CURRENTSET                             %% 提前清场
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;              %  仅保留ALLCOM 的记录功能

    Route = strcat(PathAB,setNames{CASE})
    NAME = setNames{CASE}
    StrName = strcat(PathAB, NAME);
    EEG = pop_loadset(StrName);




    %% 创建 eventlist
    PathEventList = currentFolder
    NameEventList = strcat(PathEventList,'eventlist_test.txt')
    [status, msg, msgID] = mkdir(PathEventList)
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
        NameEventList);


    %% 导入binlist

    BinFileX = strcat(parentFolder,BinPath_Normal )
    EEG  = pop_binlister( EEG , 'BDF', BinFileX,'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
    %% epoch分段--TimeWindow_BaseLine
    EEG = pop_epochbin( EEG , timewin,  timeba);
    EEG = eeg_checkset( EEG );



    %% 制作.best。 这里的【'DSindex', currdata】数据标定到'当前数据'---class是bin的种类数量
    %% 注意！同一个.set下不同的bin类目，也应该保存不同的.best文件
    eeglab redraw                                            %%% 注意!这里如果不刷新一下eeglab的gui的话，evalin功能就不能从eeglab的gui面板读取有几个数据
    currdata = evalin('base', 'CURRENTSET');                   %obtain currently loaded set's index 得到当前数据在几号位的结果，会返回一个整数


    BEST = pop_extractbest( ALLEEG , 'Bins', [ 1:int8(BinN)], 'Criterion', 'good', 'DSindex', currdata, 'ExcludeBoundary', 'on', 'Tooltype', 'erplab' );

    PathBEST = BEST_Path2
    BName = strcat(int2str(CASE),'.best')
    [status, msg, msgID] = mkdir(PathBEST)                 %% 创建并验证文件夹


    % 1）注意bestname后当前采用的数据名称，这里可能要修改。2）filename后的文件名称，也要想办法修改
    BEST = pop_savemybest(BEST, 'filename', BName,'filepath',PathBEST,'overwriteatmenu','on');

    % % 1）注意bestname后当前采用的数据名称，这里可能要修改。2）filename后的文件名称，也要想办法修改
    %   BEST = pop_savemybest(BEST, 'filename', BName,'filepath',PathBEST,'overwriteatmenu','on');
    X = 0 %停机位

end
