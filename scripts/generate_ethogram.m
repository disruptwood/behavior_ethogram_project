function generate_ethogram()
    [filesNames, behaviorLabels, ~] = extractFilesAndLabels();

    choice = menu('Choose Ethogram Type', 'Single Fly', 'Group Ethogram');

    if choice == 1
        flyIndex = inputdlg('Enter Fly Index:', 'Fly Selection', [1, 35], {'1'});
        flyIndex = str2double(flyIndex{1});
        
        behaviorData = extract_behavior_data(filesNames, flyIndex);
        create_single_ethogram(behaviorData, flyIndex, behaviorLabels);
    else
        [behaviorData, ~, minFrames] = extract_behavior_data_group(filesNames);
        create_group_ethogram(behaviorData, behaviorLabels, minFrames);
    end
end
