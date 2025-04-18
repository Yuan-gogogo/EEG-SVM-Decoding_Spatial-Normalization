cclear
close all
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

lenTime = size(TimeLine_DecodingPoints);
lenTime = lenTime(2);
% Time naming
TA(1) = round(TimeLine(1));
TA(2) = round(TimeLine(end));
NameTime = strcat(string(TA(1)),'To',string(TA(2)))

ChanceLine = 1/BinN *100;

%% New colors
colorRange = {'#000000';...
    '#ff0000';...
    '#0057fa';...
    '#707070';...
    '#707070'}

%% Import data
for ii = 1:3
NAME{ii} = strcat(NameComponent,'_',Na{ii},'_PerSample_10_Time',NameTime,'_ACC.mat')
end

load(NAME{1})
Mac(1,:) = meanACC;         %% Note the order! origin-before-after
ac(1,:,:) = squeeze(mean(ACC,3));

load(NAME{2})
Mac(2,:) = meanACC;  
ac(2,:,:) = squeeze(mean(ACC,3));

load(NAME{3})
Mac(3,:) = meanACC;  
siMac = size(Mac);
ac(3,:,:) = squeeze(mean(ACC,3));
siac = size(ac);

Na{1} = 'Origin';
Na{2} = 'Before';
Na{3} = 'After';

%% Define time window and baseline
timeX = (cat(2,timeba, fliplr(timeba))).';  % Note: needs transpose for patch to recognize format
TIMEstr = strcat(string(timewin(1)),'To',string(timewin(2)))

%% Time length
lenTime = size(TimeLine_DecodingPoints);
lenTime = lenTime(2);
TA(1) = round(TimeLine_DecodingPoints(1));
TA(2) = round(TimeLine_DecodingPoints(end));
NameTime = strcat(string(TA(1)),'To',string(TA(2)));

%% Define SE transparency
Transparency = 0.07;
%% Define binlist
PerSam = 10

%% Plot_Main Figure
figure('color', 'w');
%% Set Figure to occupy bottom right quarter of screen
% Get handles of all open figures
figHandles = findall(0, 'Type', 'figure');

% Get screen dimensions [left, bottom, width, height]
screenSize = get(0, 'ScreenSize');

% Calculate bottom right quarter area
newWidth = screenSize(3) / 2; % Half of screen width
newHeight = screenSize(4) / 4; 
newLeft = screenSize(3) / 2; % Left boundary at half screen width
newBottom = 0; % Bottom boundary at screen bottom

% Set position and size for each figure
for i = 1:length(figHandles)
    set(figHandles(i), 'Position', [newLeft, newBottom, newWidth, newHeight]);
end

hold on
%% Draw baseline fill
timeX;
timeY = [ (0) (0) (ChanceLine) (ChanceLine)];
patch('DisplayName','Baseline',...
    'YData',timeY,...
    'XData',timeX,...
    'FaceAlpha',Transparency,...
    'LineStyle','none',...
    'FaceColor','#a7a9ab');

for round = 1:siac(1)
%% Calculate standard error
clear SEac
SiSUB = size(ac);
for ii = 1 : SiSUB(3)
    SEac(ii) =std(ac(round,:,ii))  / sqrt(SiSUB(2));
end

%% Plot standard error
clear yt1 yt2 yt
yt1 =  Mac(round,:)+ SEac;
yt2 = fliplr(Mac(round,:) - SEac);
yt = (cat(2, yt1,yt2)).';
clear xt1 xt2 xt
xt1 = TimeLine_DecodingPoints;
xt2 = fliplr(TimeLine_DecodingPoints);
xt = (cat(2,xt1,xt2)).';

patch('DisplayName',strcat('Standard Error-',Na{round}),...
    'YData',yt,...
    'XData',xt,...
    'FaceAlpha',Transparency,...
    'LineStyle','none',...
    'FaceColor',char(colorRange(round)));
end

for round = 1:siac(1)
%% plot
f = plot(TimeLine_DecodingPoints, Mac(round,:),'-','LineWidth',lw(1),'Color',char(colorRange(round)))
f.DisplayName = Na{round}
ylim([(ChanceLine  - 10), (max(Mac(round,:)) + 10)])
xlim(XLIM)
end

%% Set legend position
% Get handles of legend and axes
lgd = legend;
ax = gca;

% Get axes position information
axPos = ax.Position;  % Axes position [left, bottom, width, height]
lgd.Units = 'normalized'; % Ensure legend position uses normalized units

% Calculate new legend position
lgdWidth = lgd.Position(3); % Legend width
lgdHeight = lgd.Position(4); % Legend height
newLeft = axPos(1) ; % Align left edge with X-axis left edge
newTop = axPos(2) + axPos(4) - 0.05; % Align top edge with Y-axis top edge
newBottom = newTop - lgdHeight; % Ensure correct bottom edge position

% Set new legend position
lgd.Position = [newLeft, newBottom, lgdWidth, lgdHeight];

set(gca,'XAxisLocation','origin','YAxisLocation','origin')
xlabel(['Time/ms'],'fontsize',Flabel);
ylabel(['Accuracy/percent'],'fontsize',Flabel)
set(gca,'FontSize',Flabel)
box off
hold off

%% Draw time window of interest
if abs(TimeLine_DecodingPoints(TimeWinPoint(1))) > 30
    x1 = xline(TimeLine_DecodingPoints(TimeWinPoint(1)),'--','LineWidth',lw(1),'Color',colorRange{5},'Label',strcat(string(floor(TimeWin_Component(1))),'ms'),'FontSize',Flabel,'FontWeight','bold')
    x1.LabelHorizontalAlignment = 'center'
    if abs(TimeLine_DecodingPoints(TimeWinPoint(1))) > 150
        x1.LabelVerticalAlignment = "top"
        x1.Annotation.LegendInformation.IconDisplayStyle = 'off';
    else
        x1.LabelVerticalAlignment = "middle"
        x1.Annotation.LegendInformation.IconDisplayStyle = 'off'; 
    end
end

if abs(TimeLine_DecodingPoints(TimeWinPoint(2))) > 30
    x1 = xline(TimeLine_DecodingPoints(TimeWinPoint(2)),'--','LineWidth',lw(1),'Color',colorRange{5},'Label',strcat(string(floor(TimeWin_Component(2))),'ms'),'FontSize',Flabel,'FontWeight','bold')
    x1.LabelHorizontalAlignment = 'center'
    if abs(TimeLine_DecodingPoints(TimeWinPoint(2))) > 150
        x1.LabelVerticalAlignment = "top"
        x1.Annotation.LegendInformation.IconDisplayStyle = 'off';
    else
        x1.LabelVerticalAlignment = "middle"
        x1.Annotation.LegendInformation.IconDisplayStyle = 'off'; 
    end
end

title(strcat(NameComponent,'- Accuracy-BetweenSubjects-Averaged:',string(PerSam),'-Categories:',BinL),...
    'fontsize',Ftitle,'FontWeight','bold')

%% Save Figure
NameFigure = strcat(NameComponent,'_MeanWaveTimeLine_Acc_BetweenSub.png')
saveas(gcf, NameFigure);
