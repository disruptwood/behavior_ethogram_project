function another_create_single_ethogram(behaviorData, flyIndex, behaviorLabels, scheme)
    % another_plot_single_ethogram: Plots a single ethogram using a color scheme 
    % inspired by activity, exploration, and sociality metrics.
    %
    % Inputs:
    %   - behaviorData: Struct containing binary matrices [numFrames].
    %   - flyIndex: Fly index to display.
    %   - behaviorLabels: Cleaned behavior names for display.
    %   - scheme: Color scheme to use ('basic', 'yrb', 'rgb').
    %
    % Outputs:
    %   A visually enhanced ethogram plot for a single fly.

    % Step 1: Preprocess and validate inputs
    behaviorNames = fieldnames(behaviorData.behaviors);
    numBehaviors = length(behaviorNames);
    numFrames = length(behaviorData.behaviors.(behaviorNames{1}).t0s);

    if isempty(behaviorNames)
        error('No behavior data found for fly index %d.', flyIndex);
    end
    
    % Step 2: Color schemes
    switch scheme
        case 'basic'
            colorMap = lines(numBehaviors);  % Default MATLAB lines colors
        case 'yrb'
            colorMap = [1 1 0; 1 0 0; 0 0 1]; % Yellow, Red, Blue
        case 'rgb'
            colorMap = [1 0 0; 0 1 0; 0 0 1]; % Red, Green, Blue
        otherwise
            error('Invalid color scheme. Choose "basic", "yrb", or "rgb".');
    end

    % Step 3: Create figure
    figure('Name', sprintf('Enhanced Ethogram for Fly %d', flyIndex), 'NumberTitle', 'off');
    hold on;
    yPositions = 1:numBehaviors;  % Y positions for each behavior row

    % Step 4: Plot behavior data as color-coded patches
    for i = 1:numBehaviors
        behaviorName = behaviorNames{i};
        t0s = behaviorData.behaviors.(behaviorName).t0s;
        t1s = behaviorData.behaviors.(behaviorName).t1s;

        % Plot patches for each behavior segment
        if ~isempty(t0s) && ~isempty(t1s)
            for j = 1:length(t0s)
                patchX = [t0s(j), t1s(j), t1s(j), t0s(j)];
                patchY = [yPositions(i)-0.4, yPositions(i)-0.4, yPositions(i)+0.4, yPositions(i)+0.4];
                patch(patchX, patchY, colorMap(mod(i-1, size(colorMap, 1)) + 1, :), ...
                      'EdgeColor', 'none', 'FaceAlpha', 0.7);
            end
        end

        % Add behavior labels aligned to the left
        text(-0.05 * numFrames, yPositions(i), behaviorLabels{i}, ...
            'Color', 'k', 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    end

    % Step 5: Final formatting
    xlabel('Frames');
    yticks(yPositions);
    yticklabels([]); % Hide ticks; labels are already on the left
    ylim([0.5, numBehaviors + 0.5]);
    xlim([0, numFrames]);
    title(sprintf('Enhanced Single Ethogram for Fly %d', flyIndex));
    grid on;
    hold off;
end
