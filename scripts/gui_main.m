function gui_main()
    % gui_main: Main interface to generate single or group ethograms.
    %
    % I created this simple GUI to pick files and create ethograms
    % through a simple menu. It lets you work with either one fly or a group.

    % Step 1: Add all subfolders to the MATLAB path
    add_project_paths();
    
    % Step 2: Select behavior files and get behavior details
    [filesNames, behaviorLabels, numFlies] = extractFilesAndLabels();
    fprintf('Found %d flies and %d behaviors:\n', numFlies, length(behaviorLabels));
    disp(behaviorLabels); % Show behavior labels in the Command Window

    % Step 3: Ask user what type of ethogram to create
    choice = menu('Choose Ethogram Type', ...
                  'Single Fly Ethogram', ...
                  'Color Single Fly Ethogram', ...
                  'Heatmap Single Fly Ethogram', ...
                  'Group Ethogram');

    % Step 4: Execute corresponding option
    if choice == 1
        % Single Fly Ethogram
        flyIndex = getFlyIndex(numFlies);
        behaviorData = extract_behavior_data(filesNames, flyIndex);
        create_single_ethogram(behaviorData, flyIndex, behaviorLabels);

    elseif choice == 2
        % Color Single Fly Ethogram
        flyIndex = getFlyIndex(numFlies);
        behaviorData = extract_behavior_data(filesNames, flyIndex);
        color_single_ethogram(behaviorData, flyIndex, behaviorLabels);

    elseif choice == 3
        % Heatmap Single Fly Ethogram
        flyIndex = getFlyIndex(numFlies);
        behaviorData = extract_behavior_data(filesNames, flyIndex);
        heatmap_single_ethogram(behaviorData, flyIndex, behaviorLabels);

    elseif choice == 4
        % Group Ethogram
        if ~iscell(filesNames)  % Ensure filesNames is a cell array
            filesNames = {filesNames};
        end
        [behaviorData, ~, minFrames] = extract_behavior_data_group(filesNames);
        create_group_ethogram(behaviorData, behaviorLabels, minFrames);

    else
        % Exit if no option is selected
        disp('No option selected. Exiting.');
    end
end

%% Helper function to get fly index
function flyIndex = getFlyIndex(numFlies)
    % Ask for the fly index and ensure it is valid
    flyIndex = inputdlg('Enter Fly Index (1-based):', 'Fly Selection', [1, 35], {'1'});
    flyIndex = str2double(flyIndex{1});
    if isnan(flyIndex) || flyIndex < 1 || flyIndex > numFlies
        error('Invalid Fly Index.');
    end
end
