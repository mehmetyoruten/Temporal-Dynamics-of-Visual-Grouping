function [segments] = NormMinCut(numDots, numIntensities, intensityMap, intensityDots, posDots, r, sigma_I, sigma_X, nCutThr)
%NORMMINCUT Given the parameters r, sigma_I, sigma_X, and nCut Threshold,
% calculate recursive normalized minimum cut.
%   Detailed explanation goes here

clear segments

%% Initial bipartition
segLevel = 0;
numSegments = 0;
numCuts = 0;

% Compute total number of dots
N = numDots^2;

% Flatten the intensity array for easier computations
intensityDots = reshape(intensityDots, [N,1]);

% Transform intensity keys to values
for i=1:length(intensityMap)
    intensityDots(intensityDots == intensityMap(i,1)) = intensityMap(i,2);
end

[W, D] = GenerateAdjacency(N, intensityDots, posDots, r, sigma_I, sigma_X);
[v] = SolveEigen(W,D);
stability = CheckStability(v);
[v_partition] = Vpartition(W,D,v);
[Ncut] = NcutValue(W,D,v_partition);

numSegments = numSegments + 1;
segments(numSegments) = struct('level', segLevel, 'cutNo', numCuts, 'pos', posDots, 'intensity', intensityDots, 'vpartition', v_partition ,'ncut',Ncut, 'stability', stability);
fprintf('Cut %d completed. nCut is %f. Stability is %f \n',segLevel, Ncut, stability);


segLevel = segLevel + 1;
% Bipartition if the Ncut value is below the threshold
if Ncut < nCutThr
    [segA, intensA, segB, intensB] = Segmentation(v_partition, posDots, intensityDots);
end

% Assign two segments from the first cut into structs
numCuts = numCuts + 1;

numSegments = numSegments + 1;
segments(numSegments) = struct('level', segLevel,  'cutNo', numCuts, 'pos', segA, 'intensity', intensA, 'vpartition', [] ,'ncut',-1, 'stability', 1);

numSegments = numSegments + 1;
segments(numSegments) = struct('level', segLevel,  'cutNo', numCuts, 'pos', segB, 'intensity', intensB, 'vpartition', [], 'ncut', -1','stability', 1);

segTargetFilt = ([segments.level] == segLevel);
segTargetWhere = find(segTargetFilt); % get the idx of the segments in the struct


% Check for nCut values for further bipartition
% Compute nCut values for each segment from the previous step
for k=1:length(segTargetWhere)
    i = segTargetWhere(k);

    intMatrix = segments(i).intensity;
    N = length(intMatrix);
    % If the minimum number of dots or threshold is reached stop     
    if (Ncut <= nCutThr) && ~all(intMatrix == intMatrix(1))
        [W, D] = GenerateAdjacency(N, segments(i).intensity, segments(i).pos, r, sigma_I, sigma_X);
        [v] = SolveEigen(W,D);          
        stability = CheckStability(v);
        v_partition = Vpartition(W,D,v);        
        Ncut = NcutValue(W,D,v_partition);

        segments(i).ncut = Ncut;    
        segments(i).vpartition = v_partition;       
        segments(i).stability = stability;
        fprintf('Cut %d completed. nCut is %f. Stability is %f \n',segLevel, Ncut, stability);
    else
        continue
    end
end

%% Further bipartitions
% Continue until you find all the predefined segments
while sum([segments.ncut] == -1) < numIntensities
        
    % Select the segments from the previous cut which can be cut further
    segTargetFilt = ([segments.level] == segLevel) & ([segments.ncut] > -1);
    segTarget = segments(segTargetFilt);
    segTargetWhere = find(segTargetFilt); % get the idx of the segments in the struct
    
    [~, idx] = sort([segTarget.ncut]);
    idx = segTargetWhere(idx);
    
    if isempty(idx)
        return
    end
    % Apply segmentation depending on the order
    segLevel = segLevel + 1;

    % Go over the segments you get from the last iteration
    for i=1:length(idx)        

        % Check if the conditions are satisfied
        Ncut =  segments(idx(i)).ncut;
        stability = segments(idx(i)).ncut;
        lenSeg = length(segments(idx(i)).vpartition);

        if (Ncut <= nCutThr) && ((stability > 1) || (1/stability > 1))
            % prepeare structure for upcoming 2 new segments
            numCuts = numCuts + 1;
            segments(numSegments+1) = struct('level', segLevel, 'cutNo', numCuts, 'pos', [], 'intensity', [], 'vpartition', [] ,'ncut',-1, 'stability', 1);
            segments(numSegments+2) = struct('level', segLevel, 'cutNo', numCuts, 'pos', [], 'intensity', [], 'vpartition', [] ,'ncut',-1, 'stability', 1);

            % Do partition and get two segments from each parent segment
            [segments(numSegments+1).pos, segments(numSegments+1).intensity, ...
                segments(numSegments+2).pos, segments(numSegments+2).intensity] = ...
                Segmentation(segments(idx(i)).vpartition ,segments(idx(i)).pos, segments(idx(i)).intensity);

            % Compute if the segment requires further partitioning and fill the
            % table.
            intMatrix = segments(numSegments+1).intensity;
            N = length(intMatrix);

            % If the minimum number of dots is reached stop
            % && all(intMatrix == intMatrix(1)) == 0
            if ~all(intMatrix == intMatrix(1))
                [W, D] = GenerateAdjacency(N, segments(numSegments+1).intensity, segments(numSegments+1).pos, r, sigma_I, sigma_X);
                [v] = SolveEigen(W,D);
                stability = CheckStability(v);
                v_partition = Vpartition(W,D,v);
                Ncut = NcutValue(W,D,v_partition);
                
                segments(numSegments+1).ncut = Ncut;
                segments(numSegments+1).vpartition = v_partition;
                segments(numSegments+1).stability = stability;
                fprintf('Cut %d completed. nCut is %f. Stability is %f \n',segLevel, Ncut, stability);
            end

            intMatrix = segments(numSegments+2).intensity;
            N = length(intMatrix);

            % If the minimum number of dots is reached stop
            if ~all(intMatrix == intMatrix(1))
                [W, D] = GenerateAdjacency(N, segments(numSegments+2).intensity, segments(numSegments+2).pos, r, sigma_I, sigma_X);
                [v] = SolveEigen(W,D); % get the smallest second eigenvector
                % Check for stability. If not stable, continue with the
                % other segment
                stability = CheckStability(v);
                v_partition = Vpartition(W,D,v);
                Ncut = NcutValue(W,D,v_partition);
                segments(numSegments+2).ncut = Ncut;
                segments(numSegments+2).vpartition = v_partition;
                segments(numSegments+2).stability = stability;
                fprintf('Cut %d completed. nCut is %f. Stability is %f \n',segLevel, Ncut, stability);
            end

            numSegments = numSegments + 2;
        end
    end
    
end

% Recall all the segments and represent intensities with their key values
for i=1:length(segments)
    intensityDots = segments(i).intensity;
    
    % Transform intensity values to keys
    for j=1:length(intensityMap)
        intensityDots(intensityDots == intensityMap(j,2)) = intensityMap(j,1);
    end
    segments(i).intensity = intensityDots;
end

end

