function gui_main()
    % gui_main: Main interface to generate single or group ethograms.
    %
    % I created this simple GUI to pick files and create ethograms
    % through a simple menu. It lets you work with either one fly or a group.

    % Step 1: Add all subfolders to the MATLAB path
    add_project_paths();
    
    % Step 2: Select behavior files and get behavior details
    [filesNames, behaviorLabels, numFlies] = extractFilesAndLabels();
    %fprintf('Found %d flies and %d behaviors:\n', numFlies, length(behaviorLabels));
    %disp(behaviorLabels); % Show behavior labels in the Command Window

    % Step 3: Ask user what type of ethogram to create
    choice = menu('Choose Ethogram Type', ...
                  'Single Fly Ethogram', ...
                  'Group Ethogram', ...
                  'Check Representativeness');

    % Step 4: Execute corresponding option
    if choice == 1
        % Heatmap Single Fly Ethogram
        flyIndex = getFlyIndex(numFlies);
        
        if flyIndex == 0
            % Compute representativeness
            [behaviorData, minFrames] = extract_behavior_data_group(filesNames);
            maxFliesTest = numFlies;
            [sortedFlyIndicesTest, sortedScoresTest] = compute_fly_representativeness(behaviorData, minFrames, maxFliesTest);
            flyIndex = sortedFlyIndicesTest(1); % Most representative fly
            fprintf('The most representative fly is %d with representativity score %.2f%%. Building ethogram...\n', flyIndex, sortedScoresTest(1));
        else
            fprintf('Selected fly index is %d. Building ethogram...\n', flyIndex);
        end
        
        % Extract and process the data for the selected fly
        behaviorData = extract_behavior_data(filesNames, flyIndex);
        create_heatmap_single_ethogram(behaviorData, flyIndex, behaviorLabels);

    elseif choice == 2
        % Group Ethogram
        defaultNumFlies = 10; % Default suggestion
        numFliesToAnalyze = getNumFliesToAnalyze(defaultNumFlies);
        if numFliesToAnalyze == 0
            numFliesToAnalyze = numFlies;
        end
        
        % Extract behavior data and compute representativeness
        [behaviorData, ~, minFrames] = extract_behavior_data_group(filesNames);
        maxFliesTest = numFlies;
        [sortedFlyIndicesTest, sortedScoresTest] = compute_fly_representativeness(behaviorData, minFrames, maxFliesTest);
    
        % Display selected flies and their representativity scores
        fprintf('Analyzing the following %d most representative flies:\n', numFliesToAnalyze);
        for i = 1:numFliesToAnalyze
            fprintf('  Fly Index: %d, Representativity Score: %.2f%%\n', sortedFlyIndicesTest(i), sortedScoresTest(i));
        end
    
        % Create group ethogram using selected fly indices
        selectedFlyIndices = sortedFlyIndicesTest(1:numFliesToAnalyze);
        create_group_ethogram(behaviorData, behaviorLabels, minFrames, selectedFlyIndices);

    elseif choice == 3
        % Representativeness
        if ~iscell(filesNames)  % Ensure filesNames is a cell array
            filesNames = {filesNames};
        end
        
        % Extract behavior data, number of flies, and minimal frame count
        [behaviorData, minFrames] = extract_behavior_data_group(filesNames);
        
        % Compute representativeness
        maxFliesTest = numFlies;
        [sortedFlyIndicesTest, sortedScoresTest] = compute_fly_representativeness(behaviorData, minFrames, maxFliesTest);
        
        % Display sorted list for the first three flies
        fprintf('\nFirst 10 Flies Sorted by Representativeness:\n');
        fprintf('Fly\tRepresentativeness Score\n');
        fprintf('---\t-----------------------\n');
        for i = 1:length(sortedFlyIndicesTest)
            flyNum = sortedFlyIndicesTest(i);
            score = sortedScoresTest(i);
            fprintf('%d\t%.2f\n', flyNum, score);
        end
    else
        % Exit if no option is selected
        disp('No option selected. Exiting.');
    end
end

%% Helper function to get fly index
function flyIndex = getFlyIndex(numFlies)
    % Ask for the fly index and ensure it is valid
    flyIndex = inputdlg('Enter Fly Index (0 for Most Representative, 1-based):', ...
                         'Fly Selection', [1, 50], {'1'});
    flyIndex = str2double(flyIndex{1});
    if isnan(flyIndex) || flyIndex < 0 || flyIndex > numFlies
        error('Invalid Fly Index.');
    end
end
%% Helper function to get num of most representative flies
function numFliesToAnalyze = getNumFliesToAnalyze(maxFlies)
    % Ask for the number of flies to analyze and ensure it is valid
    numFliesToAnalyze = inputdlg('Enter number of most representative flies to analyze (0 for all, 1-based):', ...
                                  'Fly Count Selection', [1, 50], {'1'});
    numFliesToAnalyze = str2double(numFliesToAnalyze{1});
    if isnan(numFliesToAnalyze) || numFliesToAnalyze < 0 || numFliesToAnalyze > maxFlies
        error('Invalid Number of Flies to Analyze.');
    end
end
