function create_heatmap_single_ethogram(behaviorData, flyIndex, behaviorLabels)
% CREATE_HEATMAP_SINGLE_ETHOGRAM:
%   Plots a single-fly ethogram as a color-by-behavior map:
%   - Each row corresponds to one behavior, each column = one frame.
%   - If the fly performs behavior b at frame f, the cell is colored with
%     that behavior’s color; otherwise, it is white.
%   - The x-axis is labeled in multiples of 10^4 frames, and the y-axis
%     shows behavior names.
%
% Inputs:
%   behaviorData.behaviors.(behaviorName).t0s / t1s: start/end frames for each behavior
%   flyIndex: identifier for the current fly (used in figure title)
%   behaviorLabels: cell array of behavior names in the desired row order
%
% Requirements:
%   - Each behavior name in behaviorLabels should appear as a field in
%     behaviorData.behaviors, or else the row will remain white.

%---------------------------------------------
% 1) Retrieve Behavior → Color Mapping
%---------------------------------------------
[behaviorColorMap, fallbackColor] = get_behavior_colors();

%---------------------------------------------
% 2) Determine the maximum frame across all behaviors
%---------------------------------------------
behaviorNames = fieldnames(behaviorData.behaviors);
numBehaviors  = length(behaviorLabels);  % how many rows to plot
maxFrames     = 0;
for i = 1:numBehaviors
    if ismember(behaviorLabels{i}, behaviorNames)
        t1s = behaviorData.behaviors.(behaviorLabels{i}).t1s;
        if ~isempty(t1s)
            maxFrames = max(maxFrames, max(t1s));
        end
    end
end

%---------------------------------------------
% 3) Build the [numBehaviors x maxFrames x 3] RGB array
%    Initialize to white. Then fill color for each behavior’s intervals.
%---------------------------------------------
rgbMatrix = ones(numBehaviors, maxFrames, 3);  % all white

for rowIdx = 1:numBehaviors
    behName = behaviorLabels{rowIdx};
    if ismember(behName, behaviorNames)
        % Look up color or use fallback
        if isKey(behaviorColorMap, behName)
            cColor = behaviorColorMap(behName);
        else
            cColor = fallbackColor;
        end

        t0s = behaviorData.behaviors.(behName).t0s;
        t1s = behaviorData.behaviors.(behName).t1s;

        for j = 1:length(t0s)
            startF = max(1, t0s(j));
            endF   = min(maxFrames, t1s(j));

            % Fill [rowIdx, startF..endF, :] with the color
            for f = startF:endF
                rgbMatrix(rowIdx, f, :) = cColor;
            end
        end
    end
end

%---------------------------------------------
% 4) Display the RGB array as an image
%---------------------------------------------
figure('Name', sprintf('Ethogram for Fly %d', flyIndex), ...
       'NumberTitle', 'off');
% Plot with x from [1..maxFrames], y from [1..numBehaviors]
image([1 maxFrames], [1 numBehaviors], rgbMatrix);

axis xy;    % Keep row 1 at top or bottom? "axis xy" puts row=1 at bottom
axis tight; % Fit axes to data range

%---------------------------------------------
% 5) X-axis labeling in "Time (minutes)"
%---------------------------------------------
samplingRate = 30;
timeMinutes = (1:maxFrames) / samplingRate / 60;
xTickInterval = 5; % interval in minutes
xTickIndices = 1:(samplingRate * 60 * xTickInterval):maxFrames;
xTickLabels = round(timeMinutes(xTickIndices), 1);

set(gca, 'XTick', xTickIndices, ...
         'XTickLabel', arrayfun(@(v) sprintf('%.1f', v), xTickLabels, 'UniformOutput', false));
xlabel('Time (minutes)');


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
