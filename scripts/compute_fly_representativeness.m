function [sortedFlyIndices, sortedScores, groupSimilarity] = compute_fly_representativeness(behaviorData, minFrames, maxFlies)
% COMPUTE_FLY_REPRESENTATIVENESS:
%   1) Filters behaviorData to keep only the behaviors: Walk, Stop, Turn, Touch, Grooming.
%   2) Calculates a representativeness index (0..100) for each fly based on how
%      closely it matches the average behavior across these filtered behaviors,
%      using a rarity-based weighting but ignoring extremely rare behaviors.
%   3) Also computes a groupSimilarity (0..100) that summarizes how homogeneous
%      the entire set of flies is, on average.
%
%   Inputs:
%       behaviorData:  Struct of binary matrices [numFlies x numFrames]. Each field is a behavior.
%       minFrames:     The minimum number of frames to consider across all behaviors.
%       maxFlies:      (Optional) Max number of flies to include (e.g., 3 for testing).
%                      If omitted or empty, all flies are processed.
%
%   Outputs:
%       sortedFlyIndices: Indices of flies sorted by descending representativeness.
%       sortedScores:     Representativeness scores in [0..100], one per fly.
%       groupSimilarity:  Mean of all flies' representativeness (0..100).

    if nargin < 3 || isempty(maxFlies)
        maxFlies = inf;
    end

    %-----------------------------------------------------------
    % 0) Keep ONLY these behaviors, remove everything else
    %-----------------------------------------------------------
    allowedBehaviors = {'Walk','Stop','Turn','Touch','Grooming'};
    allBehaviorNames = fieldnames(behaviorData);
    keepMask  = ismember(allBehaviorNames, allowedBehaviors);
    keepNames = allBehaviorNames(keepMask);

    % Remove any behaviors not in keepNames
    rmNames = setdiff(allBehaviorNames, keepNames);
    for i = 1:numel(rmNames)
        behaviorData = rmfield(behaviorData, rmNames{i});
    end

    % If no present, return everything at 100%
    if isempty(fieldnames(behaviorData))
        warning('No matching behaviors found among Walk, Stop, Turn, Touch, Grooming. Returning all flies at 100%.');
        sortedFlyIndices = (1:maxFlies).';
        sortedScores     = 100 * ones(length(sortedFlyIndices), 1);
        groupSimilarity  = 100;
        return;
    end

    %-----------------------------------------------------------
    % 1) Prepare Variables & 3D Arrays
    %-----------------------------------------------------------
    behaviorNames = fieldnames(behaviorData);
    numBehaviors  = length(behaviorNames);
    numFlies      = size(behaviorData.(behaviorNames{1}), 1);
    numFrames     = minFrames;
    numFliesUsed  = min(maxFlies, numFlies);

    % bigData: [behavior x fly x frame], storing 0/1
    bigData = false(numBehaviors, numFliesUsed, numFrames);

    for b = 1:numBehaviors
        matB = behaviorData.(behaviorNames{b});
        if size(matB, 2) < numFrames
            error('Behavior "%s" has fewer frames (%d) than minFrames (%d).', ...
                  behaviorNames{b}, size(matB, 2), numFrames);
        end
        bigData(b, :, :) = reshape(matB(1:numFliesUsed, 1:numFrames), [1, numFliesUsed, numFrames]);
    end

    %-----------------------------------------------------------
    % 2) Compute average fraction for each (behavior, frame)
    %-----------------------------------------------------------
    sumActive = sum(bigData, 2);            % sum over flies => [behavior x 1 x frame]
    avgFrac   = double(sumActive) / numFliesUsed;  % => fraction active

    %-----------------------------------------------------------
    % 3) Rare-Behavior Handling
    %    If fractionOfTime < rarityThreshold => weight = 0 (ignore)
    %    Otherwise, weight = 1/(fractionOfTime + eps)
    %-----------------------------------------------------------
    rarityThreshold = 0.01;  % 1% threshold
    behaviorWeights = zeros(numBehaviors, 1);

    for b = 1:numBehaviors
        totalOnes       = sum(sum(bigData(b,:,:), 3), 2);
        fractionOfTimeB = double(totalOnes) / (numFliesUsed * numFrames);
        if fractionOfTimeB < rarityThreshold
            behaviorWeights(b) = 0;  % too rare => ignore
        else
            behaviorWeights(b) = 1 / (fractionOfTimeB + eps);
        end
    end

    % Normalize only non-zero weights so their average = 1
    nonzeroMask = (behaviorWeights > 0);
    if any(nonzeroMask)
        nonzeroWeights = behaviorWeights(nonzeroMask);
        meanW = mean(nonzeroWeights);
        nonzeroWeights = nonzeroWeights / meanW;  % scale so average = 1
        behaviorWeights(nonzeroMask) = nonzeroWeights;
    end

    %-----------------------------------------------------------
    % 4) Weighted Distance Computation
    %-----------------------------------------------------------
    weights3D       = repmat(reshape(behaviorWeights, [numBehaviors, 1, 1]), [1, numFliesUsed, numFrames]);
    avgFracExpanded = repmat(avgFrac, [1, numFliesUsed, 1]); 

    distance3D        = abs(double(bigData) - avgFracExpanded); 
    weightedDistances = distance3D .* weights3D;                

    sumDistance = sum(weightedDistances, 1);  % sum over behaviors => [1 x f x t]
    sumDistance = sum(sumDistance, 3);        % sum over frames => [1 x f]
    sumDistance = squeeze(sumDistance);       % => [f x 1]

    %-----------------------------------------------------------
    % 5) Convert Weighted Distance => Representativeness
    %-----------------------------------------------------------
    effectiveBehaviors = sum(behaviorWeights > 0);
    if effectiveBehaviors == 0
        % Edge case: all behaviors are too rare => everything is 100
        representativeness = 100 * ones(numFliesUsed, 1);
    else
        totalWeightedPoints = effectiveBehaviors * numFrames;
        avgDiff = sumDistance / totalWeightedPoints; 
        representativeness = (1 - avgDiff) * 100;  % in [0..100]
    end

    %-----------------------------------------------------------
    % 6) Sort by Descending Representativeness
    %-----------------------------------------------------------
    [sortedScores, localIndices] = sort(representativeness, 'descend');
    allIndices       = 1:numFliesUsed;
    sortedFlyIndices = allIndices(localIndices).';

    sortedScores     = sortedScores(:);       % column vector

    %-----------------------------------------------------------
    % 7) Compute "Absolute" Group Similarity
    %    A simple global measure: the mean of all flies' representativeness.
    %-----------------------------------------------------------
    groupSimilarity = mean(representativeness);

    % Print to console
    fprintf('Overall group similarity (mean representativeness): %.2f%%\n', groupSimilarity);
end
