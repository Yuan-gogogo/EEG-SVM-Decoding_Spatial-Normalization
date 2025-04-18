clc
clear
close all
tic



%% Working - scripts - 1
load('ComList.mat')
PathALL= strcat(AllData_scripts,'\')
List= dir(fullfile(PathALL,'*.m'));         
setNames = {List.name};
NumSub = length(setNames)
Processing = strcat(PathALL,setNames{1})
run(Processing)



%% Working - scripts - 2
load('ComList.mat')
PathALL= strcat(AllData_scripts,'\')
List= dir(fullfile(PathALL,'*.m'));         
setNames = {List.name};
NumSub = length(setNames)
Processing = strcat(PathALL,setNames{2})
run(Processing)

