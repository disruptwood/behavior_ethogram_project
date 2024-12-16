function create_single_ethogram(behaviorData, flyIndex, behaviorLabels)
    % create_single_ethogram: Draws an ethogram (behavior chart) for one fly using patches.
    % 
    % Inputs:
    %   - behaviorData: Struct with behavior names and their start (t0s) and end times (t1s).
    %   - flyIndex: Index of the fly being analyzed.
    %   - behaviorLabels: Clean behavior names to display next to the ethogram.

    % Step 1: Extract behavior names and prepare colors
    behaviorNames = fieldnames(behaviorData.behaviors); % Get all behavior names
    numBehaviors = length(behaviorNames);               % Count the total behaviors
    colors = lines(numBehaviors);                      % Generate distinct colors for behaviors
    
    % Step 2: Find the maximum time range for label alignment
    % I’m collecting all end times (t1s) to know how far the timeline stretches.
    validDurations = [];
    for i = 1:numBehaviors
        t1s = behaviorData.behaviors.(behaviorNames{i}).t1s;
        if ~isempty(t1s) && isvector(t1s)
            validDurations = [validDurations; t1s(:)];
        end
    end
    
    if isempty(validDurations)
        error('No valid behavior durations found for fly index %d.', flyIndex);
    end
    
    xMax = max(validDurations);  % Max time (frames) to display
    xStart = -0.05 * xMax;       % Offset X position for aligning behavior labels

    % Step 3: Set up the figure
    figure('Name', sprintf('Ethogram for Fly %d', flyIndex), 'NumberTitle', 'off');
    hold on;
    yPositions = 1:numBehaviors; % Each behavior gets its own row (Y-position)

    % Step 4: Plot each behavior as patches
    for i = 1:numBehaviors
        behaviorName = behaviorNames{i};                       % Current behavior name
        t0s = behaviorData.behaviors.(behaviorName).t0s;       % Start times
        t1s = behaviorData.behaviors.(behaviorName).t1s;       % End times

        % Check if we have valid start and end times
        if ~isempty(t0s) && ~isempty(t1s) && isvector(t0s) && isvector(t1s)
            % Prepare patch coordinates in batch
            numIntervals = length(t0s); % Total number of behavior intervals
            patchX = zeros(4, numIntervals); % X-coordinates for all patches
            patchY = zeros(4, numIntervals); % Y-coordinates for all patches

            % Build the X and Y data for all patches at once
            for j = 1:numIntervals
                patchX(:, j) = [t0s(j); t1s(j); t1s(j); t0s(j)];
                patchY(:, j) = [yPositions(i)-0.4; yPositions(i)-0.4; yPositions(i)+0.4; yPositions(i)+0.4];
            end

            % Draw all patches for this behavior in a single call
            patch(patchX, patchY, colors(i, :), 'FaceAlpha', 0.6, 'EdgeColor', 'none');
        end

        % Step 5: Add behavior labels on the left, aligned nicely
        text(xStart, yPositions(i), behaviorLabels{i}, ...
             'Color', colors(i, :), 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    end

    % Step 6: Customize the axes to make it clean
    xlabel('Frames');
    yticks(yPositions);                 % Position Y ticks to align with rows
    yticklabels([]);                    % Hide default Y labels (labels already added manually)
    title(sprintf('Ethogram for Fly %d', flyIndex)); % Add a clean title
    grid on;                            % Add grid for better readability
    hold off;
end
