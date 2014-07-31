 % set to compact output format
format compact
% add paths
% addpath ~/matlab/mlunit_2008a
% for nctoolbox
path(path, genpath('/scen/scenario/matlab_toolbox/nctoolbox'));
setup_nctoolbox
% for scenario tools & dataextractor
addpath(genpath('/scen/scenario/matlab_scripts')); % and
addpath(genpath('/scen/scenario/matlab_toolbox'));