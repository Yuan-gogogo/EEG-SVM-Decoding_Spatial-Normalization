clc
clear
close all
tic




%% Working - script - 1
load('ComList.mat')
PathALL= strcat(WithinPathB,'\')
List= dir(fullfile(PathALL,'*.m'));           
setNames = {List.name};
NumSub = length(setNames)
Processing = strcat(PathALL,setNames{1})
run(Processing)



%% Working - script - 2
load('ComList.mat')
PathALL= strcat(WithinPathB,'\')
List= dir(fullfile(PathALL,'*.m'));           
setNames = {List.name};
NumSub = length(setNames)
Processing = strcat(PathALL,setNames{2})
run(Processing)
