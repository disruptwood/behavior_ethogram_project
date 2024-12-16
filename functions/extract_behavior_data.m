function behaviorData = extract_behavior_data(filesNames, flyIndex)
    % extract_behavior_data: Extracts behavior data for a single fly.
    %
    % Inputs:
    %   - filesNames: Cell array of file paths to scores_*.mat files.
    %   - flyIndex: Index of the fly to analyze (1-based).
    %
    % Output:
    %   - behaviorData: A structure containing behavior fields, where each field 
    %                   corresponds to a behavior with start (t0s) and end (t1s) frames.

    % Initialize the structure to store behavior data
    behaviorData.behaviors = struct();
    
    % Iterate through each behavior score file
    for i = 1:length(filesNames)
        % Load the data from the current file
        loadedData = load(filesNames{i}, 'allScores', 'behaviorName');
        
        % Validate the fly index and data availability
        if flyIndex > numel(loadedData.allScores.t0s) || isempty(loadedData.allScores.t0s{flyIndex})
            warning('No data found for fly index %d in file: %s', flyIndex, filesNames{i});
            continue;
        end
        
        % Extract behavior name and time intervals (start and end frames)
        behaviorName = loadedData.behaviorName;       % Behavior name (e.g., Walk, Jump)
        t0s = loadedData.allScores.t0s{flyIndex};     % Start frames for the behavior
        t1s = loadedData.allScores.t1s{flyIndex};     % End frames for the behavior
        
        % Save the extracted data into the structure
        behaviorData.behaviors.(behaviorName).t0s = t0s;
        behaviorData.behaviors.(behaviorName).t1s = t1s;
    end
    
    % Display a success message if data extraction is completed
    disp('Behavior data successfully extracted for the selected fly.');
end
