%% Prepare images and segments for the experiment


clearvars;
settingsGenerateTrials;

% Store segment IDs
segIdx = nan(numBlocks*numTrials,1);

% Assign arbitrary intensity values
intensities = [190, 193, 196, 199, 202, 205]';


%----------------------------------------------------------------------
%%                      Start Experimental Loop
%----------------------------------------------------------------------
% for i= 1:numTrials
% 1) generate random intensities
% 2) do segmentation
% 3) decide what to show
% 4) get positions of the dots from the grid

% Test settings for segment comparison
if segTest == true    
    numBlocks = length(blockLayouts);
    numTrials = length(blockLayouts{1});
end

% Create an empty cells to store images,presented segs, cut info, responses
presentedSegs = cell(numTrials*numBlocks,9);
imagesSegs = cell(numTrials*numBlocks,2);
allSegs = cell(numBlocks,numTrials);
shownFoils = nan(numBlocks*numTrials,1);

TrialNo = 0;

% Generate trial layout
[trialLayoutBlocks] = SetExperimentOffline(numTest, numBlocks, gridSecs, noControl);

for BlockNo=1:numBlocks
    fprintf('********************************* \n');
    fprintf('Block %d starting... \n', BlockNo);
    
    % Retrieve the layout for this block
    trialLayout = trialLayoutBlocks{BlockNo};
    
    % Arrange numbers for saving trials in one matrix
    if BlockNo == 1
        trialId = 1:(BlockNo*numTrials);
    else
        trialId = ((BlockNo-1)*numTrials+1):(BlockNo*numTrials);
    end
        

    for TrialNo=1:numTrials
        fprintf('Block %d. Trial %d starting... \n', BlockNo,TrialNo);
        trialSegment = trialLayout(TrialNo,1);
        trialDuration = trialLayout(TrialNo,2);
        trialControl = trialLayout(TrialNo,3);
            
        % Choose Segment
        segNcutVal = 1; % initial assignment for the while loop
        noIters = 0;    % keep track of number of iteration
        while segNcutVal ~= -1 % Generate images until you find a target leaf segment 
            noIters = noIters + 1;
            fprintf('Generating image with leaf nodes: %d \n', noIters)
            
            preShownImg = shownImages;
            % Get the pre-generated image                
            [segments, posDots, intensityDots, intensityMap, shownImages] = ChooseImage(trialImages,shownImages, trialSegment, intensities);
       
            % Choose a segment
            [seg, segCenter, segLevel, segNcutVal, segStab, selectedSegIdx] = ChooseSegment(segments, trialSegment);
            
            % Update the shown images array only if the leaf segment exists
            % in the target image
            if segNcutVal ~= -1
                shownImages = preShownImg;
            end
        end

                
        % Rotate the selected segment if control should be presented
        if (trialControl == 1)
            [segments, segInt, seg, allShownFoils, chosenFoilImg, selectedSegIdx]= GenerateFoil(controlSegments,segments, trialSegment, allShownFoils, numDots, overlapThr,leafOnly);
            shownFoils(trialId(TrialNo)) = chosenFoilImg;
            
            intensityDotsControl = segments(1).intensity;
            for i=1:length(intensityMap)
                intensityDotsControl(intensityDotsControl == intensityMap(i,1)) = intensityMap(i,2);
            end
            intensityDotsControl = reshape(intensityDotsControl, [numDots,numDots]);
        else
            intensityDotsControl = intensityDots;
        end
        
        allSegs{BlockNo,TrialNo} = segments; % add segments for future recalls
        
        % Save shown segment ids
        segIdx(trialId(TrialNo)) = selectedSegIdx;
        
        
        fprintf('Presenting Cut No %d, for %.2f. Control = % d \n', trialSegment, trialDuration, trialControl);
    end
   
    % If the maximum number of blocks reached, finish the experiment
    if BlockNo == numBlocks
        continue
    end
    
    trialLayout(:,4) = shownImages(trialId);
    trialLayout(:,5) = shownFoils(trialId);
    trialLayout(:,6) = segIdx(trialId);
    % Save the updated trial layout
    trialLayoutBlocks{BlockNo} = trialLayout;
end

%% Save the layout for the actual experiment
cd layouts\
shownImages = shownImages';
segIdx = segIdx';
filename = sprintf('%s_images.mat', participant);
save(filename,'trialLayoutBlocks', 'shownImages', 'shownFoils', 'segIdx');
