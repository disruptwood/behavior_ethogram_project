function singleFlyStruct = get_single_fly_data(mergedData, behaviorLabels, flyIdx)
    % get_single_fly_binary_data:
    %   Creates a structure for a single fly’s behaviors using
    %   binary arrays (1 = behavior is ON, 0 = behavior is OFF).
    %
    % Parameters:
    %   mergedData     - Struct of behavior fields => [numFlies x numFrames].
    %                    For each behavior B, mergedData.(B) is a matrix.
    %   behaviorLabels - Cell array of behavior names to include.
    %   flyIdx         - 1-based index of the fly in the merged dataset.
    %
    % Returns:
    %   singleFlyStruct.(behaviorName) = a 1 x numFrames binary array.

    singleFlyStruct = struct();

    for b = 1:numel(behaviorLabels)
        bName = behaviorLabels{b};

        if ~isfield(mergedData, bName)
            % Behavior not found in mergedData; skip or create zero array
            warning('Behavior "%s" not found in mergedData. Skipping.', bName);
            continue;
        end

        % Extract the single row corresponding to this fly
        % => 1 x numFrames binary array
        rowData = mergedData.(bName)(flyIdx, :);

        % Store it directly in singleFlyStruct under .(bName)
        singleFlyStruct.(bName) = rowData;
    end
end
