% Mehmet Yoruten, June 2022
% Visual Hiearhical Perception
% Computational Principles of Intelligence Lab
% Max Planck Institute for Biological Cybernetics


% Clear the workspace and the screen
sca;

close all;
clear;


%----------------------------------------------------------------------
%%                             Screen Setup
%----------------------------------------------------------------------
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');

AssertOpenGL;     % This script calls Psychtoolbox commands available only in OpenGL-based versions of the Psychtoolbox.
Screen('Preference','SkipSyncTests', 1);


screens=Screen('Screens');  % Get the list of screens
screenNumber=max(screens);  % & choose the one with the highest screen number.


white=WhiteIndex(screenNumber);  % Find the color values which correspond to white
black=BlackIndex(screenNumber);  % & find the color values which correspond to black.
gray=(white+black)/2;            % Define the gray on the basis of black & white.


if round(gray)==white
    gray=black;
end
inc=white-gray;

settingsExperiment;  % Load settings

% settingsSaveControlSegs;

[window, windowRect] = Screen('OpenWindow', screenNumber, backgroundColor);
HideCursor;

% Get the size of the on screen window in pixels.
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the maximum priority level
topPriorityLevel = MaxPriority(window);

% Query the frame duration (refresh rate)
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);


% Enable alpha blending for anti-aliasing
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%----------------------------------------------------------------------
%%                       Timing Information
%----------------------------------------------------------------------

% Interstimulus interval time in seconds and frames
isiTimeFrames = round(isiTimeSecs / ifi);

% Numer of frames to show fixation cross
fixationFrames = round(fixationSecs / ifi);

% How long should the whole grid stay up on the screen in time and frames
gridFrames = round(gridSecs / ifi);

% How long should the segment stay up on the screen in time and frames
segFrames = round(segSecs / ifi);

% Duration of the mask during flicker
maskFrames = round(maskSecs / ifi);

% Duration of blank screen
blankFrames = round(blankSecs / ifi);


%----------------------------------------------------------------------
%%                      Setup the Fixation Cross
%----------------------------------------------------------------------

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
allCoordsInst = [xCoords; yCoords + 100];

%----------------------------------------------------------------------
%%                      Keyboard information
%----------------------------------------------------------------------
% Keyboard setup
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
leftKey = KbName('UpArrow');
rightKey = KbName('DownArrow');
enterKey = KbName('Return');

keys =  [escapeKey leftKey rightKey enterKey];

% RestrictKeysForKbCheck([escapeKey leftKey rightKey enterKey]);
% No keys are down
keyIsDown = 0;

%----------------------------------------------------------------------
%%                 Setup Dot Positions on the Screen
%----------------------------------------------------------------------
screenXquarter = screenXpixels/4;
screenYquarter = screenYpixels/4;

dotAreaX = [xCenter - dotArea/2,  xCenter + dotArea/2];
dotAreaY = [yCenter - dotArea/2, yCenter + dotArea/2];

dotsXpos = (dotAreaX(1) + (dotDiameter/2)):(dotDiameter+space):(dotAreaX(2)-(dotDiameter/2));
dotsYpos = (dotAreaY(1) + (dotDiameter/2)):(dotDiameter+space):(dotAreaY(2)-(dotDiameter/2));

%----------------------------------------------------------------------
%%                 Setup Hex Positions on the Screen
%----------------------------------------------------------------------

hexAreaX = numDots * (hexEdge*(sqrt(3)));
hexAreaY = numDots * hexEdge * (1.5) + (hexEdge/2);

hexAreaX = [xCenter - hexAreaX/2,  xCenter + hexAreaX/2];
hexAreaY = [yCenter - hexAreaY/2, yCenter + hexAreaY/2];

hexXpos = (hexAreaX(1) + (hexEdge)*sqrt(3)) : hexEdge*(sqrt(3)) : hexAreaX(2); 
hexYpos = (hexAreaY(1) + hexEdge) : (hexEdge + hexEdge/2) : (hexAreaY(2) - hexEdge);


%--------------------------------------------------------------------
%%                  Start Contrast Sensitivity Experiment
%--------------------------------------------------------------------
[contrast, cntrstMatrix, cntrstResp] = DrawThresholdExp(...
    window, numDots, minIntensity, numIntensities,trialsDesired, topPriorityLevel,  fixationSecs, ...
    xCenter, yCenter, hexEdge, hexAreaX, hexAreaY, ...
    hexXpos, hexYpos, allCoords, lineWidthPix, textColor, ...
    respSecs, afterRespTime, blankSecs, gradientTest, windowRect, hexArea, maskSecs);


