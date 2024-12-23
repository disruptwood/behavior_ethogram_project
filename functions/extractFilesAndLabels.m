function [filesNames, behaviorLabels, numFlies] = extractFilesAndLabels()
    predefinedOrder = {
        'scores_Jump.mat', ...
        'scores_Stable_Interaction.mat', ...
        'scores_Grooming.mat', ...
        'scores_Social_Clustering.mat', ...      
        'scores_Short_Distance_Approach.mat', ...        
        'scores_Long_Lasting_Interaction.mat', ...       
        'scores_Touch.mat', ...
        'scores_Long_Distance_Approach.mat', ...       
        'scores_Turn.mat', ...
        'scores_Stop.mat', ...
        'scores_Walk.mat'
    };

    % Step 1: File selection
    [files, path] = uigetfile('scores_*.mat', 'Select Behavior Score Files', 'MultiSelect', 'on');
    if isnumeric(files)
        error('No files selected. Operation cancelled.');
    end
    if ischar(files)
        files = {files};
    end

    % Step 2: Reorder selected files according to predefinedOrder
    orderedFiles = reorderFiles(files, predefinedOrder);
    filesNames = fullfile(path, orderedFiles);

    % Step 3: Clean behavior labels in new order
    behaviorLabels = cellfun(@cleanBehaviorName, orderedFiles, 'UniformOutput', false);

    % Step 4: Extract number of flies from the first file in ordered list
    try
        loadedData = load(filesNames{1}, 'allScores');
        if ~isfield(loadedData, 'allScores')
            error('The file does not contain the required "allScores" structure.');
        end
        numFlies = numel(loadedData.allScores.t0s);
    catch ME
        error('Error reading file: %s\nDetails: %s', filesNames{1}, ME.message);
    end

    %disp('Successfully loaded behavior score files and extracted clean labels.');
end

function cleanName = cleanBehaviorName(fileName)
    cleanName = strrep(fileName, 'scores_', '');
    cleanName = strrep(cleanName, '.mat', '');
    cleanName = strrep(cleanName, '_', ' ');
    cleanName = regexprep(cleanName, '\s+', ' ');
    cleanName = strtrim(cleanName);
end

function orderedFiles = reorderFiles(files, predefinedOrder)
    orderedFiles = {};

    % 1) Include files that match predefined order, in predefined order
    for i = 1:numel(predefinedOrder)
        idx = find(strcmp(predefinedOrder{i}, files), 1);
        if ~isempty(idx)
            orderedFiles{end+1} = files{idx}; %#ok<AGROW>
        end
    end

    % 2) Append any remaining files not in predefinedOrder
    usedFiles = orderedFiles;
    remainingFiles = setdiff(files, usedFiles);
    orderedFiles = [orderedFiles, remainingFiles];
end