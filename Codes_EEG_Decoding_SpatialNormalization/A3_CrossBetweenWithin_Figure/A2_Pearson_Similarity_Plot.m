clear
close all
clc
tic

currentFolder = pwd;
disp(['Current folder path: ', currentFolder]);
currentFolder = strcat(currentFolder,'\');
currentFolder

%% Import 
% Find position of last backslash
lastSlashIdx = find(currentFolder == '\', 2, 'last');
parentFolder1 = currentFolder(1:lastSlashIdx - 0);
disp(parentFolder1);
load(strcat(parentFolder1,'ComList.mat'))

% Time naming
TA(1) = round(TimeLine(1));
TA(2) = round(TimeLine(end));
NameTime = strcat(string(TA(1)),'To',string(TA(2)))

%% Person Similarity -- Visualization

%% Import Between Subjects data
clear Name
NAME = {};
for ii = 1:3
    NAME{ii} = strcat(BetweenPathB,NameComponent,'_',Na{ii},'_PerSample_10_Time',NameTime,'_ACC.mat')
end

clear ACC
load(NAME{1})
Data(1,:,:) = squeeze(mean(ACC,3));
clear ACC
load(NAME{2})
Data(2,:,:) = squeeze(mean(ACC,3));
clear ACC
load(NAME{3})
Data(3,:,:) = squeeze(mean(ACC,3));

%% Import Within Subjects data
clear Name
for ii = 1:3
NAME{ii} = strcat(WithinPathB,NameComponent,'_',Na{ii},'_WithinSub.mat')
end

load(NAME{1})
Data(4,:,:) = AccOrigin*100;

load(NAME{2})
Data(5,:,:) = Acc_BeforeAveraging*100;

load(NAME{3})
Data(6,:,:) = Acc_AfterAveraging*100;

%% Similarity Calculation

% Calculate similarity matrices
n = size(Data, 1);
A_similarityMatrix = zeros(n, n);
B_similarityMatrix = zeros(n, n);
C_similarityMatrix = zeros(n, n);

for i = 1:n
    for j = i:n
        % Extract ith and jth samples from Data
        sample_i = squeeze(Data(i, :, :));
        sample_j = squeeze(Data(j, :, :));
        
        % Method 1: Euclidean distance
        euclidean_distance = norm(sample_i - sample_j, 'fro')
        
        % Method 2: Cosine similarity
        cosine_similarity = 1 - pdist2(sample_i(:)', sample_j(:)', 'cosine')
        
        % Method 3: Pearson correlation
        pearson_corr = corr2(sample_i, sample_j)
        
        % Method 4: SSIM similarity
        ssim_value = ssim(sample_i, sample_j)
        
        % Store similarity matrices (can choose different similarity methods)
        % Using Euclidean distance
        A_similarityMatrix(i, j) = euclidean_distance;
        A_similarityMatrix(j, i) = euclidean_distance;
        
        % Using Pearson correlation
        B_similarityMatrix(i, j) = pearson_corr;
        B_similarityMatrix(j, i) = pearson_corr;
        
        % Using SSIM
        C_similarityMatrix(i, j) = ssim_value;
        C_similarityMatrix(j, i) = ssim_value;
    end
end

%% Pearson Correlation Coefficient Visualization
figure('Color','w','Name','Pearson')
% Set figure to occupy right 1/3 of screen
screenSize = get(0, 'ScreenSize');
figWidth = screenSize(3) / 3;
figHeight = screenSize(4)/3;
figLeft = screenSize(3) / 3;
figBottom = 0;

set(gcf, 'Position', [figLeft, figBottom, figWidth, figHeight]);

% Resize figure to 90% of original size
figHandles = findall(0, 'Type', 'figure');
for i = 1:length(figHandles)
    currentPos = get(figHandles(i), 'Position');
    newWidth = currentPos(3) * 0.9;
    newHeight = currentPos(4) * 0.9;
    newLeft = currentPos(1) + (currentPos(3) - newWidth) / 2;
    newBottom = currentPos(2) + (currentPos(4) - newHeight) / 2;
    set(figHandles(i), 'Position', [newLeft, newBottom, newWidth, newHeight]);
end

% Plot similarity matrix
imagesc(B_similarityMatrix);
colorbar;
colormap(slanCM('GnBu'));

% Display matrix values
disp('Person - Similarity Matrix:');
disp(B_similarityMatrix);

% Set axis ticks
xticks(1:size(B_similarityMatrix, 2));
yticks(1:size(B_similarityMatrix, 1));
axis equal;

% Add text labels
for i = 1:size(B_similarityMatrix, 1)
    for j = 1:size(B_similarityMatrix, 2)
        if i<4 & j<4
            valueStr = sprintf('%.2f', B_similarityMatrix(i, j));
            text(j, i, valueStr, 'HorizontalAlignment', 'center', 'Color', 'white', 'FontWeight', 'bold');
        elseif i >3 & j>3
            valueStr = sprintf('%.2f', B_similarityMatrix(i, j));
            text(j, i, valueStr, 'HorizontalAlignment', 'center', 'Color', 'white', 'FontWeight', 'bold');
        else 
            valueStr = sprintf('%.2f', B_similarityMatrix(i, j));
            text(j, i, valueStr, 'HorizontalAlignment', 'center', 'Color', '#6fad86', 'FontWeight', 'bold');
        end
    end
end

% Set axis labels
xLabels = {'Between-Origin' 'Between-Before' 'Between-After' 'Within-Origin' 'Within-Before' 'Within-After'};
yLabels = {'Between-Origin' 'Between-Before' 'Between-After' 'Within-Origin' 'Within-Before' 'Within-After'};
xlim([0.5 6.5])

set(gca, 'XTick', 1:numel(xLabels), 'XTickLabel', xLabels, 'YTick', 1:numel(yLabels), 'YTickLabel', yLabels);
ax = gca;
ax.XAxis.TickLength = [0 0];
ax.YAxis.TickLength = [0 0];

title(strcat(NameComponent,'-Pearson(PCCs)'),'FontSize',12,'FontWeight','bold')

%% Save Figure
NameFigure = strcat(NameComponent,'_SimilarityPearson_Cross-Between-Within.png')
saveas(gcf, NameFigure);