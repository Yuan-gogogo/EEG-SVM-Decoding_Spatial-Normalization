clear
close all
clc

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

%% Point range corresponding to time window
disp(strcat(NameComponent,'-TimeRange:'))
TimeWin = timewin
PointRange = TimeWinPoint(1):TimeWinPoint(2)

% Time naming
TA(1) = round(TimeLine(1));
TA(2) = round(TimeLine(end));
NameTime = strcat(string(TA(1)),'To',string(TA(2)))

%% Import Between Subjects data
clear Name
for ii = 1:3
NAME{ii} = strcat(BetweenPathB,NameComponent,'_',Na{ii},'_PerSample_10_Time',NameTime,'_ACC.mat')
end

%% Plot Between Subjects
load(NAME{1})
M(1) = squeeze(mean(meanACC(PointRange)))           %% Origin-Between
%% Standard error
clear Ra
Ra = squeeze(mean(ACC(:,PointRange,:),[2 3])) ;
si = size(ACC)
si = si(1)
SE(1) = std(Ra)/(sqrt(si))
%%

clear meanACC
load(NAME{2})   %% Before-Between
M(2) = squeeze(mean(meanACC(PointRange)))
%% Standard error
clear Ra
Ra = squeeze(mean(ACC(:,PointRange,:),[2 3])) ;
si = size(ACC)
si = si(1)
SE(2) = std(Ra)/(sqrt(si))
%%

clear meanACC
load(NAME{3})   %% After-Between
M(3) = squeeze(mean(meanACC(PointRange)))
%% Standard error
clear Ra
Ra = squeeze(mean(ACC(:,PointRange,:),[2 3])) ;
si = size(ACC)
si = si(1)
SE(3) = std(Ra)/(sqrt(si))
%%

%% Import Within Subjects data
clear Name
for ii = 1:3
NAME{ii} = strcat(WithinPathB,NameComponent,'_',Na{ii},'_WithinSub.mat')
end

load(NAME{1})               %% Origin-Within
M(4) = squeeze(mean(meanOrigin(PointRange))) *100
%% Standard error
clear Ra
Ra = squeeze(mean(AccOrigin(:,PointRange),2))  *100
si = size(ACC)
si = si(1)
SE(4) = std(Ra)/(sqrt(si))
%%

load(NAME{2})               %% Before-Within
M(5) = squeeze(mean(mean_Before(PointRange)))*100
%% Standard error
clear Ra
Ra = squeeze(mean(Acc_BeforeAveraging(:,PointRange),2)) *100
si = size(ACC)
si = si(1)
SE(5) = std(Ra)/(sqrt(si))
%%

load(NAME{3})                 %% After-Within
M(6) = squeeze(mean(mean_AfterAveraging(PointRange)))*100
%% Standard error
clear Ra
Ra = squeeze(mean(Acc_AfterAveraging(:,PointRange),2))  *100
si = size(ACC)
si = si(1)
SE(6) = std(Ra)/(sqrt(si))
%%

X = cat(2,(1:3),(5:7))

figure('color', 'w');
%% Set Figure to occupy bottom right quarter of screen
% Get handles of all open figures
figHandles = findall(0, 'Type', 'figure');

% Get screen dimensions [left, bottom, width, height]
screenSize = get(0, 'ScreenSize');

% Calculate bottom right quarter area
newWidth = screenSize(3) / 2; % Half of screen width
newHeight = screenSize(4) / 2; % Half of screen height
newLeft = screenSize(3) / 2; % Left boundary at half screen width
newBottom = 0; % Bottom boundary at screen bottom

% Set position and size for each figure
for i = 1:length(figHandles)
    set(figHandles(i), 'Position', [newLeft, newBottom, newWidth, newHeight]);
end
hold on
%%

PlotBar = bar(X,M) 
PlotBar.EdgeColor = 'none';  % Remove bar edges
PlotBar.FaceColor='flat';
PlotBar.CData = [0.20 0.20 0.20;
    0.55 0.55 0.55;
    0.84 0.84 0.84;
    0.96 0.20 0.11;
    0.97 0.62 0.53;
    0.98 0.89 0.83]

ax=gca;
hold on;
grid on;
ax.LineWidth=1.2;
ax.XMinorTick='on';
ax.YMinorTick='on';
ax.ZMinorTick='on';
ax.GridLineStyle=':';
box off

%% Error bars
hold on;
errorbar(X, M, SE, '.', 'Color', 'k', ...
         'LineWidth', 2, 'CapSize', 15);  % Add error bars

%% X-axis labels
labels = {'','BetweenSub-Origin', 'BetweenSub-Before', 'BetweenSub-After', '','WithinSub-Origin', 'WithinSub-Before', 'WithinSub-After'};

xticklabels(labels);          % Set X-axis tick labels
xtickangle(45);  

ylabel('Accuracy / %')
title(strcat(NameComponent,'-Category:',string(BinN),'- Mean Accuracy - Time Window:',string(TimeWin_Component(1)),'To',string(TimeWin_Component(2)),'ms'), ...
    'FontWeight','bold','FontSize',13)

ylim([00 max(M)+4])

%% Add value labels on bars
hold on;
for i = 1:length(M)
    if i<4
        text(i, M(i) + 0.6, num2str(M(i), '%.2f'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 14,'FontWeight','bold');
    else
        text(i+1, M(i) + 0.6,num2str(M(i), '%.2f'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 14,'FontWeight','bold');
    end
end
hold off;

%% Add chance level line
h1 = yline(ChanceLine,'--')
h1.Label = strcat('Chance= ',string(ChanceLine),'%')
h1.LabelHorizontalAlignment = 'center'

%% Save Figure
NameFigure = strcat(NameComponent,'_ACC_SE_Cross-Between-Within.png')
saveas(gcf, NameFigure);