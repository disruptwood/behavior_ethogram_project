function create_heatmap_single_ethogram(behaviorData, flyIndex, behaviorLabels)
% CREATE_HEATMAP_SINGLE_ETHOGRAM:
%   Plots a single-fly ethogram as a color-by-behavior map:
%   - Each row corresponds to one behavior, each column = one frame.
%   - If the fly performs behavior b at frame f, the cell is colored with
%     that behavior’s color; otherwise, it is white.
%   - The x-axis is labeled in multiples of 5 minutes, and the y-axis
%     shows behavior names.
%
% Inputs:
%   behaviorData.(behName) : a 2D binary matrix (#flies x #frames)
%   flyIndex : index of fly in specific condition
%   behaviorLabels         : cell array of behavior names in desired row order

%---------------------------------------------
% 1) Retrieve Behavior → Color Mapping
%---------------------------------------------
[behaviorColorMap, fallbackColor] = get_behavior_colors();

%---------------------------------------------
% 2) Determine the maximum number of frames across all requested behaviors
%---------------------------------------------
numBehaviors = length(behaviorLabels);
maxFrames    = 0;

% Replace underscores with spaces in behaviorLabels
behaviorLabels = strrep(behaviorLabels, '_', ' ');

for i = 1:numBehaviors
    behName = behaviorLabels{i};
    if isfield(behaviorData, behName)
        % #frames is size(behaviorData.(behName), 2)
        maxFrames = max(maxFrames, size(behaviorData.(behName), 2));
    end
end

% If no behaviors found or maxFrames = 0, just return
if maxFrames == 0
    warning('No valid frames found for the specified behaviors. Nothing to plot.');
    return;
end

%---------------------------------------------
% 3) Build the [numBehaviors x maxFrames x 3] RGB array
%    Initialize to white (1,1,1). We'll color any 1s in the binary array.
%---------------------------------------------
rgbMatrix = ones(numBehaviors, maxFrames, 3);  % all white

for rowIdx = 1:numBehaviors
    behName = behaviorLabels{rowIdx};
    if isfield(behaviorData, behName)
        % Look up color or use fallback
        if isKey(behaviorColorMap, behName)
            cColor = behaviorColorMap(behName);
        else
            cColor = fallbackColor;
        end
        
        % Extract the binary array for this behavior (only one row exists)
        framesBinary = behaviorData.(behName);
        
        % If framesBinary is shorter than maxFrames, pad with zeros (safety check)
        if length(framesBinary) < maxFrames
            framesBinary = [framesBinary, zeros(1, maxFrames - length(framesBinary))];
        end
        
        % Fill in the color for frames where framesBinary == 1
        activeFrames = find(framesBinary == 1);
        for f = activeFrames
            rgbMatrix(rowIdx, f, :) = cColor;
        end
    end
end

%---------------------------------------------
% 4) Display the RGB array as an image
%---------------------------------------------
figure('Name', sprintf('Ethogram for Fly %d', flyIndex), ...
       'NumberTitle', 'off');
image([1 maxFrames], [1 numBehaviors], rgbMatrix);

axis xy;    % row=1 at the bottom
axis tight; % fit axes to data range

%---------------------------------------------
% 5) X-axis labeling in "Time (minutes)"
%---------------------------------------------
samplingRate = 30;  % frames per second (example)
timeMinutes = (1:maxFrames) / samplingRate / 60;
xTickInterval = 5;  % interval in minutes
xTickIndices  = 1:(samplingRate * 60 * xTickInterval):maxFrames;
xTickLabels   = round(timeMinutes(xTickIndices), 1);

set(gca, 'XTick', xTickIndices, ...
         'XTickLabel', arrayfun(@(v) sprintf('%d', v), xTickLabels, 'UniformOutput', false));
xlabel('Minutes');

%---------------------------------------------
% 6) Y-axis: each row = one behavior
%---------------------------------------------
set(gca, 'YTick', 1:numBehaviors, 'YTickLabel', behaviorLabels);

%---------------------------------------------
% 7) Final formatting
%---------------------------------------------
title(sprintf('Ethogram for Fly %d', flyIndex), 'FontWeight','bold');
set(gca, 'FontSize', 10, 'TickDir','out');
end
