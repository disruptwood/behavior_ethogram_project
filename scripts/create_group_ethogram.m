function create_group_ethogram(behaviorData, behaviorLabels, minFrames, selectedFlyIndices)
    % CREATE_GROUP_ETHOGRAM: Plots a group ethogram using the image() function
    % with transparency based on the proportion of flies exhibiting each behavior.
    %
    % This function visualizes behavioral data for a group of flies over time,
    % where each behavior is represented as a row and each frame as a column.
    % The color intensity and transparency of each cell indicate the proportion
    % of selected flies performing that behavior at a given frame.
    %
    % Inputs:
    %   - behaviorData: Struct containing binary matrices for each behavior.
    %                   Each field corresponds to a behavior and contains a
    %                   [numFlies x numFrames] binary matrix, where 1 indicates
    %                   the behavior is active and 0 otherwise.
    %   - behaviorLabels: Cell array of strings specifying the names of behaviors.
    %                     The order of behaviors in this array determines the row order
    %                     in the ethogram.
    %   - minFrames: Scalar specifying the maximum number of frames to display.
    %                This ensures that all behaviors are plotted over the same frame range.
    %   - selectedFlyIndices: Vector of fly indices to include in the analysis.
    %                          These indices correspond to the rows in the binary matrices
    %                          within behaviorData.
    %
    % Example Usage:
    %   create_group_ethogram(data, {'Walking', 'Flying'}, 1000, [1, 2, 5, 7]);

    %% 1. Setup Behavior and Frame Limits
    %---------------------------------------------
    % Retrieve all behavior names present in the behaviorData struct.
    behaviorNames = fieldnames(behaviorData);
    
    % Determine the number of behaviors to plot based on the provided labels.
    numBehaviors = length(behaviorLabels);
    
    % Initialize maxFrames to minFrames to ensure uniform frame length across behaviors.
    maxFrames = minFrames;

    % Replace underscores with spaces in behaviorLabels
    behaviorLabels = strrep(behaviorLabels, '_', ' ');

    %% 2. Retrieve Behavior → Color Mapping
    %---------------------------------------------
    % Obtain a mapping from behavior names to their corresponding RGB colors.
    % If a behavior does not have a predefined color, a fallback color is used.
    [behaviorColorMap, fallbackColor] = get_behavior_colors();

    %% 3. Initialize RGB and Alpha Matrices
    %---------------------------------------------
    % Pre-allocate an RGB matrix to store color information for each behavior-frame pair.
    % Initialized to white ([1, 1, 1]) by default.
    rgbMatrix   = ones(numBehaviors, maxFrames, 3);  % [numBehaviors x maxFrames x 3]

    % Pre-allocate an Alpha matrix to store transparency values.
    % Initialized to 0 (fully transparent) by default.
    alphaMatrix = zeros(numBehaviors, maxFrames);    % [numBehaviors x maxFrames]

    %% 4. Populate RGB and Alpha Matrices
    %---------------------------------------------
    for rowIdx = 1:numBehaviors
        % Get the current behavior name based on the label.
        behName = behaviorLabels{rowIdx};
        
        % Check if the behavior exists in the behaviorData struct.
        if ismember(behName, behaviorNames)
            % Extract the binary matrix for the current behavior and selected flies.
            % Size: [numSelectedFlies x maxFrames]
            mat = behaviorData.(behName)(selectedFlyIndices, 1:maxFrames);
            
            % Calculate the proportion of selected flies exhibiting the behavior at each frame.
            % If only one fly is selected, this proportion will be either 0 or 1.
            propActive = sum(mat, 1) / length(selectedFlyIndices);
            
            % Retrieve the color for the current behavior from the color map.
            % If the behavior is not found, use the fallback color.
            if isKey(behaviorColorMap, behName)
                cColor = behaviorColorMap(behName);
            else
                cColor = fallbackColor;
            end
            
            % Iterate over each frame to assign colors and transparency.
            for f = 1:maxFrames
                if propActive(f) > 0
                    % Assign the behavior's color to the RGB matrix.
                    rgbMatrix(rowIdx, f, :) = cColor;
                    
                    % Assign the proportion active to the Alpha matrix.
                    % This determines the transparency level.
                    alphaMatrix(rowIdx, f)  = propActive(f);
                end
                % If propActive(f) == 0, the cell remains white and fully transparent.
            end
        end
        % If the behavior is not present in behaviorData, the row remains white and transparent.
    end

    %% 5. Display the RGB Matrix with Transparency using image()
    %---------------------------------------------
    % Create a new figure for the group ethogram.
    figure('Name','Group Ethogram','NumberTitle','off');
    
    % Display the RGB matrix as an image.
    % The X-axis spans from 1 to maxFrames, and the Y-axis spans from 1 to numBehaviors.
    hImg = image([1 maxFrames], [1 numBehaviors], rgbMatrix);
    
    % Set the axes to have the origin at the bottom-left.
    axis xy;
    
    % Adjust the axes limits to fit the data tightly.
    axis tight;
    
    % Hold the current plot to overlay additional properties.
    hold on;

    %% 6. Apply Transparency
    %---------------------------------------------
    % Set the AlphaData property of the image to the alphaMatrix.
    % This controls the transparency of each pixel based on propActive.
    set(hImg, 'AlphaData', alphaMatrix, 'AlphaDataMapping','none');

    %% 7. Configure X-Axis Labels
    %---------------------------------------------
    samplingRate = 30;
    timeMinutes = (1:maxFrames) / samplingRate / 60;
    xTickInterval = 5; % interval in minutes
    xTickIndices = 1:(samplingRate * 60 * xTickInterval):maxFrames;
    xTickLabels = round(timeMinutes(xTickIndices), 1);
    
    set(gca, 'XTick', xTickIndices, ...
             'XTickLabel', arrayfun(@(v) sprintf('%.1f', v), xTickLabels, 'UniformOutput', false));
    xlabel('Minutes');


    %% 8. Configure Y-Axis Labels
    %---------------------------------------------
    % Set Y-axis ticks corresponding to each behavior row.
    set(gca, 'YTick', 1:numBehaviors, 'YTickLabel', behaviorLabels);
    
    %% 9. Final Formatting
    %---------------------------------------------
    % Add a title to the ethogram with bold font weight.
    title('Group Ethogram', 'FontWeight','bold');
    
    % Set the font size for readability and adjust tick direction.
    set(gca, 'FontSize', 10, 'TickDir','out');
    
    % Release the hold on the current plot.
    hold off;
end
