function [behaviorData, behaviorLabels, conditionLabels, localIndices, minFrames] = ...
    extract_behavior_data_group(filesNames, folderTags)
    % This function:
    %   1) Loops over each condition (folder).
    %   2) Builds a "temp" struct for that folder, storing behaviors of the same N flies.
    %   3) Appends exactly N rows once for that folder, rather than N per .mat file.
    %   4) Merges with other conditions the same way.

    if nargin < 2, folderTags = repmat({''}, size(filesNames)); end

    behaviorData    = struct();
   % behaviorLabels  = {};
    conditionLabels = {};
    localIndices    = [];

    multipleConditions = any(~cellfun(@isempty, folderTags));
    if multipleConditions
        uniqueConds = unique(folderTags);
    else
        uniqueConds = {''};  % single condition => one folder
    end

    %----------------------------------------
    % 1) Determine minFrames across all files
    %----------------------------------------
    minFrames = inf;
    for i = 1:numel(filesNames)
        fName = filesNames{i};
        lData = load(fName, 'allScores', 'behaviorName');
        if ~isfield(lData,'allScores')|| ~isfield(lData.allScores,'postprocessed'), continue; end
        pp = lData.allScores.postprocessed;
        if ~iscell(pp)||isempty(pp), continue; end

        firstFly = pp{1};
        if isnumeric(firstFly) || islogical(firstFly)
            minFrames = min(minFrames, length(firstFly));
        end
    end
    if isinf(minFrames)
        error('No valid data found. minFrames=inf');
    end

    %----------------------------------------
    % 2) For each condition, do a "block approach"
    %----------------------------------------
    % We'll gather all behaviors for the same N flies in a "temp" struct, 
    % then append exactly N rows at once to the global structure.

    for c = 1:numel(uniqueConds)
        cond = uniqueConds{c};
        condIdx   = strcmp(folderTags, cond);
        condFiles = filesNames(condIdx);
        if isempty(condFiles), continue; end

        % We assume each .mat in this folder references the SAME set of N flies
        % (the user says so). We'll discover N from the *first* .mat in that folder.
        lDataFirst = load(condFiles{1}, 'allScores', 'behaviorName');
        ppFirst = lDataFirst.allScores.postprocessed;
        numFliesCondition = numel(ppFirst);  % e.g. 10

        %----------------------------------------
        % Initialize a "tempBehavior" struct for this folder
        % Each field => [N x minFrames]
        % Fill with false(0) => we expand to [N x minFrames] in place
        %----------------------------------------
        tempBehavior = struct();

        % We'll store the final # behaviors after reading all .mat in this folder
        bNamesFolder = {};

        %----------------------------------------
        % Read each .mat in this condition
        %----------------------------------------
        for f = 1:numel(condFiles)
            fName = condFiles{f};
            lData = load(fName, 'allScores', 'behaviorName');
            if ~isfield(lData,'allScores')|| ~isfield(lData.allScores,'postprocessed'), continue; end
            if ~isfield(lData,'behaviorName'), continue; end

            bName = lData.behaviorName;
            postprocessed = lData.allScores.postprocessed;
            nFliesFile = numel(postprocessed);
            if nFliesFile ~= numFliesCondition
                warning('File %s has %d flies, but condition claims %d. Skipping.', ...
                         fName, nFliesFile, numFliesCondition);
                continue;
            end

            % Build a block [N x minFrames]
            newBlock = false(numFliesCondition, minFrames);
            for ff = 1:numFliesCondition
                flyData = postprocessed{ff};
                flyLen  = length(flyData);
                if flyLen>minFrames
                    flyData = flyData(1:minFrames);
                elseif flyLen<minFrames
                    padded = false(1,minFrames);
                    padded(1:flyLen) = flyData(:)';
                    flyData = padded;
                else
                    flyData = flyData(:)';
                end
                newBlock(ff,:) = logical(flyData);
            end

            if ~isfield(tempBehavior, bName)
                tempBehavior.(bName) = newBlock;
                bNamesFolder{end+1} = bName; %#ok<AGROW>
            else
                % It's possible that each .mat just duplicates the same bName, but 
                % typically you have different bName => 'Grooming','Jump', etc.
                % If it's the same bName repeated, you might decide how to handle that 
                % (either skip or unify). For now, let's skip re-adding:
                warning('Behavior %s found multiple times in the same condition. Overwriting.', bName);
                tempBehavior.(bName) = newBlock;
            end
        end

        %----------------------------------------
        % 3) Now we have "tempBehavior" => each field is [N x minFrames]
        %    That means we have N flies in this condition, with however many behaviors.
        %----------------------------------------

        % We'll now append exactly N new rows in the global structure.
        % localIndices will run from 1..N for this condition (or from startCount+1..startCount+N).
        % conditionLabels likewise. This ensures we only have N new rows, not N per file.

        if ~isfield(behaviorData, 'placeholder') 
            % just to avoid an empty struct edge case if you like
            behaviorData.placeholder = false(0,minFrames); 
            behaviorData = rmfield(behaviorData,'placeholder');
        end

        % a) Find how many flies we have so far in global => used for indexing if needed
        %globalStart = size(behaviorData.(bNamesFolder{1}),1) + 1; 
        % if you do it by the first known bName's row count

        % b) If multiple conditions => local indices start at 1..N for this folder
        for ff = 1:numFliesCondition
            conditionLabels{end+1,1} = cond;          %#ok<AGROW>
            localIndices(end+1,1)    = ff;           %#ok<AGROW>
        end

        % c) Merge the behaviors from tempBehavior into behaviorData
        %    If a behavior is new to the global structure, create an empty block first.
        folderBehNames = fieldnames(tempBehavior);
        for b = 1:numel(folderBehNames)
            bName = folderBehNames{b};
            if ~isfield(behaviorData,bName)
                behaviorData.(bName) = false(0,minFrames);
            end
            % Now append the [N x minFrames] block from tempBehavior
            block = tempBehavior.(bName);
            behaviorData.(bName) = [behaviorData.(bName); block];
        end
    end

    %----------------------------------------
    % 4) Build the final behaviorLabels from all fields in behaviorData
    %    If you want them in a certain order, reorder them after
    %----------------------------------------
    allBehNames = fieldnames(behaviorData);
    % Reorder them by getPredefinedOrder
    bOrder = getPredefinedOrder();
    inOrder = intersect(bOrder, allBehNames, 'stable');
    remainder = setdiff(allBehNames,bOrder,'stable');
    behaviorLabels = [inOrder; remainder];
end
