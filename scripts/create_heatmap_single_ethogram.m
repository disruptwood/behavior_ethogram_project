function create_heatmap_single_ethogram(behaviorData, flyIndex, behaviorLabels)
    % heatmap_single_ethogram: Creates a heatmap ethogram for a single fly.
    % Behaviors are grouped into time buckets for better visualization.
    %
    % Inputs:
    %   - behaviorData: Struct with behavior start (t0s) and end (t1s) times.
    %   - flyIndex: Index of the fly.
    %   - behaviorLabels: Names of the behaviors.

    % Define the time bucket size (e.g., 100 frames per bucket)
    framesPerBucket = 100;

    % Step 1: Calculate the total time range (max frame)
    behaviorNames = fieldnames(behaviorData.behaviors);
    numBehaviors = length(behaviorNames);
    maxFrames = 0;

    % Find the maximum end time across all behaviors
    for i = 1:numBehaviors
        t1s = behaviorData.behaviors.(behaviorNames{i}).t1s;
        if ~isempty(t1s)
            maxFrames = max(maxFrames, max(t1s));
        end
    end

    % Step 2: Initialize the behavior analysis matrix
    numBuckets = ceil(maxFrames / framesPerBucket);
    behaviorMatrix = zeros(numBehaviors, numBuckets);

    % Step 3: Aggregate behavior occurrences into time buckets
    for i = 1:numBehaviors
        t0s = behaviorData.behaviors.(behaviorNames{i}).t0s;
        t1s = behaviorData.behaviors.(behaviorNames{i}).t1s;

        if ~isempty(t0s) && ~isempty(t1s)
            for j = 1:length(t0s)
                % Determine start and end buckets for the current behavior interval
                startBucket = ceil(t0s(j) / framesPerBucket);
                endBucket = ceil(t1s(j) / framesPerBucket);

                % Increment behavior counts across the relevant buckets
                for bucket = startBucket:endBucket
                    behaviorMatrix(i, bucket) = behaviorMatrix(i, bucket) + 1;
                end
            end
        end
    end

    % Step 4: Normalize behavior counts within each bucket
    for bucket = 1:numBuckets
        bucketSum = sum(behaviorMatrix(:, bucket));
        if bucketSum > 0
            behaviorMatrix(:, bucket) = behaviorMatrix(:, bucket) / bucketSum;
        end
    end

    % Step 5: Plot the heatmap
    figure('Name', sprintf('Heatmap Ethogram for Fly %d', flyIndex), 'NumberTitle', 'off');
    heatmap(1:numBuckets, behaviorLabels, behaviorMatrix, ...
            'Colormap', parula, 'ColorLimits', [0 1]);

    % Step 6: Customize the axes and title
    xlabel('Time Buckets');
    ylabel('Behaviors');
    title(sprintf('Heatmap Ethogram for Fly %d', flyIndex));
    set(gca, 'FontSize', 10); % Adjust font size for clarity
end
