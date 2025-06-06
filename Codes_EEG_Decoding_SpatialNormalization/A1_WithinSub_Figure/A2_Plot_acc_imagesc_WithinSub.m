clear all
close all
clc
tic

%%
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

Name = strcat(NameComponent,'-WithinSubject-')

%% Import data
for ii = 1:3
NAME{ii} = strcat(NameComponent,'_',Na{ii},'_WithinSub.mat')
end

%% Plot formatting parameters
ft = [10 12 15]
colorRange = {'#3685ba';...
              '#d47d44';...
              '#45b828';
              '#f56433';
              '#0d4469'}
Ftitle = 12;
Flabel = [8 10 12 14];
fle = 8;
lw =[ 1 0.8 0.6 2]

%% Colorbar range
colorR(1) = 1/BinN  - 0.10;
colorR(2) = 1/BinN  + 0.10;

%% Configure Figure to occupy right 50% of screen
% Create example plot
figure('Color', 'w'); 
% Get screen dimensions
screenSize = get(0, 'ScreenSize'); % [left, bottom, width, height]
% Set figure to occupy right 50% of desktop
figWidth = screenSize(3) / 2; % Half of screen width
figHeight = screenSize(4);    % Full screen height
figLeft = screenSize(3) / 2;  % Left boundary at half screen width
figBottom = 0;                % Bottom boundary at 0

% Adjust figure position and size
set(gcf, 'Position', [figLeft, figBottom, figWidth, figHeight]);

%% Resize figure to 90% of original size
% Get handles of all open figures
figHandles = findall(0, 'Type', 'figure');

% Resize each figure to 90% of current size
for i = 1:length(figHandles)
    % Get current figure position
    currentPos = get(figHandles(i), 'Position');
    
    % Calculate new size (90%)
    newWidth = currentPos(3) * 0.9;
    newHeight = currentPos(4) * 0.9;
    newLeft = currentPos(1) + (currentPos(3) - newWidth) / 2; % Center horizontally
    newBottom = currentPos(2) + (currentPos(4) - newHeight) / 2; % Center vertically
    
    % Set new position and size
    set(figHandles(i), 'Position', [newLeft, newBottom, newWidth, newHeight]);
end

%% Find point corresponding to 0ms
C = find(TimeLine_DecodingPoints <= 0)
C = C(end)

%% Plot Origin data
load(NAME{1})
subplot(3,1,1)
imagesc(AccOrigin)
colorbar
colormap(slanCM('rainbow'))
numLabels = 30; % Number of labels to display
len = length(TimeLine_DecodingPoints)
tickPositions = linspace(1, len , numLabels);
tickLabels = round(linspace(TimeLine_DecodingPoints(1), TimeLine_DecodingPoints(end), numLabels));
xticks(tickPositions);
xticklabels(arrayfun(@(x) sprintf('%dms', x), tickLabels, 'UniformOutput', false));
caxis(colorR);
title(strcat(NameComponent,'- Accuracy - Within Subjects - Origin'),'FontWeight','bold','fontsize',Ftitle)
ylabel('Subject')

hold on
if abs(TimeLine_DecodingPoints(TimeWinPoint(1))) > 30
    x1 = xline(TimeWinPoint(1),':','LineWidth',lw(4),'Color',colorRange{5},'Label',strcat(string(TimeWin_Component(1)),'ms'),'FontSize',Flabel(2) ,'FontWeight','bold')
    x1.LabelHorizontalAlignment = 'center'
    x1.LabelVerticalAlignment = "top"
end

if abs(TimeLine_DecodingPoints(TimeWinPoint(2))) > 30
    x1 = xline(TimeWinPoint(2),':','LineWidth',lw(4),'Color',colorRange{5},'Label',strcat(string(TimeWin_Component(2)),'ms'),'FontSize',Flabel(2) ,'FontWeight','bold')
    x1.LabelHorizontalAlignment = 'center'
    x1.LabelVerticalAlignment = "top"
end

x1 = xline(C,'--','LineWidth',lw(4),'Color','black','Label','0ms','FontSize',Flabel(4) ,'FontWeight','bold')
x1.LabelHorizontalAlignment = 'center'
x1.LabelVerticalAlignment = "top"

