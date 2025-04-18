clc
clear 
tic


%% 导入总录
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

if ICA_if == 0                                   % 如果做过ICA 但没移除成分则进行，否则直接跳过


    %%
    %% 通道信息备用
    % chanlocs = EEG.chanlocs
    % save('chanlocs.mat','chanlocs')

    % 迭代次数
    Ite = 10;

    %% 根据bin做基线矫正
    timeBase(1).data = [-200 0]
    % timeBase(2).data = [-500 -400]
    % timeBase(1).data = [-500 -400]
    % timeBase(2).data = [-500 -400]
    %% 执行文件夹
    PathAB = RawPath;
    List= dir(fullfile(PathAB,'*.set'));           % 这里只读.set， 防止其他文件被读入！
    setNames = {List.name};
    NumSub = length(setNames)

    for CASE = 1:NumSub

        clear ALLEEG EEG CURRENTSET                             %% 提前清场
        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;              %  仅保留ALLCOM 的记录功能

        Route = strcat(PathAB,setNames{CASE})
        NAME = setNames{CASE}
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




        PathDoc = ICA_Path
        [status, msg, msgID] = mkdir(PathDoc)
        SAVENAME = strcat('Data_', string(CASE))
        EEG = pop_saveset( EEG, SAVENAME{1}, PathDoc);


        x = 0;
    end



end