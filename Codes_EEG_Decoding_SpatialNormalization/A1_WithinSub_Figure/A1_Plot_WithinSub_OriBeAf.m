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
lastSlashIdx = find(currentFolder == '\', 2, 'last');
parentFolder1 = currentFolder(1:lastSlashIdx - 0);
disp(parentFolder1);
load(strcat(parentFolder1,'ComList.mat'))
Name = strcat(NameComponent,'-WithinSubject-')

%% New colors
colorRange = {'#000000';...
    '#ff0000';...
    '#0057fa';...
    '#707070';...
    '#707070'}

ChanceLine = 1/BinN;

%% Import data
for ii = 1:3
NAME{ii} = strcat(NameComponent,'_',Na{ii},'_WithinSub.mat')
end

load(NAME{1})
load(NAME{2})
load(NAME{3})

Mac(1,:) = meanOrigin;         %% Note the order! origin-before-after
Mac(2,:) = mean_Before;
Mac(3,:) = mean_AfterAveraging;
siMac = size(Mac);

ac(1,:,:) = AccOrigin;
ac(2,:,:) = Acc_BeforeAveraging;
ac(3,:,:) = Acc_AfterAveraging;
siac = size(ac);

Na{1} = 'Origin';
Na{2} = 'Before';
Na{3} = 'After';

%% Define SE transparency
Transparency = 0.07;

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
newHeight = screenSize(4) / 4; % Quarter of screen height
newLeft = screenSize(3) / 2; % Left boundary at half screen width
newBottom = 0; % Bottom boundary at screen bottom

% Set position for each figure
for i = 1:length(figHandles)
    set(figHandles(i), 'Position', [newLeft, newBottom, newWidth, newHeight]);
end
hold on
%% Draw baseline fill
timeX;
timeY = [ (0) (0) (ChanceLine ) (ChanceLine )];
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
ylim([(ChanceLine  - 0.10), (max(Mac(round,:)) + 0.10)])
xlim([XLIM])
end

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

%%
title(strcat(Name,'Accuracy-Averaged:',string(PerSam),'-Categories:',BinL),...
    'fontsize',Ftitle,'FontWeight','bold')

%% Save Figure
NameFigure = strcat(NameComponent,'_MeanWaveTimeLine_Acc_WithinSub.png')
saveas(gcf, NameFigure);