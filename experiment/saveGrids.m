%% Find the target trial
% Use allSegs array to recall the desired trial image and segments.

% Target Inputs
targetBlock = 1;
targetTrial = 1;

% Find the target trial 
trialDinBlock = (10*(targetBlock-1) + 1):(10*targetBlock);
trialId = trialDinBlock(targetTrial);

positionGrid = allSegs{targetBlock, targetTrial}.pos;

% Get the position and intensity values of the segment
positionSeg = presentedSegs{trialId, 4};
intensityImg = presentedSegs{trialId, 3};

intensitySeg = nan(length(positionSeg),1);
for i=1:length(positionSeg)
    intensitySeg(i,:) = intensityImg(seg(i,1),seg(i,2));
end

