clc
clear
close all
tic



%% Working - script - 1
load('ComList.mat')
PathALL= strcat(CrossFigure,'\')
ListALL= dir(fullfile(PathALL,'*.m'));
setNamesALL = {ListALL.name};
NumSubALL = length(setNamesALL)
Processing = strcat(PathALL,setNamesALL{1})
run(Processing)





%% Working - script - 1
load('ComList.mat')
PathALL= strcat(CrossFigure,'\')
ListALL= dir(fullfile(PathALL,'*.m'));
setNamesALL = {ListALL.name};
NumSubALL = length(setNamesALL)
Processing = strcat(PathALL,setNamesALL{2})
run(Processing)



%% Working - script - 3
load('ComList.mat')
PathALL= strcat(CrossFigure,'\')
ListALL= dir(fullfile(PathALL,'*.m'));
setNamesALL = {ListALL.name};
NumSubALL = length(setNamesALL)
Processing = strcat(PathALL,setNamesALL{3})
run(Processing)






