function gui_main()
    % gui_main: Main interface to generate single or group ethograms.
    %
    % It lets work with either one fly or a group.

    % Step 1: Add all subfolders to the MATLAB path
    add_project_paths();
    
    % Step 2: Select .MAT files or folders
    %         Then build the merged data across conditions/folders
    [filesNames, ~, folderTags] = extractFilesAndLabels();

    % We now load and merge all behavior data, deriving the actual behavior names
    [allBehaviorData, behaviorLabels, allConditionLabels, localIndices, minFramesAll] = ...
        extract_behavior_data_group(filesNames, folderTags);

    % "behaviorLabels" is the list of sorted behaviors from .mat content.
    behaviorFields = fieldnames(allBehaviorData);
    if isempty(behaviorFields)
        error('No behaviors were loaded. Aborting.');
    end

    % Determine how many total flies
    totalFlies = size(allBehaviorData.(behaviorFields{1}), 1);
    fprintf('\nTotal flies in merged data: %d\n', totalFlies);

    % Step 3: Ask user what type of ethogram to create
    choice = menu('Choose Ethogram Type', ...
                  'Single Fly Ethogram', ...
                  'Group Ethogram', ...
                  'Check Representativeness');

    % Single vs. multi-condition check
    multipleConditions = any(~cellfun(@isempty, folderTags));

    switch choice
        case 1
            % -----------------------------------------------------
            % HEATMAP SINGLE FLY ETHOGRAM
            % -----------------------------------------------------
            if totalFlies < 1
                disp('No flies found to plot. Exiting Single-Fly Ethogram.');
                return;
            end

            flyIndex = getFlyIndex(totalFlies);
            
            if flyIndex == 0
                % If user wants "most representative," pick from all
                [sortedFlyIndices, sortedScores] = compute_fly_representativeness(allBehaviorData, minFramesAll, totalFlies);
                globalIdx = sortedFlyIndices(1);
                bestScore = sortedScores(1);

                fprintf('\nMost representative fly => GLOBAL index = %d, score = %.2f%%\n', ...
                         globalIdx, bestScore);

                if multipleConditions && ~isempty(allConditionLabels)
                    condName = allConditionLabels{globalIdx};
                    localIdx = localIndices(globalIdx);
                    fprintf('This corresponds to condition = "%s", LOCAL index = %d.\n', ...
                             condName, localIdx);
                else
                    % Single-condition => localIdx = globalIdx
                    localIdx = globalIdx;
                    fprintf('Single-condition => globalIdx=%d, localIdx=%d.\n', ...
                             globalIdx, localIdx);
                end
            else
                globalIdx = flyIndex;
                fprintf('Selected GLOBAL index = %d.\n', globalIdx);

                if multipleConditions && ~isempty(allConditionLabels)
                    condName = allConditionLabels{globalIdx};
                    localIdx = localIndices(globalIdx);
                    fprintf('Condition = "%s", LOCAL index = %d.\n', condName, localIdx);
                else
                    localIdx = globalIdx;
                    fprintf('Single-condition => globalIdx=%d, localIdx=%d.\n', ...
                             globalIdx, localIdx);
                end
            end

            % Build a single-fly structure from the merged dataset
            singleFlyData = get_single_fly_data(allBehaviorData, behaviorLabels, globalIdx);

            % Plot the ethogram
            create_heatmap_single_ethogram(singleFlyData, localIdx, behaviorLabels);

        case 2
            % -----------------------------------------------------
            % GROUP ETHOGRAM
            % -----------------------------------------------------
            if totalFlies < 1
                disp('No flies found. Aborting Group Ethogram.');
                return;
            end

            defaultNumFlies = 10; % Default suggestion
            numFliesToAnalyze = getNumFliesToAnalyze(defaultNumFlies);
            if numFliesToAnalyze == 0
                numFliesToAnalyze = totalFlies;
            end

            [sortedFlyIndicesTest, sortedScoresTest] = ...
                compute_fly_representativeness(allBehaviorData, minFramesAll, totalFlies);

            fprintf('\nAnalyzing the following %d most representative flies:\n', numFliesToAnalyze);
            for i = 1:numFliesToAnalyze
                fprintf('  Fly Index: %d, Representativity Score: %.2f%%\n', ...
                    sortedFlyIndicesTest(i), sortedScoresTest(i));
            end

            selectedFlyIndices = sortedFlyIndicesTest(1:numFliesToAnalyze);
            create_group_ethogram(allBehaviorData, behaviorLabels, minFramesAll, selectedFlyIndices);

        case 3
            % -----------------------------------------------------
            % CHECK REPRESENTATIVENESS
            % -----------------------------------------------------
            [sortedFlyIndicesTest, sortedScoresTest] = ...
                compute_fly_representativeness(allBehaviorData, minFramesAll, totalFlies);

            fprintf('\nFlies Sorted by Representativeness:\n');
            fprintf('GlobalIdx\tCondition\tLocalIdx\tScore\n');
            for i = 1:numel(sortedFlyIndicesTest)
                gIdx  = sortedFlyIndicesTest(i);
                score = sortedScoresTest(i);

                if multipleConditions && ~isempty(allConditionLabels)
                    condName = allConditionLabels{gIdx};
                    locIdx   = localIndices(gIdx);
                else
                    condName = '-';  % SingleCondition or no condition
                    locIdx   = gIdx; % localIndices=globalIndices
                end
                fprintf('%d\t%s\t%d\t%.2f\n', gIdx, condName, locIdx, score);
            end

        otherwise
            disp('No option selected. Exiting.');
    end
end

%% Helper function to get fly index
function flyIndex = getFlyIndex(totalFlies)
    % getFlyIndex: Asks the user for a fly index or 0 for "most representative."
    dlgRes = inputdlg(sprintf('Enter Fly Index (0 for Most Representative, 1..%d):', totalFlies), ...
                      'Fly Selection', [1, 50], {'1'});
    if isempty(dlgRes)
        error('User cancelled input.');
    end

    userVal = str2double(dlgRes{1});
    if isnan(userVal) || userVal < 0 || userVal > totalFlies
        error('Invalid Fly Index.');
    end
    flyIndex = userVal;
end

%% Helper function to get number of flies to analyze for group ethogram
function numFliesToAnalyze = getNumFliesToAnalyze(maxFlies)
    dlgRes = inputdlg(sprintf('Enter number of most representative flies to analyze (0 for all, 1..%d):', maxFlies), ...
                      'Fly Count Selection', [1, 50], {'1'});
    if isempty(dlgRes)
        error('User cancelled input.');
    end

    userVal = str2double(dlgRes{1});
    if isnan(userVal) || userVal < 0 || userVal > maxFlies
        error('Invalid Number of Flies to Analyze.');
    end
    numFliesToAnalyze = userVal;
end