%--------------------------------------------------------------------
%%                  Get Information from Previous Session
%--------------------------------------------------------------------
% load results/my/my_10blocks_3deg_thrExp_last.mat settings shownFoils shownImages;
% % 
intensities = CreateIntensities(minIntensity,numIntensities, contrast);
% intensities = settings{2};
% contrast = settings{5};
% 
normed_intensities = (intensities/255);
sigma_I = (normed_intensities(6) - normed_intensities(1))* 0.07;
intensityMap(:,1) = 1:numIntensities;
intensityMap(:,2) = intensities;
% 
% % Save the computed delta
settings{5} = contrast;
settings{2} = intensities;
settings{6} = intensityMap;
%----------------------------------------------------------------------
%%                      Start Instructions
%----------------------------------------------------------------------
% DrawInstructions(window, xCenter, yCenter, allCoords, lineWidthPix, numDots, hexEdge, hexAreaX, hexAreaY, hexXpos, hexYpos, textColor, intensityMap)

%----------------------------------------------------------------------
%%                      Start Practice Trials
%----------------------------------------------------------------------
% [allPracticeSegs,respPracticeMatrix, shownFoils] = DrawPractice(window, windowRect, practiceSegments, practiceControlSegments, ...
%                      numPractice,numDots, ...
%                      fixationSecs, blankSecs, afterRespTime, gridSecs,maskSecs, ...
%                      practiceRespSecs, segSecs, xCenter, yCenter,...
%                      hexAreaX, hexAreaY, hexXpos, hexYpos, hexEdge, ...
%                      allCoords, lineWidthPix, textColor, topPriorityLevel, ...
%                      overlapThr, leafOnly, intensityMap, shownPracticeFoils, shownPracticeImgs, intensities);
%----------------------------------------------------------------------
%%                      Start Experimental Loop
%----------------------------------------------------------------------

ListenChar(2); % Disable input to command window


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
presentedSegs = cell(numTrials*numBlocks,14);
imagesSegs = cell(numTrials*numBlocks,5);
respMatrix = NaN(numTrials*numBlocks,25);
allSegs = cell(numBlocks,numTrials);

% Load shown image ids and trial layout
cd layouts\;
layoutName = sprintf('%s_images.mat', participant);
load(layoutName);
cd ..\;

