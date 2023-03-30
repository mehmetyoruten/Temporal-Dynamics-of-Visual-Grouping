% Mehmet Yoruten, June 2022
% Visual Hiearhical Perception


% Clear the workspace and the screen
sca;

close all;
clear;

%----------------------------------------------------------------------
%%                             Screen Setup
%----------------------------------------------------------------------
% PsychImaging('PrepareConfiguration')
% PsychImaging('AddTask', 'General', 'EnableDataPixxC48Output',2);
% Datapixx('Open');
% Datapixx('SetVideoMode',0);

ListenChar(2); % Disable input to command window

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
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
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


%----------------------------------------------------------------------
%%                      Start Instructions
%----------------------------------------------------------------------
[posDots, intensityDots] = GenerateGrid(numDots, numIntensities, intensities, gradientTest);
DrawInstructions2(window,xCenter, yCenter, allCoordsInst, lineWidthPix, numDots, dotAreaX, dotAreaY, hexAreaX, hexAreaY, dotsXpos, dotsYpos, hexEdge, hexXpos, hexYpos, dotDiameter, intensityDots, textColor, hexagonTest);

%----------------------------------------------------------------------
%%                      Start Practice Trials
%----------------------------------------------------------------------
[allPracticeSegs,respPracticeMatrix] = DrawPractice2(window, windowRect, numPractice,numDots, ...
                     numIntensities, intensities, gradientTest, r, sigma_I, sigma_X, nCutThr,...
                     fixationSecs, blankSecs, practiceRespSecs, afterRespTime, gridSecs,maskSecs, segSecs, xCenter, ...
                     yCenter, dotsXpos, dotsYpos,dotDiameter, dotAreaX, dotAreaY,...
                     hexAreaX, hexAreaY, hexXpos, hexYpos, hexEdge, space, ...
                     allCoords, lineWidthPix, textColor, topPriorityLevel, hexagonTest);
%----------------------------------------------------------------------
%%                      Start Experimental Loop
%----------------------------------------------------------------------
% for i= 1:numTrials
% 1) generate random intensities
% 2) do segmentation
% 3) decide what to show
% 4) get positions of the dots from the grid

% Generate trial layout
trialLayout = SetExperiment(numPresentation,gridSecs);

% create an empty cell to store presented segs
presentedSegs = cell(numTrials,3, numBlocks);
imagesSegs = cell(numTrials,2, numBlocks);

% Create arrays to store responses
respMatrix = NaN(numTrials,5,numBlocks);

allSegs = cell(numBlocks,numTrials);

TrialNo = 0;

for BlockNo=1:numBlocks
    fprintf('********************************* \n');
    fprintf('Block %d starting... \n', BlockNo);
    
    % Randomize the order for each block
    mask = randperm(length(trialLayout));
    trialLayout = trialLayout(mask,:);
    
    % Save participant score for each block
    scoreMatrix = zeros(numTrials,1);

    for TrialNo=1:numTrials
        fprintf('Trial %d starting... \n', TrialNo);
        trialSegment = trialLayout(TrialNo,1);
        trialDuration = trialLayout(TrialNo,2);
        trialControl = trialLayout(TrialNo,3);
    
        % Generate random grid with different intensities
        [posDots, intensityDots] = GenerateGrid(numDots, numIntensities, intensities, gradientTest);
        
    
        % Generate segments
        [segments] = NormMinCut(numDots, numIntensities, intensityDots, posDots, r, sigma_I, sigma_X, nCutThr);
        allSegs{BlockNo,TrialNo} = segments; % add segments for future recalls

        % Order all the cut segments ascending
        %sortedSegs = [segments.ncut];
        sortedSegs = [segments.cutNo]; 
        [sortedNcuts, segIdx] = sort(sortedSegs(2:end)); % do not consider the initial grid as segment
        
        fprintf('Presenting Level %d, for %.2f. Control = % d \n', trialSegment, trialDuration, trialControl);
        
        % Choose segment to show        
        choose = randi(2); % choose one of the segments from that cut
