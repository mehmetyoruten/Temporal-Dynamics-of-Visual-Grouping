function [seg,segCenter, segLevel, segNcutVal, segStab] = PG_ChooseSegment(segments,trialSegment, selectedSegIdx)
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

%% Choose with ID

seg = segments(selectedSegIdx).pos;
segLevel = segments(selectedSegIdx).level;
segNcutVal = segments(selectedSegIdx).ncut;
segStab = segments(selectedSegIdx).stability;
segCutNo = segments(selectedSegIdx).cutNo;

if segCutNo == trialSegment
    fprintf('Segment ID matches the cut. \n')
else
    fprintf('Problem with Segment ID. \n')
end


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




end

