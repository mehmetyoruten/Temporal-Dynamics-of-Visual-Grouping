
% Clear the workspace and the screen
sca;
close all;
clear;

%----------------------------------------------------------------------
%%                             Screen Setup
%----------------------------------------------------------------------
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
%%                              Settings
%----------------------------------------------------------------------

% Numer of frames to wait before re-drawing
waitframes = 1;

% How long should the whole grid stay up on the screen in time and frames
gridSecs = 10;

% How long should the segment stay up on the screen in time and frames
segSecs = 2;

% Duration of the mask during flicker
maskSecs = 1.5;

% Duration of blank screen
blankSecs = 1;
practiceBlankSecs = 20; % set longer response phase for practice trials

%----------------------------------------------------------------------
%%                 Setup Dot Positions on the Screen
%----------------------------------------------------------------------
numDots = 10;
dotSizePix = 40;

screenXquarter = screenXpixels/4;
screenYquarter = screenYpixels/4;

dotArea = numDots * space;

dotAreaX = [xCenter - dotArea/2,  xCenter + dotArea/2];
dotAreaY = [yCenter - dotArea/2, yCenter + dotArea/2];


dotsYpos = linspace(dotAreaY(1), dotAreaY(2), numDots);
dotsXpos = linspace(dotAreaX(1), dotAreaX(2), numDots);

%----------------------------------------------------------------------
%%                 Flip to Screen
%----------------------------------------------------------------------
intensityDots

% Draw dots
DrawDots(window, gridSecs(trialDuration), numDots, dotSizePix, intensityDots, dotsXpos, dotsYpos);
