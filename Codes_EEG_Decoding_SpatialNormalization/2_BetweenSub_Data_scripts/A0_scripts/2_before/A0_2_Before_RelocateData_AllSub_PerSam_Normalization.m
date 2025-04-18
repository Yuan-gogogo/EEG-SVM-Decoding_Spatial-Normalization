clc
clear
close all
tic

%% -Initial dataset configuration-
%%
currentFolder = pwd;
disp(['Current folder path: ', currentFolder]);
currentFolder = strcat(currentFolder,'\');
currentFolder

%% Import 
% Find position of last backslash
lastSlashIdx = find(currentFolder == '\', 4, 'last');
parentFolder1 = currentFolder(1:lastSlashIdx - 0);
disp(parentFolder1);
load(strcat(parentFolder1,'ComList.mat'))

%% Configure training-testing ratio
PerTrain = 0.85; 
NumRoutes = 5;     %% Total number of iterations

%% Subject to leave out in leave-one-out validation
ChooseOne = 1;

for Tim = 1: NumRoutes
    for PerSam = [10]
        %%
        clear ranA ranB
        PathBest = BEST_Path2;
        List= dir(fullfile(PathBest,'*.best'));           % Only read .best files
        setNames = {List.name};
        NumSub = length(setNames)

        for SUB = 1 : NumSub
            NameBest = strcat(string(SUB),'.best');

            clear ALLEEG EEG CURRENTSET                             %% Clear workspace
            [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;              % Keep ALLCOM recording function
            BEST = pop_loadbest('filename', {NameBest}, 'filepath', ...
                PathBest, ...
                'Tooltype', 'erplab');
            TimeLine = BEST.times;

            %% Equalize trials across different stimuli
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
                BEST.binwise_data(ii).data = BEST.binwise_data(ii).data(:,1:decodingPoints:end,Ran(1:min_val))
            end

            %% Normalize data
            clear Nor SI
            a = -1; % Lower bound
            b = 1;  % Upper bound
            for ii = 1 : BinN
                SI(ii).data = size(BEST.binwise_data(ii).data(ChanLength,:,:))
            end

            for ii = 1 : BinN
                for time = 1: SI(ii).data(2)
                    for trial = 1: SI(ii).data(3)
                        clear x x_min x_max
                        x = squeeze(BEST.binwise_data(ii).data(ChanLength,time,trial));
                        x_min = min(BEST.binwise_data(ii).data(ChanLength,time,trial));
                        x_max = max(BEST.binwise_data(ii).data(ChanLength,time,trial));
                        Nor(ii).data(:,time,trial) = a + (x - x_min) * (b - a) / (x_max - x_min);
                    end
                end
            end

            for ii = 1 : BinN
                BEST.binwise_data(ii).data = Nor(ii).data
            end

            %% Random configuration
            for ii = 1 : BinN
                si = size(BEST.binwise_data(ii).data(:,:,:));
                si = si(3)
                Ran = randperm(si);
                Num_AfterAverage = floor(si/PerSam);

                if Num_AfterAverage == 0
                    Num_AfterAverage = 1
                    Data(ii).data(:,:,1) = mean(BEST.binwise_data(ii).data(:,:,:),3);
                else
                    for Ongoing = 1 : Num_AfterAverage
                        X = PerSam*Ongoing;
                        Y = (X-PerSam+1):X;
                        Data(ii).data(:,:,Ongoing) = mean(BEST.binwise_data(ii).data(:,:,Ran(Y)),3);
                    end
                end
                % Label
                Label(ii).data = zeros(Num_AfterAverage,1) + ii;

                % Test
                SS = size(Data(ii).data);
                if length(SS) == 3
                    SS = SS(3);
                else
                    SS = 1;
                end

                if SS ~= length(Label(ii).data)
                    disp('Subject:')
                    SUB
                    disp('Category:')
                    ii
                    disp('Data size does not match Label size')
                    pause
                end
            end

            %% Organize raw data and labels for single subject
            for ii = 1:BinN
                DataSub(SUB).sti(ii).data = double(Data(ii).data)
                DataSub(SUB).la(ii).data = Label(ii).data
            end

            clear si Ran Num_AfterAverage Ongoing X Y
            clear Data Label
            x = 00;  % Breakpoint
        end
    end
    PathDoc = strcat(BetweenDocA,Na{2},'\');
    [status, msg, msgID] = mkdir(PathDoc)
    DocName = strcat(string(Tim),'_Routes_','AllSub_DataLocate_Normalization.mat');
    DocName = strcat(PathDoc,DocName)
    save(DocName,'DataSub','TimeLine')
end

%% -Configure leave-one-out validation sets-
clc
clear
close all
tic

%%
currentFolder = pwd;
disp(['Current folder path: ', currentFolder]);
currentFolder = strcat(currentFolder,'\');
currentFolder

%% Import 
% Find position of last backslash
lastSlashIdx = find(currentFolder == '\', 4, 'last');
parentFolder1 = currentFolder(1:lastSlashIdx - 0);
disp(parentFolder1);
load(strcat(parentFolder1,'ComList.mat'))

%% Number of random configurations
NumRoutes = 5;
for Tim = 1: NumRoutes
    clear DataSub
    PathDoc = strcat(BetweenDocA,Na{2},'\');
    List= dir(fullfile(PathDoc,'*.mat'));           
    setNames = {List.name};
    NumSub = length(setNames)
    Name = setNames{Tim};
    NameFull = strcat(PathDoc,Name)
    load(NameFull)

    A = size(DataSub)
    for ChooseOne = 1: A(2)
        clear lenSub NumSub
        clear TrainData TestData

        lenSub = length(DataSub);
        NumSub = 1:lenSub;
        NumSub = NumSub(NumSub ~= ChooseOne);
        disp('Left-out subject:')
        ChooseOne
        disp('Other subjects:')
        NumSub

        %% STI
        %% Concatenate data from other subjects for sti(1)
        for Bi = 1 : BinN
            Data_sti(Bi).data = [];
            for i = NumSub
                if isfield(DataSub(i), 'sti') && length(DataSub(i).sti) >= 1
                    clear currentData
                    currentData = DataSub(i).sti(Bi).data;
                    if size(currentData, 3) > 0
                        Data_sti(Bi).data = cat(3, Data_sti(Bi).data, currentData); % Concatenate along 3rd dimension
                    end
                end
            end
            disp(size(Data_sti(Bi).data)); % View merged data dimensions
        end

        %% LABEL
        %% Concatenate data from other subjects for la(1)
        for Bi = 1 : BinN
            Label_Choose(Bi).data = [];
            for i = NumSub
                if isfield(DataSub(i), 'la') && length(DataSub(i).la) >= 1
                    currentData = DataSub(i).la(Bi).data;
                    Label_Choose(Bi).data = cat(1, Label_Choose(Bi).data, currentData); % Concatenate
                end
            end
            disp(size(Label_Choose(Bi).data)); % View merged data dimensions
        end

        %% Concatenate training set stimulus-label
        clear TrainData TrainLabel
        TrainData = cat(3, Data_sti(:).data);
        TrainData = permute(TrainData,[3, 1, 2]);
        TrainData = double(TrainData);
        TrainLabel = cat(1,Label_Choose(:).data);

        %% Concatenate test set stimulus-label
        clear TestData TestLabel
        TestData = cat(3, DataSub(ChooseOne).sti(:).data);
        TestData = permute(TestData,[3, 1, 2]);
        TestData = double(TestData);
        TestLabel = cat(1,DataSub(ChooseOne).la(:).data);

        %% Save data
        PathDoc = strcat(BetweenDocB,Na{2},'\Route_',string(Tim),'\');
        [status, msg, msgID] = mkdir(PathDoc)
        DocName = strcat(string(ChooseOne),'_Left_TrainTest_Normalization_PerSam.mat');
        DocName = strcat(PathDoc,DocName)
        save(DocName,'TrainData','TrainLabel',"TestData","TestLabel",'TimeLine')
    end
end

%% -Training and prediction-
clc
clear
close all
tic

%%
currentFolder = pwd;
disp(['Current folder path: ', currentFolder]);
currentFolder = strcat(currentFolder,'\');
currentFolder

%% Import 
% Find position of last backslash
lastSlashIdx = find(currentFolder == '\', 4, 'last');
parentFolder1 = currentFolder(1:lastSlashIdx - 0);
disp(parentFolder1);
load(strcat(parentFolder1,'ComList.mat'))

%% Import NumSub
PathAB = RawPath;
List= dir(fullfile(PathAB,'*.set'));           % Only read .set files
setNames = {List.name};
NumSub = length(setNames)
clear PathAB List setNames

%% Calculate type name - Note to modify name
NameCal = strcat(NameComponent,'_',Na{2})
NumRoutes = 5

%% Define parameters
sampleRate = 256;
PerSample = 1000/sampleRate;
TIMEstr = strcat(string(timewin(1)),'To',string(timewin(2)))

%% Time length
lenTime = size(TimeLine_DecodingPoints);
lenTime = lenTime(2);
% Time naming
TA(1) = round(TimeLine(1));
TA(2) = round(TimeLine(end));
NameTime = strcat(string(TA(1)),'To',string(TA(2)))

ACC = zeros(NumSub,lenTime,NumRoutes);
for Tim = 1: NumRoutes
    %% Path
    PathDoc = strcat(BetweenDocB,Na{2},'\Route_',string(Tim),'\');
    List= dir(fullfile(PathDoc,'*.mat'));           % Only read .mat files
    setNames = {List.name};
    NumSub = length(setNames)
    TotalSub = [1 : NumSub];

    for PerSam = PerSam
        %% Parameter Settings
        for sub = 1 : NumSub
            clear TrainLabel TrainData TestLabel TestData
            Name = strcat(PathDoc,cell2mat(setNames(sub)));
            load(Name)
            parfor TimeData = 1 : lenTime

                %% Based on Matlab2024a
                % Get training and testing data
                trainX = squeeze(TrainData(:,:,TimeData));  % [samples × features]
                testX = squeeze(TestData(:,:,TimeData));
                trainY = TrainLabel(:);
                testY = TestLabel(:);
                % Train multi-class SVM model
                model = fitcecoc(trainX, trainY, 'Learners', templateSVM('KernelFunction', 'linear'));
                % Predict
                predict_label = predict(model, testX);
                % Calculate accuracy
                correct_predictions = (predict_label == testY);
                accuracy = sum(correct_predictions) / numel(testY) * 100;  % In percentage
                % Store accuracy
                ACC(sub, TimeData, Tim) = accuracy;
                disp('Current time:')
                TimeLine(1,TimeData)

                %% Based on LIBSVM
                % model = svmtrain(TrainLabel(:), TrainData(:,:,TimeData));
                % [predict_label,accuracy,dec_values] = svmpredict(TestLabel(:), TestData(:,:,TimeData), model);
                % ACC(sub,TimeData,Tim) = accuracy(1);
                % disp('Current time:')
                % TimeLine(1,TimeData)

                XXX = 0;  % Pause point / Debug placeholder
            end
        end
    end
end

%% Save individual subject's ACC file
meanACC = squeeze(mean(ACC,[1 3]));
NameACC = strcat(NameCal,'_PerSample_',string(PerSam),'_Time',NameTime,'_ACC.mat')
save(NameACC,'ACC','meanACC','TimeLine');

NameACC_Path = strcat(BetweenPathB,NameCal,'_PerSample_',string(PerSam),'_Time',NameTime,'_ACC.mat')
save(NameACC_Path,'ACC','meanACC','TimeLine');