function [behaviorData, numFlies, minFrames] = extract_behavior_data_group(filesNames)
    % extract_behavior_data_group: Extracts binary behavior matrices for all flies and behaviors.
    % filesNames: Paths to the scores_*.mat files

    % Ensure filesNames is a cell array
    if ~iscell(filesNames)
        filesNames = {filesNames};
    end

    % Initialization
    behaviorData = struct();
    minFrames = inf;

    % Determine the number of flies from the first file
    loadedData = load(filesNames{1}, 'allScores');
    numFlies = numel(loadedData.allScores.t0s);

    % Process each file
    for i = 1:length(filesNames)
        % Load data
        loadedData = load(filesNames{i}, 'allScores', 'behaviorName');
        behaviorName = loadedData.behaviorName;

        % Collect t1s and filter out empty elements
        t1s = loadedData.allScores.t1s;
        t1s = t1s(~cellfun(@isempty, t1s));  % Remove empty elements

        % Calculate the maximum number of frames
        if ~isempty(t1s)
            maxFrames = max(cellfun(@(x) max(x), t1s, 'UniformOutput', true));
        else
            maxFrames = 0; % If no data, set to 0
        end

        % Initialize the behavior binary matrix
        behaviorMatrix = zeros(numFlies, maxFrames);

        % Fill the matrix
        for flyIdx = 1:numFlies
            t0s = loadedData.allScores.t0s{flyIdx};
            t1s = loadedData.allScores.t1s{flyIdx};

            if ~isempty(t0s) && ~isempty(t1s)
                for j = 1:length(t0s)
                    behaviorMatrix(flyIdx, t0s(j):t1s(j)) = 1;
                end
            end
        end

        % Update the minimum number of frames
        minFrames = min(minFrames, size(behaviorMatrix, 2));
        behaviorData.(behaviorName) = behaviorMatrix(:, 1:minFrames);
    end
end
