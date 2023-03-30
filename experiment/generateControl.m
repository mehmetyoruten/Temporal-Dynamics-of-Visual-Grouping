% Mehmet Yoruten, Oct 2022
% Visual Hiearhical Perception
% Computational Principles of Intelligence Lab
% Max Planck Institute for Biological Cybernetics
%
%
% Creates

% Clear the workspace and the screen
sca;

close all;
clear;

settingsExperiment;


%--------------------------------------------------------------------
%%                  Get Information from Previous Session
%--------------------------------------------------------------------
load results/my/my_10blocks_3deg_thrExp_last.mat settings shownFoils shownImages;
% 
% intensities = CreateIntensities(minIntensity,numIntensities, contrast);
intensities = settings{2};
contrast = settings{5};

normed_intensities = (intensities/255);
sigma_I = (normed_intensities(6) - normed_intensities(1))* 0.07;
intensityMap(:,1) = 1:numIntensities;
intensityMap(:,2) = intensities;

% Save the computed delta
settings{5} = contrast;
settings{2} = intensities;
settings{6} = intensityMap;


%----------------------------------------------------------------------
%%                      Start Experimental Loop
%----------------------------------------------------------------------
% for i= 1:numTrials
% 1) generate random intensities
% 2) do segmentation
% 3) decide what to show
% 4) get positions of the dots from the grid

% Generate trial layout
trialLayout = SetExperiment(numTest, gridSecs, noControl);

% Create arrays to store responses
if segTest == true    
    numBlocks = length(blockLayouts);
    numTrials = length(blockLayouts{1});
end

% Create an empty cells to store images,presented segs, cut info, responses
allSegs = cell(numTrials,1);

TrialNo = 0;

% Testing layout
if segTest == true
    trialLayout = blockLayouts{BlockNo};
end


for TrialNo=1:numTrials
    fprintf('Trial %d starting... \n', TrialNo);
    trialSegment = trialLayout(TrialNo,1);
    trialDuration = trialLayout(TrialNo,2);
    trialControl = trialLayout(TrialNo,3);
        
            
    if leafOnly == true
        segNcutVal = 1; % initial assignment for the while loop
        noIters = 0;    % keep track of number of iteration
        while segNcutVal ~= -1 % Generate images until you find a target leaf segment 
            noIters = noIters + 1;
            fprintf('Generating image with leaf nodes: %d \n', noIters)
            % Generate random grid with different intensities
            [posDots, intensityMap, intensityDots] = GenerateGrid(numDots, numIntensities, intensities, gradientTest, thrExp);
            
            % Generate segments
            [segments] = NormMinCut(numDots, numIntensities, intensityMap, intensityDots, posDots, r, sigma_I, sigma_X, nCutThr);
        end
    else
        noIters = 0;    % keep track of number of iteration
        lenSeg = 0;
        while lenSeg ~= 11
            noIters = noIters + 1;
            fprintf('Attempt no %d \n', noIters)
            % Generate random grid with different intensities
            [posDots, intensityMap, intensityDots] = GenerateGrid(numDots, numIntensities, intensities, gradientTest, thrExp);
        
            % Generate segments
            [segments] = NormMinCut(numDots, numIntensities, intensityMap, intensityDots, posDots, r, sigma_I, sigma_X, nCutThr);

            lenSeg = length(segments);
        end

    end            
    
    allSegs{TrialNo} = segments; % add segments for future recalls
    
    fprintf('Generating Cut No %d, for %.2f. Control = % d \n', trialSegment, trialDuration, trialControl);
                    
end


%% Save the Results

% cd results;
filename = sprintf('%s.mat', participant);
trialImages = allSegs;
save(filename,'trialImages');

ListenChar(0); % Enable input to command window
ShowCursor();
% Clear the screen
sca;