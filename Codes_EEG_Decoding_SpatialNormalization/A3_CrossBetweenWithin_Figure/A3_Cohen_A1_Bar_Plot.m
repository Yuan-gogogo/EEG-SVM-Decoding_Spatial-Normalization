clear
close all
clc

% Function to calculate Cohen's d
function d = cohens_d(group1, group2)
    mean1 = mean(group1);
    mean2 = mean(group2);
    std1 = std(group1);
    std2 = std(group2);
    n1 = length(group1);
    n2 = length(group2);
    pooled_std = sqrt(((n1 - 1) * std1^2 + (n2 - 1) * std2^2) / (n1 + n2 - 2));
    d = (mean1 - mean2) / pooled_std;
end

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
load(strcat(parentParent1,'ComList.mat'))

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
% Standard error
clear Ra
Ra = squeeze(mean(ACC(:,PointRange,:),[2 3])) ;
si = size(ACC)
si = si(1)
SE(1) = std(Ra)/(sqrt(si))
%%
Coh(1,:)  = Ra;

clear meanACC
load(NAME{2})   %% Before-Between
M(2) = squeeze(mean(meanACC(PointRange)))
% Standard error
clear Ra
Ra = squeeze(mean(ACC(:,PointRange,:),[2 3])) ;
si = size(ACC)
si = si(1)
SE(2) = std(Ra)/(sqrt(si))
%%
Coh(2,:)  = Ra;

clear meanACC
load(NAME{3})   %% After-Between
M(3) = squeeze(mean(meanACC(PointRange)))
% Standard error
clear Ra
Ra = squeeze(mean(ACC(:,PointRange,:),[2 3])) ;
si = size(ACC)
si = si(1)
SE(3) = std(Ra)/(sqrt(si))
%%
Coh(3,:)  = Ra;

%% Import Within Subjects data
clear Name
for ii = 1:3
NAME{ii} = strcat(WithinPathB,NameComponent,'_',Na{ii},'_WithinSub.mat')
end

load(NAME{1})               %% Origin-Within
M(4) = squeeze(mean(meanOrigin(PointRange))) *100
% Standard error
clear Ra
Ra = squeeze(mean(AccOrigin(:,PointRange),2))  *100
si = size(ACC)
si = si(1)
SE(4) = std(Ra)/(sqrt(si))
%%
Coh(4,:)  = Ra;

load(NAME{2})               %% Before-Within
M(5) = squeeze(mean(mean_Before(PointRange)))*100
% Standard error
clear Ra
Ra = squeeze(mean(Acc_BeforeAveraging(:,PointRange),2)) *100
si = size(ACC)
si = si(1)
SE(5) = std(Ra)/(sqrt(si))
%%
Coh(5,:)  = Ra;

load(NAME{3})                 %% After-Within
M(6) = squeeze(mean(mean_AfterAveraging(PointRange)))*100
% Standard error
clear Ra
Ra = squeeze(mean(Acc_AfterAveraging(:,PointRange),2))  *100
si = size(ACC)
si = si(1)
SE(6) = std(Ra)/(sqrt(si))
Coh(6,:)  = Ra;

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

hold on;
errorbar(X, M, SE, '.', 'Color', 'k', ...
         'LineWidth', 2, 'CapSize', 15);  % Add error bars

%%
labels = {'','BetweenSub-Origin', 'BetweenSub-Before', 'BetweenSub-After', '','WithinSub-Origin', 'WithinSub-Before', 'WithinSub-After'};

xticklabels(labels);          % Set X-axis tick labels
xtickangle(45);  

ylabel('Accuracy / %')
title(strcat(NameComponent,'-Category:',string(BinN),'- Mean Accuracy - Time Window:',string(TimeWin_Component(1)),'To',string(TimeWin_Component(2)),'ms'), ...
    'FontWeight','bold','FontSize',13)

ylim([00 max(M)+10])

hold on;
for i = 1:length(M)
    if i<4
        text(i, M(i) + 4, num2str(M(i), '%.2f'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 14,'FontWeight','bold');
    else
        text(i+1, M(i) + 4,num2str(M(i), '%.2f'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 14,'FontWeight','bold');
    end
end
hold off;

h1 = yline(ChanceLine,'--')
h1.Label = strcat('Chance= ',string(ChanceLine),'%')
h1.LabelHorizontalAlignment = 'center'

%% Calculate EffectSize (Cohen's d)
% Calculate Cohen's d for each group comparison
d1 = cohens_d(Coh(1, :), Coh(2, :));
d2 = cohens_d(Coh(1, :), Coh(3, :));
d3 = cohens_d(Coh(4, :), Coh(5, :));
d4 = cohens_d(Coh(4, :), Coh(6, :));

% Create results table
lastname = {'BetweenSub_Origin-Before'; 'BetweenSub_Origin-After'; ...
            'WithinSub_Origin-Before'; 'WithinSub_Origin-After'};
cohens_d_values = [d1; d2; d3; d4];

result_table = table(lastname, cohens_d_values, ...
                     'VariableNames', {'Comparison', 'Cohens_d'});
disp(result_table);

% Save results to Excel
filename = strcat(NumComponent,'_',NameComponent,'_Cohen.xlsx');
writetable(result_table, filename);

%% Save Figure
NameFigure = strcat(NameComponent,'_ACC_SE_Cross-Between-Within.png')
saveas(gcf, NameFigure);