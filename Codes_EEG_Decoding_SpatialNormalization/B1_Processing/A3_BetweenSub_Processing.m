clc
clear
close all
tic



%%


%% Working - Ori - scripts
load('ComList.mat')
PathALL= strcat(BetweenPathA,Na{1},'\')
ListALL= dir(fullfile(PathALL,'*.m'));
setNamesALL = {ListALL.name};
NumSubALL = length(setNamesALL)
ProcessingALL = strcat(PathALL,setNamesALL{1})
run(ProcessingALL)



%% Working - Before - scripts
load('ComList.mat')
PathALL= strcat(BetweenPathA,Na{2},'\')
ListALL= dir(fullfile(PathALL,'*.m'));
setNamesALL = {ListALL.name};
NumSubALL = length(setNamesALL)
ProcessingALL = strcat(PathALL,setNamesALL{1})
run(ProcessingALL)


%% Working - After - scripts
load('ComList.mat')
PathALL= strcat(BetweenPathA,Na{3},'\')
ListALL= dir(fullfile(PathALL,'*.m'));
setNamesALL = {ListALL.name};
NumSubALL = length(setNamesALL)
ProcessingALL = strcat(PathALL,setNamesALL{1})
run(ProcessingALL)
