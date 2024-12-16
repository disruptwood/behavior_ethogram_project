function [filesNames, behaviorLabels, numFlies] = extractFilesAndLabels()
    % Hadar, i used part of your code snippet here
    % extractFilesAndLabels: Extracts behavior files and cleaned labels.
    % Outputs:
    %   - filesNames: Full paths to the scores_*.mat files.
    %   - behaviorLabels: Cleaned behavior labels.
    %   - numFlies: Number of flies.
    
    % Step 1: File selection
    [files, path] = uigetfile('scores_*.mat', 'Select Behavior Score Files', 'MultiSelect', 'on');
    
    % Check if files were selected
    if isnumeric(files)
        error('No files selected. Operation cancelled.');
    end

    % Convert file(s) to cell array
    if ischar(files)
        files = {files};
    end
    
    % Step 2: Create full path for each file
    filesNames = fullfile(path, files);
    
    % Step 3: Clean behavior labels
    behaviorLabels = cellfun(@cleanBehaviorName, files, 'UniformOutput', false);
    
    % Step 4: Extract number of flies
    try
        loadedData = load(filesNames{1}, 'allScores');
        if ~isfield(loadedData, 'allScores')
            error('The file does not contain the required "allScores" structure.');
        end
        numFlies = numel(loadedData.allScores.t0s);
    catch ME
        error('Error reading file: %s\nDetails: %s', filesNames{1}, ME.message);
    end
    
    % Notification of successful load
    disp('Successfully loaded behavior score files and extracted clean labels.');
end

function cleanName = cleanBehaviorName(fileName)
    % Clean behavior name: remove 'scores_', '.mat', replace underscores
    cleanName = strrep(fileName, 'scores_', '');   % Remove 'scores_' prefix
    cleanName = strrep(cleanName, '.mat', '');     % Remove extension
    cleanName = strrep(cleanName, '_', ' ');       % Replace underscores with spaces
    cleanName = regexprep(cleanName, '\s+', ' ');  % Remove extra spaces
    cleanName = strtrim(cleanName);                % Remove leading/trailing spaces
end
