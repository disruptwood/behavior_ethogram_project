function create_group_ethogram(behaviorData, behaviorLabels, minFrames)
    % create_group_ethogram: Draws a group ethogram using patches, similar in style to the single ethogram.
    % 
    % Inputs:
    %   - behaviorData: Struct with binary matrices [numFlies x numFrames] for each behavior.
    %   - behaviorLabels: Cleaned behavior names to display on the left.
    %   - minFrames: Max number of frames to display (to ensure uniform length).

    % Step 1: Extract behavior names and set up general properties
    behaviorNames = fieldnames(behaviorData);       % Names of all behaviors
    numBehaviors = length(behaviorNames);           % Total number of behaviors
    numFlies = size(behaviorData.(behaviorNames{1}), 1); % Number of flies
    
    % Limit the frames to display to avoid exceeding data bounds
    maxFrames = minFrames;                         
    for bIdx = 1:numBehaviors
        maxFrames = min(maxFrames, size(behaviorData.(behaviorNames{bIdx}), 2));
    end

    % Step 2: Generate colors for behaviors (same as single ethogram)
    colors = lines(numBehaviors);                   % Get a list of unique colors for each behavior

    % Step 3: Align the behavior labels to a specific X-position (before the ethogram starts)
    xStart = -0.05 * maxFrames;                     % Offset for labels to align nicely to the left

    % Step 4: Set up the figure for the group ethogram
    figure('Name', 'Group Ethogram', 'NumberTitle', 'off');
    hold on;

    % Step 5: Assign Y positions to each behavior (top to bottom layout)
    yPositions = 1:numBehaviors;                   % Position each behavior in its row

    % Step 6: Loop through each behavior to draw the patches
    for bIdx = 1:numBehaviors
        behaviorName = behaviorNames{bIdx};        % Current behavior name
        behaviorMatrix = behaviorData.(behaviorName)(:, 1:maxFrames); % Behavior binary matrix

        % Calculate how many flies exhibit this behavior at each time point
        f = sum(behaviorMatrix, 1) / numFlies;     % Proportion of flies active (0 to 1)
        
        % Set the Y-position for this behavior
        y = yPositions(bIdx);

        % Step 7: Plot behavior intervals as patches
        % I plot now one patch per frame where the behavior occurs (with transparency) 
        % its very not effective...
        for frameIdx = 1:maxFrames
            if f(frameIdx) > 0  % Only plot when at least one fly is active
                % Define X and Y coordinates for the patch
                patchX = [frameIdx-0.5, frameIdx+0.5, frameIdx+0.5, frameIdx-0.5];
                patchY = [y-0.4, y-0.4, y+0.4, y+0.4];
                
                % Plot the patch with transparency based on the proportion of flies
                patch(patchX, patchY, colors(bIdx, :), 'FaceAlpha', f(frameIdx), ...
                      'EdgeColor', 'none');
            end
        end

        % Step 8: Add behavior name label aligned to the left of the ethogram
        % This keeps it readable and looks cleaner
        text(xStart, y, behaviorLabels{bIdx}, ...
             'Color', colors(bIdx, :), 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
    end

    % Step 9: Customize the axes
    xlabel('Frames');
    yticks(yPositions);                            % Y-axis ticks at each behavior row
    yticklabels([]);                               % Hide default labels
    ylim([0.5, numBehaviors + 0.5]);               % Ensure spacing for all behavior rows
    xlim([0, maxFrames]);                          % Limit the X-axis to the frame range
    title('Group Ethogram');
    grid on;                                       % Add grid lines
    hold off;
end