TrialNo = 0;
for BlockNo=(blockFromLastSess+1):(blockFromLastSess+numBlocks)
    fprintf('********************************* \n');
    fprintf('Block %d starting... \n', BlockNo);
 
    
    % Retrieve the layout for this block
    trialLayout = trialLayoutBlocks{BlockNo};
    
    % Save participant score for each block
    scoreMatrix = nan(numTrials,1);
    
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
        
        imgToShow = trialLayout(TrialNo,4);
        segToShow = trialLayout(TrialNo,6);
        
        % Retrieve the img
        [segments, posDots, intensityDotsImg, intensityMap] = PG_ChooseImg(trialImages, imgToShow, trialSegment, intensities);
        if (trialControl == 0)                        
            % Retrieve the segment
            [seg,segCenter, segLevel, segNcutVal, segStab] = PG_ChooseSegment(segments,trialSegment, segToShow);
            intensityDotsControl = intensityDotsImg;
            chosenFoilImg = 0;
        else
            foilToShow = trialLayout(TrialNo,5);
            chosenFoilImg = foilToShow;
            % Retrieve the img of foil
            [segmentsFoil, posDots, intensityDotsControl, intensityMap] = PG_ChooseImg(controlSegments, chosenFoilImg, trialSegment, intensities);
            % Retrieve the segment from the image
            [seg,segCenter, segLevel, segNcutVal, segStab] = PG_ChooseSegment(segmentsFoil,trialSegment, segToShow);
        end

        
        allSegs{BlockNo,TrialNo} = segments; % add segments for future recalls
        
        fprintf('Presenting Cut No %d, for %.2f. Control = % d \n', trialSegment, trialDuration, trialControl);
                
        Priority(topPriorityLevel);
        responseSetting = false;
        
        % Draw fixation        
        DrawFixation(window, fixationSecs, hexAreaX, hexAreaY, lineWidthPix, textColor);

        % Draw image
        [imageGrid] = DrawHexagon(window, gridSecs(trialDuration), numDots, hexEdge, intensityMap, intensityDotsImg, hexXpos, hexYpos);
        
        % Draw mask
        DrawMask(window, windowRect, hexArea, maskSecs);
    
        % Draw Segment 
        [imageSeg, delta_int, intDiff, intStd,intOrder] = DrawHexSegment(window, intensityMap, intensityDotsControl, seg, segSecs, hexEdge, hexXpos, hexYpos);        
    
        % Get responses
        responseSetting = true;
        [reactionTime, keyCode] = GetResponse(respSecs, afterRespTime, window, xCenter, yCenter, allCoords,lineWidthPix, textColor, responseSetting);                                 
        
        % Show blank screen
        DrawBlankScreen(window,blankSecs);

        % Take screenshot
        imagesSegs{trialId(TrialNo), 1} = trialId(TrialNo);
        imagesSegs{trialId(TrialNo), 2} = TrialNo;
        imagesSegs{trialId(TrialNo), 3} = BlockNo;
        imagesSegs{trialId(TrialNo), 4} = imageGrid;
        imagesSegs{trialId(TrialNo), 5} = imageSeg;
        
        % Save intensity, segment and nCut values for future recalls
        presentedSegs{trialId(TrialNo),1} = trialId(TrialNo); 
        presentedSegs{trialId(TrialNo),2} = TrialNo;
        presentedSegs{trialId(TrialNo),3} = BlockNo; 
        presentedSegs{trialId(TrialNo),4} = trialControl; 

        presentedSegs{trialId(TrialNo),5} = imgToShow;          % presented img id
        presentedSegs{trialId(TrialNo),6} = chosenFoilImg;          % control img 
        presentedSegs{trialId(TrialNo),7} = segToShow;     % presented segment id from the img cell

        presentedSegs{trialId(TrialNo),8} = intensityDotsImg;      % 10 x 10 array of presented image
        if trialControl == 1
            presentedSegs{trialId(TrialNo),9} = intensityDotsControl;             % 10 x 10 array of the intensity array of segment
        else
            presentedSegs{trialId(TrialNo),9} = intensityDotsImg;
        end
        presentedSegs{trialId(TrialNo),10} = seg;                % Position index of presented seg
        presentedSegs{trialId(TrialNo),11} = length(seg); 
        presentedSegs{trialId(TrialNo),12} = segLevel; 
        presentedSegs{trialId(TrialNo),13} = segNcutVal; 
        presentedSegs{trialId(TrialNo),14} = segStab; 

        % Store responses
        respMatrix(trialId(TrialNo),1) = trialId(TrialNo);                      % Save trial id
        respMatrix(trialId(TrialNo),2) = TrialNo;                               % Save trial no in a block
        respMatrix(trialId(TrialNo),3) = BlockNo;                               % Save block no
        respMatrix(trialId(TrialNo),4) = trialSegment;                          % Save which cut you present
        respMatrix(trialId(TrialNo),5) = trialDuration;                         % Save exposure time
        respMatrix(trialId(TrialNo),6) = trialControl;                          % Save if you showed control cond
        respMatrix(trialId(TrialNo),7) = keyCode;                               % Save which key you pressed
        
        respMatrix(trialId(TrialNo),8) = imgToShow;                             % Save the shown image
        respMatrix(trialId(TrialNo),9) = chosenFoilImg;                         % Save the control image
        respMatrix(trialId(TrialNo),10) = segToShow;                       % Save the shown image

        respMatrix(trialId(TrialNo),11) = reactionTime;                          % Save which image you presented
        respMatrix(trialId(TrialNo),12) = length(seg);                           % Save segment size
        respMatrix(trialId(TrialNo),13) = segCenter(1);                         % Save center X location of segment
        respMatrix(trialId(TrialNo),14) = segCenter(2);                         % Save center Y location of segment
        respMatrix(trialId(TrialNo),15) = sqrt(sum((segCenter - [0 0]) .^ 2));  % Save Euclidian distance to the image center
        respMatrix(trialId(TrialNo),16) = intDiff;                              % Save segment's intensity difference
        respMatrix(trialId(TrialNo),17) = intStd;                               % Save segment's std of intensity
        respMatrix(trialId(TrialNo),18) = segNcutVal;                           % Save segment's ncut value
        respMatrix(trialId(TrialNo),19) = segStab;                              % Save segment's stability
        respMatrix(trialId(TrialNo),20) = segNcutVal*-1;                        % Save leaf node info
        respMatrix(trialId(TrialNo),21) = respMatrix(trialId(TrialNo),6) == respMatrix(trialId(TrialNo),7); % Save if the answer is correct or not
        respMatrix(respMatrix(:,20) ~= 1,20) = 0;                               % Assign 0 for non leaf
        respMatrix(trialId(TrialNo),22:24) = delta_int;                         % Assign meanImg, meanSeg, deltaInt
        respMatrix(trialId(TrialNo),25) = intOrder;                             % Save intensity order of the shown image

        if trialControl == keyCode
            scoreMatrix(TrialNo) = 1;
        else
            scoreMatrix(TrialNo) = 0;
        end
        
        fprintf('Responses recorded. \n');
        fprintf('********************************* \n');
    end
    
    % Compute the score from that block
    DrawScore(window,textColor,scoreMatrix);

    % If the maximum number of blocks reached, finish the experiment
    if BlockNo == numBlocks
        continue
    end

end


%% Save the Results

filepath = sprintf('results/%s', participant);
cd(filepath)
filename = sprintf('%s.mat', participant);
save(filename,'respMatrix', 'allSegs', 'presentedSegs', 'imagesSegs','settings', 'shownFoils', 'shownImages');

ListenChar(0); % Enable input to command window
ShowCursor();
% Clear the screen
sca;