%% Plot Before Averaging data
load(NAME{2})
subplot(3,1,2)
imagesc(Acc_BeforeAveraging)
colorbar
colormap(slanCM('rainbow'))

numLabels = 30; % Number of labels to display
len = length(TimeLine_DecodingPoints)
tickPositions = linspace(1, len , numLabels);
tickLabels = round(linspace(TimeLine_DecodingPoints(1), TimeLine_DecodingPoints(end), numLabels));
xticks(tickPositions);
xticklabels(arrayfun(@(x) sprintf('%dms', x), tickLabels, 'UniformOutput', false));
caxis(colorR);
title(strcat(NameComponent,'- Accuracy - Within Subjects - Normalization Before Averaging'),'FontWeight','bold','fontsize',Ftitle)
ylabel('Subject')

hold on
if abs(TimeLine_DecodingPoints(TimeWinPoint(1))) > 30
    x1 = xline(TimeWinPoint(1),':','LineWidth',lw(4),'Color',colorRange{5},'Label',strcat(string(TimeWin_Component(1)),'ms'),'FontSize',Flabel(2) ,'FontWeight','bold')
    x1.LabelHorizontalAlignment = 'center'
    x1.LabelVerticalAlignment = "top"
end

if abs(TimeLine_DecodingPoints(TimeWinPoint(2))) > 30
    x1 = xline(TimeWinPoint(2),':','LineWidth',lw(4),'Color',colorRange{5},'Label',strcat(string(TimeWin_Component(2)),'ms'),'FontSize',Flabel(2) ,'FontWeight','bold')
    x1.LabelHorizontalAlignment = 'center'
    x1.LabelVerticalAlignment = "top"
end

x1 = xline(C,'--','LineWidth',lw(4),'Color','black','Label','0ms','FontSize',Flabel(4) ,'FontWeight','bold')
x1.LabelHorizontalAlignment = 'center'
x1.LabelVerticalAlignment = "top"

%% Plot After Averaging data
load(NAME{3})

subplot(3,1,3)
imagesc(Acc_AfterAveraging)
colorbar
colormap(slanCM('rainbow'))

numLabels = 30; % Number of labels to display
len = length(TimeLine_DecodingPoints)
tickPositions = linspace(1, len , numLabels);
tickLabels = round(linspace(TimeLine_DecodingPoints(1), TimeLine_DecodingPoints(end), numLabels));
xticks(tickPositions);
xticklabels(arrayfun(@(x) sprintf('%dms', x), tickLabels, 'UniformOutput', false));
caxis(colorR);

title(strcat(NameComponent,'- Accuracy - Within Subjects - Normalization After Averaging'),'FontWeight','bold','fontsize',Ftitle)
ylabel('Subject')

hold on
if abs(TimeLine_DecodingPoints(TimeWinPoint(1))) > 30
    x1 = xline(TimeWinPoint(1),':','LineWidth',lw(4),'Color',colorRange{5},'Label',strcat(string(TimeWin_Component(1)),'ms'),'FontSize',Flabel(2) ,'FontWeight','bold')
    x1.LabelHorizontalAlignment = 'center'
    x1.LabelVerticalAlignment = "top"
end

if abs(TimeLine_DecodingPoints(TimeWinPoint(2))) > 30
    x1 = xline(TimeWinPoint(2),':','LineWidth',lw(4),'Color',colorRange{5},'Label',strcat(string(TimeWin_Component(2)),'ms'),'FontSize',Flabel(2) ,'FontWeight','bold')
    x1.LabelHorizontalAlignment = 'center'
    x1.LabelVerticalAlignment = "top"
end

x1 = xline(C,'--','LineWidth',lw(4),'Color','black','Label','0ms','FontSize',Flabel(4) ,'FontWeight','bold')
x1.LabelHorizontalAlignment = 'center'
x1.LabelVerticalAlignment = "top"

%% Save figure
NameFigure = strcat(NameComponent,'_imagesc_Acc_WithinSub.png')
saveas(gcf, NameFigure);