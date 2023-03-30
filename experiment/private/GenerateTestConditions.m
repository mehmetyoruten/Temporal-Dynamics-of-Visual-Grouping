function GenerateTestConditions()

orderedConds = ones(5,1).*[1:5]';
orderedConds = cat(1,orderedConds, orderedConds);

exposureTimeConds = ones(10,1);
controlConds = [rand(1,10) > 0.5]';

trialLayout = cat(2,orderedConds, exposureTimeConds, controlConds);

save('testSegments.mat', 'trialLayout')