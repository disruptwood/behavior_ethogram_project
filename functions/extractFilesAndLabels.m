function [filesNames, numFlies, folderTags] = extractFilesAndLabels()
    % extractFilesAndLabels:
    %   1) if user selects .mat files (single condition), collect them (no reorder).
    %   2) if user selects folders (multiple conditions), collect all scores_*.mat from each folder.
    %   - Return:
    %       filesNames - cell array of paths
    %       numFlies   - # of flies in first file (for immediate feedback)
    %       folderTags - condition/folder label per file or empty in single condition.

    fprintf('--- Starting extractFilesAndLabels ---\n');

    [selectedPaths, selectionType] = selectFilesOrFolders();
    fprintf('Selection Type: %s\n', selectionType);
    fprintf('Number of selected paths: %d\n', numel(selectedPaths));
    disp('Selected Paths:');
    disp(selectedPaths);

    if isempty(selectedPaths)
        error('No files or folders selected. Operation cancelled.');
    end

    % Initialize outputs
    filesNames = {};
    folderTags = {};
    %numFlies   = 0;

    if strcmp(selectionType, 'files')
        % SINGLE CONDITION
        files = selectedPaths;
        for i = 1:numel(files)
            [~, ~, ext] = fileparts(files{i});
            if ~strcmpi(ext,'.mat')
                error('All selected files must be .mat');
            end
        end
        [dirs, baseNames, ~] = cellfun(@fileparts, files, 'UniformOutput', false);
        uniqueDirs = unique(dirs);
        if numel(uniqueDirs)~=1
            error('All selected files must be in one directory for single condition mode.');
        end
        theDir = uniqueDirs{1};

        % Just store them
        filesNames = fullfile(theDir, baseNames);
        % For single condition => empty folderTags
        folderTags = repmat({''}, size(filesNames));

    elseif strcmp(selectionType, 'folders')
        % MULTIPLE CONDITIONS
        for d = 1:numel(selectedPaths)
            thisDir = selectedPaths{d};
matFiles = dir(fullfile(thisDir, 'scores_*.mat'));
if isempty(matFiles)
    % If no files directly, check for subfolders
    subFolders = dir(thisDir);
    subFolders = subFolders([subFolders.isdir] & ~ismember({subFolders.name}, {'.', '..'}));
    for s = 1:numel(subFolders)
        subFolderPath = fullfile(thisDir, subFolders(s).name);
        subMatFiles = dir(fullfile(subFolderPath, 'scores_*.mat'));
        for k = 1:numel(subMatFiles)
            fullPath = fullfile(subMatFiles(k).folder, subMatFiles(k).name);
            filesNames{end+1,1} = fullPath; %#ok<AGROW>
            folderTags{end+1,1} = subFolders(s).name; %#ok<AGROW>
        end
    end
else
    [~, condName] = fileparts(thisDir);
    for k = 1:numel(matFiles)
        fullPath = fullfile(matFiles(k).folder, matFiles(k).name);
        filesNames{end+1,1} = fullPath; %#ok<AGROW>
        folderTags{end+1,1} = condName; %#ok<AGROW>
    end
end
        end
    else
        error('Unknown selection type: %s', selectionType);
    end

    if isempty(filesNames)
        error('No .mat files found.');
    end

    % Determine #flies from first file
    fprintf('\n--- Checking first file for # of flies (allScores.t0s) ---\n');
    fprintf('First file to load: %s\n', filesNames{1});
    loadedData = load(filesNames{1}, 'allScores');
    if ~isfield(loadedData,'allScores') || ~isfield(loadedData.allScores,'t0s')
        error('First file missing allScores.t0s');
    end
    numFlies = numel(loadedData.allScores.t0s);
    fprintf('Number of flies in first file: %d\n', numFlies);

    fprintf('--- Finished extractFilesAndLabels ---\n');
end
