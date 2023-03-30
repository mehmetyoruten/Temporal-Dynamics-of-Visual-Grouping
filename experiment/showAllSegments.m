% Mehmet Yoruten, June 2022
% Visual Hiearhical Perception

% Script for saving all the segments as screenshots 


% Clear the workspace and the screen
sca;
close all;
clear;

%----------------------------------------------------------------------
%%                             Screen Setup
%----------------------------------------------------------------------
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
isiTimeSecs = 0.1;

% Numer of frames to wait before re-drawing
waitframes = 1;

% Numer of frames to show fixation cross
fixationSecs = 0.1;

% How long should the whole grid stay up on the screen in time and frames
gridSecs = [0.1 0.8 1];

% How long should the segment stay up on the screen in time and frames
segSecs = 0.1;

% Duration of the mask during flicker
maskSecs = 0.1;

% Duration of the response screen
respSecs = 0.1;
afterRespTime = 0.1;

% Duration of blank screen
blankSecs = 0.1;

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
numDots = 10;

screenXquarter = screenXpixels/4;
screenYquarter = screenYpixels/4;

dotAreaX = [xCenter - dotArea/2,  xCenter + dotArea/2];
dotAreaY = [yCenter - dotArea/2, yCenter + dotArea/2];

dotsXpos = (dotAreaX(1) + (dotDiameter/2)):(dotDiameter+space):(dotAreaX(2)-(dotDiameter/2));
dotsYpos = (dotAreaY(1) + (dotDiameter/2)):(dotDiameter+space):(dotAreaY(2)-(dotDiameter/2));

%----------------------------------------------------------------------
%%                 Setup Hexagon Positions on the Screen
%----------------------------------------------------------------------
hexEdge = 15;   % for 3 deg
% hexEdge = 19.5; % for 4 deg

% Area that hexagons occupy
hexArea = floor(numDots * (hexEdge*(sqrt(3))));
hexAreaDeg = degrees_per_pixel*hexArea;

%----------------------------------------------------------------------
%%                 Setup Hex Positions on the Screen
%----------------------------------------------------------------------

hexAreaX = numDots * (hexEdge*(sqrt(3)));
hexAreaY = numDots * hexEdge * (1.5) + (hexEdge/2);

hexAreaX = [xCenter - hexAreaX/2,  xCenter + hexAreaX/2];
hexAreaY = [yCenter - hexAreaY/2, yCenter + hexAreaY/2];

hexXpos = (hexAreaX(1) + (hexEdge)*sqrt(3)) : hexEdge*(sqrt(3)) : hexAreaX(2); 
hexYpos = (hexAreaY(1) + hexEdge) : (hexEdge + hexEdge/2) : (hexAreaY(2) - hexEdge);


%% Set higher intensities for demonstration purposes
intensities = [190, 194, 198, 202, 206, 210];
load preGenImgs\practiceControlSegments.mat;
shownImages = [];
targetImg = 210;
%----------------------------------------------------------------------
%%                      Start Experimental Loop
%----------------------------------------------------------------------
% Generate a grid with different intensities. You will use same grid for
% the rest of display session
targetSegs = [200];

% [posDots, intensityDots] = GenerateGrid(numDots, numIntensities, intensities, gradientTest);
% Generate segments
% [segments] = NormMinCut(numDots, numIntensities, intensityDots, posDots, r, sigma_I, sigma_X, nCutThr);

 
% Load layout for display session
load showSegments.mat trialLayout;

% create an empty cell to store presented segs
numTrials = length(trialLayout);
presentedSegs = cell(numTrials,2);
imagesSegs = cell(numTrials,2);
allSegs = cell(numTrials);

for TrialNo=1:numTrials
    fprintf('Trial %d starting... \n', TrialNo);
    trialSegment = trialLayout(TrialNo,1);
    trialDuration = trialLayout(TrialNo,2);
    trialControl = trialLayout(TrialNo,3);
    trialChoose = trialLayout(TrialNo,4);
    

    % Get the pre-generated image  
    segments = practiceSegments{targetImg};
    posDots = segments(1).pos;
    intensityDots = segments(1).intensity;
    intensityDots = reshape(intensityDots,10,10);                
    intensityMap = [[1:6]', intensities'];  
    
    seg = segments(TrialNo).pos;
    % Choose a segment
%     [seg, ~] = ChooseSegment(segments, trialSegment);


    allSegs{TrialNo} = segments; % add segments for future recalls

    % Order all the cut segments ascending
    sortedSegs = [segments.cutNo]; 
    [sortedNcuts, segIdx] = sort(sortedSegs(1:end)); 
    
    fprintf('Presenting Level %d, for %.2f. Control = % d \n', trialSegment, trialDuration, trialControl);
    
    % Choose segment to show        
%     choose = trialChoose; % choose one of the segments from that cut
% 
%     selectedSegIdx = [(segIdx(sortedNcuts == trialSegment))];
%     selectedSegIdx = selectedSegIdx(choose);
    
%     seg = segments(selectedSegIdx).pos;
  
    % Save intensity, segment and nCut values for future recalls
    presentedSegs{TrialNo,2} = seg; 
    presentedSegs{TrialNo,1} = intensityDots; 
            
    Priority(topPriorityLevel);
    

     % Draw image
    [imageGrid] = DrawHexagon(window, gridSecs(trialDuration), numDots, hexEdge, intensityMap, intensityDots, hexXpos, hexYpos);


    % Draw Segment 
    [imageArray, delta_int, intDiff, intStd,intOrder] = DrawHexSegment(window, intensityMap, intensityDots, seg, segSecs, hexEdge, hexXpos, hexYpos);        
  
    % Show blank screen
    DrawBlankScreen(window,blankSecs);

    % Take screenshot
    imagesSegs{TrialNo, 1} = imageGrid;
    imagesSegs{TrialNo, 2} = imageArray;

    fprintf('********************************* \n');
end
    
%% Save images
SaveImages(imagesSegs, trialLayout);
fprintf('Images saved... \n');
%% End Session
ListenChar(0); % Enable input to command window
ShowCursor();
% Clear the screen
sca;