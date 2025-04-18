clear
close
tic

currentFolder = pwd;
disp(['Current folder path: ', currentFolder]);
currentFolder = strcat(currentFolder,'\');
currentFolder

%% Import
% Find the position of the last slash
lastSlashIdx = find(currentFolder == '\', 3, 'last');
parentFolder = currentFolder(1:lastSlashIdx - 0);
disp(parentFolder);
load(strcat(parentFolder,'ComList.mat'))

%% Name data
for ii = 1:3
    NAME{ii} = strcat(NameComponent,'_',Na{ii},'_WithinSub.mat')
end

%% PathMVPC
for ii = 1:length(Na)
    PathMVPC{ii} = strcat(WithinDocA,Na{ii},'\')
end

% Working! Decoding
PathBest = strcat(BEST_Path2,'\')
List= dir(fullfile(PathBest,'*.best'));           % Only reading .best files to prevent reading other files
setNames = {List.name};
NumSub = length(setNames)

%% Decoding-Origin
for SUB = 1: NumSub
    Name = setNames{SUB}

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    BEST = pop_loadbest('filename', Name, 'filepath', PathBest, 'Tooltype', 'erplab');
    TimeLine = BEST.times;

    %% Reduce Standard trials to match deviation/task trials
    for ii = 1 : BinN
        si(ii).data = size(BEST.binwise_data(ii).data)
    end

    % Extract all si(ii).data(3) values
    data3_values = arrayfun(@(x) x.data(3), si);
    % Find minimum value and its index
    [min_val, min_index] = min(data3_values);
    % Display result
    fprintf('Minimum value is %d, corresponding to ii = %d.\n', min_val, min_index);

    for ii = 1 : BinN
        clear Ran
        Ran = randperm(si(ii).data(3));
        BEST.binwise_data(ii).data = BEST.binwise_data(ii).data(:,:,Ran(1:min_val))
    end

    %% Note! In ERP-CORE dataset, only channels 1:28 are actual valid electrodes. Use ChanLength defined in main script
    clear siTrials Cross
    siTrials = size(BEST.binwise_data(1).data);
    siTrials = siTrials(3);
    Cross = ceil(siTrials/PerSam)
    if Cross == 1
        Cross = 2
    end

    MVPC = pop_decoding(BEST, 'Channels', ChanLength, 'classcoding', 'OneVsAll', 'Classes', (1 : length(BEST.binwise_data)), 'Decode_Every_Npoint', decodingPoints, 'DecodeTimes', [BEST.times(1) BEST.times(end)], 'EqualizeTrials', 'classes', 'Method', 'SVM', 'nCrossblocks', Cross, 'nIter', [iteration], 'ParCompute', 'on', 'Tooltype', 'erplab');
    AccOrigin(SUB,:) = MVPC.average_score;

    %% Save mvpc
    NameMVPC = strcat(string(SUB),'_Origin');
    FileMVPC = strcat(string(SUB),'_Origin.mvpc');
    [status, msg, msgID] = mkdir(PathMVPC{1})
    MVPC = pop_savemymvpc(MVPC, 'mvpcname', char(NameMVPC), 'filename', char(FileMVPC), 'filepath', PathMVPC{1}, 'Warning', 'on');

    X = 0;
end

DocName = NAME{1} 
meanOrigin = squeeze(mean(AccOrigin,1));
save(DocName,'AccOrigin','TimeLine','meanOrigin')
Path_DocName = strcat(WithinPathB,NAME{1});
save(Path_DocName,'AccOrigin','TimeLine','meanOrigin')

%% Decoding- Normalization Before the Averaging
for SUB = 1 : NumSub
    Name = setNames{SUB}
    clear BEST.binwise_data

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    BEST = pop_loadbest('filename', Name, 'filepath', PathBest, 'Tooltype', 'erplab');
    TimeLine = BEST.times;

    %% Reduce Standard trials to match deviation/task trials
    for ii = 1 : BinN
        si(ii).data = size(BEST.binwise_data(ii).data)
    end

    % Extract all si(ii).data(3) values
    data3_values = arrayfun(@(x) x.data(3), si);
    % Find minimum value and its index
    [min_val, min_index] = min(data3_values);
    % Display result
    fprintf('Minimum value is %d, corresponding to ii = %d.\n', min_val, min_index);

    for ii = 1 : BinN
        clear Ran
        Ran = randperm(si(ii).data(3));
        BEST.binwise_data(ii).data = BEST.binwise_data(ii).data(:,:,Ran(1:min_val))
    end

    %% normalize
    clear Nor

    a = -1; % Lower bound
    b = 1;  % Upper bound
    for ii = 1 : BinN
        SI(ii).data = size(BEST.binwise_data(ii).data(ChanLength,:,:))
    end

    for Bi = 1 : BinN
        for time = 1: SI(ii).data(2)
            for trial = 1: SI(ii).data(3)
                clear x x_min x_max
                x = squeeze(BEST.binwise_data(Bi).data(ChanLength,time,trial));
                x_min = min(BEST.binwise_data(Bi).data(ChanLength,time,trial));
                x_max = max(BEST.binwise_data(Bi).data(ChanLength,time,trial));
                Nor(Bi).data(:,time,trial) = a + (x - x_min) * (b - a) / (x_max - x_min);
            end
        end
    end

    for ii = 1 : BinN
        BEST.binwise_data(ii).data = Nor(ii).data
    end

    clear NorChan
    NorChan = size(BEST.binwise_data(1).data);
    NorChan = 1 : NorChan(1);

    %% Record current data
    clear siTrials Cross
    siTrials = size(BEST.binwise_data(1).data);
    siTrials = siTrials(3);
    Cross = ceil(siTrials/PerSam)
    if Cross == 1
        Cross = 2
    end

    %% Since BEST.binwise_data has been modified above, use full channels after modification
    MVPC = pop_decoding(BEST, 'Channels', NorChan, 'classcoding', 'OneVsAll', 'Classes', (1 : length(BEST.binwise_data)), 'Decode_Every_Npoint', decodingPoints, 'DecodeTimes', [BEST.times(1) BEST.times(end)], 'EqualizeTrials', 'classes', 'Method', 'SVM', 'nCrossblocks', Cross, 'nIter', [iteration], 'ParCompute', 'on', 'Tooltype', 'erplab');
    Acc_BeforeAveraging(SUB,:) = MVPC.average_score;

    %% Save mvpc
    NameMVPC = strcat(string(SUB),'_BeforeAveraging');
    FileMVPC = strcat(string(SUB),'_BeforeAveraging.mvpc');
    [status, msg, msgID] = mkdir(PathMVPC{2})
    MVPC = pop_savemymvpc(MVPC, 'mvpcname', char(NameMVPC), 'filename', char(FileMVPC), 'filepath', PathMVPC{2}, 'Warning', 'on');
end

DocName = NAME{2} 
mean_Before = squeeze(mean(Acc_BeforeAveraging,1));
save(DocName,'TimeLine','mean_Before','Acc_BeforeAveraging')
Path_DocName = strcat(WithinPathB,NAME{2});
save(Path_DocName,'TimeLine','mean_Before','Acc_BeforeAveraging')

%% Decoding - Normalization After the Averaging
for SUB = 1 : NumSub
    Name = setNames{SUB}

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    BEST = pop_loadbest('filename', Name, 'filepath', PathBest, 'Tooltype', 'erplab');
    TimeLine = BEST.times;

    %% Reduce Standard trials to match deviation/task trials
    for ii = 1 : BinN
        si(ii).data = size(BEST.binwise_data(ii).data)
    end

    % Extract all si(ii).data(3) values
    data3_values = arrayfun(@(x) x.data(3), si);
    % Find minimum value and its index
    [min_val, min_index] = min(data3_values);
    % Display result
    fprintf('Minimum value is %d, corresponding to ii = %d.\n', min_val, min_index);

    for ii = 1 : BinN
        clear Ran
        Ran = randperm(si(ii).data(3));
        BEST.binwise_data(ii).data = BEST.binwise_data(ii).data(:,:,Ran(1:min_val))
    end

    %% This is a self-adjusting function that adds 'normalization' to the original pop_decoding function
    clear siTrials Cross
    siTrials = size(BEST.binwise_data(1).data);
    siTrials = siTrials(3);
    Cross = ceil(siTrials/PerSam)
    if Cross == 1
        Cross = 2
    end

    MVPC = pop_decoding_NormalizeAfter(BEST, 'Channels', ChanLength, 'classcoding', 'OneVsAll', 'Classes', (1 : length(BEST.binwise_data)), 'Decode_Every_Npoint', decodingPoints, 'DecodeTimes', [BEST.times(1) BEST.times(end)], 'EqualizeTrials', 'classes', 'Method', 'SVM', 'nCrossblocks', Cross, 'nIter', [iteration], 'ParCompute', 'on', 'Tooltype', 'erplab');
    Acc_AfterAveraging(SUB,:) = MVPC.average_score;

    %% Save mvpc
    NameMVPC = strcat(string(SUB),'_AfterAveraging');
    FileMVPC = strcat(string(SUB),'_AfterAveraging.mvpc');
    [status, msg, msgID] = mkdir(PathMVPC{3})
    MVPC = pop_savemymvpc(MVPC, 'mvpcname', char(NameMVPC), 'filename', char(FileMVPC), 'filepath', PathMVPC{3}, 'Warning', 'on');
end

DocName = NAME{3} 
mean_AfterAveraging = squeeze(mean(Acc_AfterAveraging,1));
save(DocName,'TimeLine','mean_AfterAveraging','Acc_AfterAveraging')

Path_DocName = strcat(WithinPathB,NAME{3});
save(Path_DocName,'TimeLine','mean_AfterAveraging','Acc_AfterAveraging')







































%    clear
%    close
%    tic
% 
% 
% 
% 
% 
%    currentFolder = pwd;
%    disp(['当前文件夹路径为: ', currentFolder]);
%    currentFolder = strcat(currentFolder,'\');
%    currentFolder
% 
%    %% 导入
%    % 找到最后一个斜杠的位置
%    lastSlashIdx = find(currentFolder == '\', 3, 'last');
%    parentFolder = currentFolder(1:lastSlashIdx - 0);
%    disp(parentFolder);
%    load(strcat(parentFolder,'ComList.mat'))
% 
% 
%    %% 命名数据
%    for ii = 1:3
%        NAME{ii} = strcat(NameComponent,'_',Na{ii},'_WithinSub.mat')
%    end
% 
% 
% 
% 
% %% PathMVPC
% for ii = 1:length(Na)
%     PathMVPC{ii} = strcat(WithinDocA,Na{ii},'\')
% 
% end
% 
% 
% % Working！ Decoding
% PathBest = strcat(BEST_Path2,'\')
% List= dir(fullfile(PathBest,'*.best'));           % 这里只读.set， 防止其他文件被读入！
% setNames = {List.name};
% NumSub = length(setNames)
% 
% %% Decoding-Origin
% for SUB = 1: NumSub
%     % for SUB = 1 : NumSub
%     Name =  setNames{SUB}
% 
%     [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
%     BEST = pop_loadbest( 'filename',  Name, 'filepath', PathBest, 'Tooltype', 'erplab' );
%     TimeLine = BEST.times;
% 
%     %% 对Standard进行削减，到deviation等试次--task等试次
%     for ii = 1 : BinN
%         si(ii).data = size(BEST.binwise_data(ii).data)
%         % siB = size(BEST.binwise_data(2).data)
%     end
% 
%     % 提取所有 si(ii).data(3) 的值
%     data3_values = arrayfun(@(x) x.data(3), si);
%     % 找到最小值及其对应的索引
%     [min_val, min_index] = min(data3_values);
%     % 显示结果
%     fprintf('最小值为 %d，对应的 ii 为 %d。\n', min_val, min_index);
% 
%     for ii = 1 : BinN
%         clear Ran
%         Ran = randperm(si(ii).data(3));
%         BEST.binwise_data(ii).data = BEST.binwise_data(ii).data(:,:,Ran(1:min_val))
%     end
% 
% 
% 
%     %% 注意！ ERP-CORE 数据集的33个channels中只有1:28是实际采集的有效电极。读取总纲目设定的 ChanLength
%     clear siTrials Cross
%     siTrials = size(BEST.binwise_data(1).data);
%     siTrials = siTrials (3);
%     Cross =  ceil(siTrials/PerSam)
%     if Cross == 1
%         Cross = 2
%     end
% 
%     MVPC = pop_decoding( BEST , 'Channels', ChanLength, 'classcoding', 'OneVsAll', 'Classes', (1 : length(BEST.binwise_data)), 'Decode_Every_Npoint', decodingPoints, 'DecodeTimes', [ BEST.times(1) BEST.times(end)], 'EqualizeTrials', 'classes', 'Method', 'SVM', 'nCrossblocks', Cross, 'nIter', [iteration], 'ParCompute', 'on', 'Tooltype', 'erplab' );
%     AccOrigin(SUB,:) = MVPC.average_score;
% 
% 
%     %% 储存mvpc
%     NameMVPC = strcat(string(SUB),'_Origin');
%     FileMVPC = strcat(string(SUB),'_Origin.mvpc');
%     [status, msg, msgID] = mkdir(PathMVPC{1})
%     MVPC = pop_savemymvpc(MVPC, 'mvpcname', char(NameMVPC) , 'filename', char(FileMVPC), 'filepath', PathMVPC{1} , 'Warning', 'on');
% 
%     X = 0;
% end
% 
% DocName = NAME{1} 
% meanOrigin = squeeze(mean(AccOrigin,1));
% save(DocName,'AccOrigin','TimeLine','meanOrigin')
% Path_DocName  = strcat(WithinPathB,NAME{1} );
% save(Path_DocName,'AccOrigin','TimeLine','meanOrigin')
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% %% Decoding- Normalization Before the Averaging
% for SUB = 1 : NumSub
%     Name =  setNames{SUB}
%     clear BEST.binwise_data
% 
% 
%     [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
%     BEST = pop_loadbest( 'filename',  Name, 'filepath', PathBest, 'Tooltype', 'erplab' );
%     TimeLine = BEST.times;
% 
%     %% 对Standard进行削减，到deviation等试次--task等试次
%     for ii = 1 : BinN
%         si(ii).data = size(BEST.binwise_data(ii).data)
%         % siB = size(BEST.binwise_data(2).data)
%     end
% 
%     % 提取所有 si(ii).data(3) 的值
%     data3_values = arrayfun(@(x) x.data(3), si);
%     % 找到最小值及其对应的索引
%     [min_val, min_index] = min(data3_values);
%     % 显示结果
%     fprintf('最小值为 %d，对应的 ii 为 %d。\n', min_val, min_index);
% 
%     for ii = 1 : BinN
%         clear Ran
%         Ran = randperm(si(ii).data(3));
%         BEST.binwise_data(ii).data = BEST.binwise_data(ii).data(:,:,Ran(1:min_val))
%     end
% 
% 
% 
% 
%     %% normalize
%     clear Nor
% 
%     a = -1; % 下限
%     b = 1;  % 上限
%     for ii = 1 : BinN
%         SI(ii).data = size(BEST.binwise_data(ii).data(ChanLength,:,:))
%     end
% 
% 
% 
%     for Bi = 1 : BinN
%         for time = 1:  SI(ii).data(2)
%             for trial = 1:  SI(ii).data(3)
%                 clear x x_min x_max
%                 x = squeeze(BEST.binwise_data(Bi).data(ChanLength,time,trial));
%                 x_min = min(BEST.binwise_data(Bi).data(ChanLength,time,trial));
%                 x_max = max(BEST.binwise_data(Bi).data(ChanLength,time,trial));
%                 Nor(Bi).data(:,time,trial) = a + (x - x_min) * (b - a) / (x_max - x_min);
%             end
%         end
%     end
% 
%     for ii = 1 : BinN
%         BEST.binwise_data(ii).data = Nor(ii).data
%     end
% 
%     clear NorChan
%     NorChan = size(BEST.binwise_data(1).data);
%     NorChan = 1 : NorChan(1);
% 
% 
% 
%     %% 记录当下数据
%     clear siTrials Cross
%     siTrials = size(BEST.binwise_data(1).data);
%     siTrials = siTrials (3);
%     Cross =  ceil(siTrials/PerSam)
%     if Cross == 1
%         Cross = 2
%     end
% 
%     %% 以上的BEST.binwise_data被修正过，因此以下'Channels'使用修正后的全通道
%     MVPC = pop_decoding( BEST , 'Channels', NorChan, 'classcoding', 'OneVsAll', 'Classes', (1 : length(BEST.binwise_data)), 'Decode_Every_Npoint', decodingPoints, 'DecodeTimes', [ BEST.times(1) BEST.times(end)], 'EqualizeTrials', 'classes', 'Method', 'SVM', 'nCrossblocks', Cross, 'nIter', [iteration], 'ParCompute', 'on', 'Tooltype', 'erplab' );
%     Acc_BeforeAveraging(SUB,:) = MVPC.average_score;
% 
% 
% 
% 
%     %% 储存mvpc
%     NameMVPC = strcat(string(SUB),'_BeforeAveraging');
%     FileMVPC = strcat(string(SUB),'_BeforeAveraging.mvpc');
%     [status, msg, msgID] = mkdir(PathMVPC{2})
%     MVPC = pop_savemymvpc(MVPC, 'mvpcname', char(NameMVPC) , 'filename', char(FileMVPC), 'filepath', PathMVPC{2} , 'Warning', 'on');
% 
% 
% end
% 
% DocName = NAME{2} 
% mean_Before = squeeze(mean(Acc_BeforeAveraging,1));
% save(DocName,'TimeLine','mean_Before','Acc_BeforeAveraging')
% Path_DocName  = strcat(WithinPathB,NAME{2} );
% save(Path_DocName,'TimeLine','mean_Before','Acc_BeforeAveraging')
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% %% Decoding - Normalization After the Averaging
% 
% for SUB = 1 : NumSub
%     Name =  setNames{SUB}
% 
% 
% 
%     [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
%     BEST = pop_loadbest( 'filename',  Name, 'filepath', PathBest, 'Tooltype', 'erplab' );
%     TimeLine = BEST.times;
% 
% 
%     %% 对Standard进行削减，到deviation等试次--task等试次
%     for ii = 1 : BinN
%         si(ii).data = size(BEST.binwise_data(ii).data)
%     end
% 
%     % 提取所有 si(ii).data(3) 的值
%     data3_values = arrayfun(@(x) x.data(3), si);
%     % 找到最小值及其对应的索引
%     [min_val, min_index] = min(data3_values);
%     % 显示结果
%     fprintf('最小值为 %d，对应的 ii 为 %d。\n', min_val, min_index);
% 
% 
%     for ii = 1 : BinN
%         clear Ran
%         Ran = randperm(si(ii).data(3));
%         BEST.binwise_data(ii).data = BEST.binwise_data(ii).data(:,:,Ran(1:min_val))
%     end
% 
% 
% 
% 
% 
% 
%     %% 这里是一个自调函数，对原始pop_decoding引用的erp_decoding函数中添加了'normalization'新程序段落
%     clear siTrials Cross
%     siTrials = size(BEST.binwise_data(1).data);
%     siTrials = siTrials (3);
%     Cross =  ceil(siTrials/PerSam)
%     if Cross == 1
%         Cross = 2
%     end
% 
%     MVPC = pop_decoding_NormalizeAfter( BEST , 'Channels', ChanLength, 'classcoding', 'OneVsAll', 'Classes', (1 : length(BEST.binwise_data)), 'Decode_Every_Npoint', decodingPoints, 'DecodeTimes', [ BEST.times(1) BEST.times(end)], 'EqualizeTrials', 'classes', 'Method', 'SVM', 'nCrossblocks', Cross, 'nIter', [iteration], 'ParCompute', 'on', 'Tooltype', 'erplab' );
%     % MVPC = pop_decoding( BEST , 'Channels', [ 1:28], 'classcoding', 'OneVsAll', 'Classes', [ 1 2], 'Decode_Every_Npoint', [ 1], 'DecodeTimes', [ -199.219 796.875], 'EqualizeTrials', 'classes', 'Method', 'SVM', 'nCrossblocks', [ 8], 'nIter', [ 100], 'ParCompute', 'on', 'Tooltype', 'erplab' );
%     Acc_AfterAveraging(SUB,:) = MVPC.average_score;
% 
% 
%     %% 储存mvpc
%     NameMVPC = strcat(string(SUB),'_AfterAveraging');
%     FileMVPC = strcat(string(SUB),'_AfterAveraging.mvpc');
%     [status, msg, msgID] = mkdir(PathMVPC{3})
%     MVPC = pop_savemymvpc(MVPC, 'mvpcname', char(NameMVPC) , 'filename', char(FileMVPC), 'filepath', PathMVPC{3} , 'Warning', 'on');
% 
% 
% end
% 
% DocName = NAME{3} 
% mean_AfterAveraging = squeeze(mean(Acc_AfterAveraging,1));
% save(DocName,'TimeLine','mean_AfterAveraging','Acc_AfterAveraging')
% 
% 
% Path_DocName  = strcat(WithinPathB,NAME{3});
% save(Path_DocName,'TimeLine','mean_AfterAveraging','Acc_AfterAveraging')
% 
% 



