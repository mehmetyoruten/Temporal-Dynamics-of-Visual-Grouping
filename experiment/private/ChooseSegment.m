function [seg,segCenter, segLevel, segNcutVal, segStab, selectedSegIdx] = ChooseSegment(segments,trialSegment)
% CHOOSESEGMENT Select the target segment from the partitioned image.
%
%     Parameters
%     ------------
%     segments      (1 x 7 struct)     : All the segments of the partitioned
%                                        image with cutLevel, cutNo, position, intensity, vpartition, ncutVal,
%                                        and stability information.
%
%     trialSegment  (int)               : cutNo of the target segment.
% 
%     Returns
%     -------------
%     seg           (n x 2 d array)     : Position of all the nodes in the
%                                         target segment.
%     segCenter     (1 x 2 d array)     : Center of the segment relative to
%                                         the image position.
%     segLevel      (int)               : Level of the segment in the
%                                         partition tree.
%     segNcutVal    (float)             : nCut Value of the segment. -1 if
%                                         it is the leaf segment.
%     segStab       (float)             : Stability of the segment. 1 if it
%                                         is the leaf segment.

%% Choose with cutNo
% Order all the cut segments ascending
sortedSegs = [segments.cutNo]; 
[sortedNcuts, segIdx] = sort(sortedSegs(2:end)); % do not consider the initial grid as segment

selectedSegIdx = [(segIdx(sortedNcuts == trialSegment))];

%% Choose the small/big one
% Compare sizes 
sizesComp = zeros(1,2);
sizesComp(1) = length(segments(selectedSegIdx(1)).intensity);
sizesComp(2) = length(segments(selectedSegIdx(2)).intensity);

%% Choose segment to show        
choose = randi(2); % choose one of the segments from that cut
selectedSegIdx = selectedSegIdx(choose);
selectedSegIdx = selectedSegIdx + 1; % Shift the index 1, to disregard the initial uncut grid

seg = segments(selectedSegIdx).pos;
segLevel = segments(selectedSegIdx).level;
segNcutVal = segments(selectedSegIdx).ncut;
segStab = segments(selectedSegIdx).stability;

%% Compute the segment position relative to the center of the image
% Find the center of the image
imgPos = segments(1).pos;
imgPosMax = max(imgPos(:,1));
imgPosMin = min(imgPos(:,1));
shift = median(imgPosMin:imgPosMax); % Find the median to center arrays at 0
imgCenter = [0 0];


% Find the center of the segment
segPosXmin = min(seg(:,1));
segPosXmax = max(seg(:,1));
segCenterX = median(segPosXmin:segPosXmax);

segPosYmin = min(seg(:,2));
segPosYmax = max(seg(:,2));
segCenterY = median(segPosYmin:segPosYmax);

segCenter = [segCenterX, segCenterY] - shift; % Make 0 center

% Compute Euclidian distance
segDist = sqrt(sum((segCenter - imgCenter) .^ 2));

%% Choose the leaf nodes
% idx = find([segments.ncut] == -1);
% seg = segments(idx(trialSegment)).pos;
% segNcut = segments(idx(trialSegment)).cutNo;

%% Choose the leaf nodes from the stock
% if leafOnly == 1
%     targetIds = trialSegment*2:trialSegment*2+1; % +1 because we disregard the iniitial image
%     allNcutVals = [allSegs{2,i}];
%     choose = allNcutVals(targetIds) == -1;    
%     
%     selectedSegIdx = targetIds(choose(1));
%     
%     seg = segments(selectedSegIdx).pos;
%     segLevel = 
%     segNcutVal = segments(selectedSegIdx).ncut;
%     segStab = segments(selectedSegIdx).stability;
% 
%     



end

