function [segments] = NormMinCut(numDots, numIntensities, intensityDots, posDots, r, sigma_I, sigma_X, nCutThr)
%NORMMINCUT Summary of this function goes here
%   Detailed explanation goes here

clear segments

%% Initial bipartition
segLevel = 0;
numSegments = 0;

% Compute total number of dots
N = numDots^2;

% Flatten the intensity array for easier computations
intensityDots = reshape(intensityDots, [N,1]);

[W, D] = GenerateAdjacency(N, intensityDots, posDots, r, sigma_I, sigma_X);
[v_partition] = SolveEigen(W,D);
[Ncut] = NcutValue(W,D,v_partition);

numSegments = numSegments + 1;
segments(numSegments) = struct('level', segLevel, 'pos', posDots, 'intensity', intensityDots, 'vpartition', v_partition ,'ncut',Ncut);
fprintf('Bipartition level %d, nCut is %f \n', segLevel, Ncut);


segLevel = segLevel + 1;
% Bipartition if the Ncut value is below the threshold
if Ncut < nCutThr
    [segA, intensA, segB, intensB] = Segmentation(v_partition, posDots, intensityDots);
end

numSegments = numSegments + 1;
segments(numSegments) = struct('level', segLevel, 'pos', segA, 'intensity', intensA, 'vpartition', [] ,'ncut',-1);

numSegments = numSegments + 1;
segments(numSegments) = struct('level', segLevel, 'pos', segB, 'intensity', intensB, 'vpartition', [], 'ncut', -1);

% % Check for nCut values for further bipartition
% Compute nCut values for each segment from the previous step
for i=numSegments-2^segLevel + 1:numSegments
    intMatrix = segments(i).intensity;
    N = length(intMatrix);
    % If the minimum number of dots is reached stop 
    if (N >= numDots) && all(intMatrix == intMatrix(1)) == 0
        [W, D] = GenerateAdjacency(N, segments(i).intensity, segments(i).pos, r, sigma_I, sigma_X);
        [v_partition] = SolveEigen(W,D);
        segments(i).ncut = NcutValue(W,D,v_partition);    
        segments(i).vpartition = v_partition;
    else
        continue
    end
end


while sum([segments.ncut] == -1) < numIntensities
    
    % sort all nCut vals in ascending order
    [nCutVals, idx] = sort([segments.ncut]);
    
    % Get the eligible segments' ids from the previous level
    idFilter = (idx >= numSegments-2^segLevel + 1) & numSegments;
    ncutFilter = nCutVals > -1;
    idx = idx(idFilter & ncutFilter);
    
    
    % Apply segmentation depending on the order
    segLevel = segLevel + 1;
    
    for i=1:length(idx)
        Ncut =  segments(idx(i)).ncut;
        lenSeg = length(segments(idx(i)).vpartition);
    
        if (Ncut <= nCutThr) && (lenSeg >= numDots)
            % prepeare structure for upcoming 2 new segments
            segments(numSegments+1) = struct('level', segLevel, 'pos', [], 'intensity', [], 'vpartition', [] ,'ncut',-1);
            segments(numSegments+2) = struct('level', segLevel, 'pos', [], 'intensity', [], 'vpartition', [] ,'ncut',-1);
        
            [segments(numSegments+1).pos, segments(numSegments+1).intensity, ...
            segments(numSegments+2).pos, segments(numSegments+2).intensity] = ...
            Segmentation(segments(idx(i)).vpartition ,segments(idx(i)).pos, segments(idx(i)).intensity);
            
            % Compute if the segment requires further partitioning and fill the
            % table
            intMatrix = segments(numSegments+1).intensity;
            N = length(intMatrix);
            % If the minimum number of dots is reached stop 
            if (N >= numDots) && all(intMatrix == intMatrix(1)) == 0
                [W, D] = GenerateAdjacency(N, segments(numSegments+1).intensity, segments(numSegments+1).pos, r, sigma_I, sigma_X);
                [v_partition] = SolveEigen(W,D);
                % Check for stability
                if length(v_partition) == 1
                    continue
                end
                segments(numSegments+1).ncut = NcutValue(W,D,v_partition);    
                segments(numSegments+1).vpartition = v_partition;
            end
          
            intMatrix = segments(numSegments+2).intensity;
            N = length(intMatrix);
            % If the minimum number of dots is reached stop 
            if (N >= numDots) && all(intMatrix == intMatrix(1)) == 0
                [W, D] = GenerateAdjacency(N, segments(numSegments+2).intensity, segments(numSegments+2).pos, r, sigma_I, sigma_X);
                [v_partition] = SolveEigen(W,D);
                % Check for stability
                if length(v_partition) == 1
                    continue
                end
                segments(numSegments+2).ncut = NcutValue(W,D,v_partition);    
                segments(numSegments+2).vpartition = v_partition;
            end
    
            numSegments = numSegments + 2;
        end
    end
    fprintf('Cut for Level %d completed.',segLevel);
end


end

