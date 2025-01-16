%% functions/add_project_paths.m
function add_project_paths()
    % Adds all subfolders of the current project to the MATLAB path
    rootDir = pwd; % Current directory
    addpath(genpath(rootDir));
    %fprintf('All subfolders added to path: %s\n', rootDir);
end