%         seg = segments(segIdx(trialSegment)).pos;

        selectedSegIdx = [(segIdx(sortedNcuts == trialSegment))];
        selectedSegIdx = selectedSegIdx(choose);
        selectedSegIdx = selectedSegIdx + 1; % Shift the index 1, to disregard the initial uncut grid
        
        seg = segments(selectedSegIdx).pos;
        segNcut = sortedNcuts(segIdx(trialSegment));
                
        
        % Rotate the selected segment if control should be presented
        if (trialControl == 1) && (TrialNo > 1)
            seg = GenerateFoil(allSegs(BlockNo,1:TrialNo-1),seg, trialSegment,numDots, 270, overlapThr, false);
        elseif (trialControl == 1) && (TrialNo == 1)
            seg = GenerateFoil(allPracticeSegs,seg, trialSegment, numDots, 270, overlapThr, false);
        end
        
        % Save intensity, segment and nCut values for future recalls
        presentedSegs{TrialNo,3, BlockNo} = segNcut; 
        presentedSegs{TrialNo,2, BlockNo} = seg; 
        presentedSegs{TrialNo,1, BlockNo} = intensityDots; 
                
        Priority(topPriorityLevel);
        responseSetting = false;
        
        % Draw fixation
        DrawFixation(window, fixationSecs, xCenter, yCenter, dotAreaX, dotAreaY, hexAreaX, hexAreaY, space, allCoords, lineWidthPix, textColor, hexagonTest);

        % Draw Segment 
        if hexagonTest == false
            DrawSegment(window, intensityDots, seg, segSecs, dotDiameter, dotsXpos, dotsYpos);
        else
            [imageSegment] = DrawHexSegment(window, intensityDots, seg, segSecs, hexEdge, hexXpos, hexYpos);
        end

        % Draw mask
        DrawMask(window, windowRect, dotArea, maskSecs);           

        % Draw image
        if hexagonTest == false
            % Draw dots
            DrawDots(window, gridSecs(trialDuration), numDots, dotDiameter, intensityDots, dotsXpos, dotsYpos);
        else
            % Draw hexagons
            [imageGrid] = DrawHexagon(window, gridSecs(trialDuration), numDots, hexEdge, intensityDots, hexXpos, hexYpos);
        end
    
        % Get responses
        responseSetting = true;
        [reactionTime, keyCode] = GetResponse(respSecs, afterRespTime, window, xCenter, yCenter, dotAreaX, dotAreaY,hexAreaX, hexAreaY, allCoords,lineWidthPix, textColor, hexagonTest, responseSetting);                                 
        
        % Show blank screen
        DrawBlankScreen(window,blankSecs);

        % Take screenshot
%         imagesSegs{TrialNo, 1, BlockNo} = imageGrid;
%         imagesSegs{TrialNo, 2, BlockNo} = imageSegment;

        % Store responses
        respMatrix(TrialNo,1,BlockNo) = trialSegment; % Save which level you present
        respMatrix(TrialNo,2, BlockNo) = trialDuration; % Save how long you present
        respMatrix(TrialNo,3, BlockNo) = trialControl; % Save if you showed control
        respMatrix(TrialNo,4, BlockNo) = keyCode; % Save which key you pressed
        respMatrix(TrialNo,5, BlockNo) = reactionTime; % Save reaction time
        
        if (trialControl+keyCode == 2) || (trialControl+keyCode == 0) 
            scoreMatrix(TrialNo) = 1;
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

cd results;
filename1 = sprintf('%s.mat', participant);
filename2 = sprintf('%s_presentedSegments.mat', participant);
filename3 = sprintf('%s_allSegments.mat', participant);
save(filename1,'respMatrix');
save(filename2,'presentedSegs');
save(filename3,'allSegs');

ListenChar(0); % Enable input to command window
ShowCursor();
% Clear the screen
sca;