function [trialLayout] = SetExperiment(numTest, gridSecs, noControl)
%SETEXPERIMENT Generate trial layout for the current block.
% 
%     Parameters
%     ------------
%     numTest   (int)       : How many times you want to show the
%                                     condition in one block
%     gridSecs          (int)       : Number of exposure time conditions
%     noControl         (logical)   : If you want control conditions or not
%
%     Returns
%     -------------
%     trialLayout       (array )    : Array with the randomized conditions


% Create trial layout for each condition
for condSeg=1:5
    for condTime=1:length(gridSecs)
        for condControl=0:1
%         control = cat(2,ones(numControl,1)*condSeg, ones(numControl,1)*condTime, ones(numControl,1));
            trials = cat(2,ones(numTest,1)*condSeg, ones(numTest,1)*condTime, ones(numTest,1)*condControl);
%             trials = cat(1,test,control);
            if condSeg == 1 && condTime == 1 && condControl == 0 % Initial matrix
                trialLayout = trials;
                continue
            end
            trialLayout = cat(1,trialLayout,trials);        
        end
    end
end

% If no control conditin is wanted, 
if noControl == 1
    trialLayout(:,3) = 0;
end

mask = randperm(length(trialLayout));
trialLayout = trialLayout(mask,:);


end

