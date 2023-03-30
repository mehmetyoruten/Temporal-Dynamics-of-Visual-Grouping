% Mehmet Yoruten, June 2022
% Visual Hiearhical Perception
% Computational Principles of Intelligence Lab
% Max Planck Institute for Biological Cybernetics


% Clear the workspace and the screen
sca;

close all;
clear;


%% Keyboard namings
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');

% enterKey = KbName('space');
enterKey = KbName('return');


% Setup the text type for the window
% Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 25);

vbl = Screen('Flip', window);
ifi=Screen('GetFlipInterval', window);
waitframes = 1;
waitduration = waitframes * ifi;

%% Draw Introduction
pressKey = 'Press any key to continue start the experiment.';

keyPress = false;

while keyPress == false
    % Text output 
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2]); 
    
    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi); 
   
    [keyIsDown,~,keyCode] = KbCheck;
%     if keyCode(enterKey)==1
    if (keyIsDown==1) && (keyCode(escapeKey) == 0)
        keyPress = true;
    elseif keyCode(escapeKey) == 1
        ListenChar(0);
        sca;
        fprintf('*** Experiment terminated *** \n');
        return
    end
end
WaitSecs(0.3);

%----------------------------------------------------------------------
%%                             Screen Setup
%----------------------------------------------------------------------
PsychImaging('PrepareConfiguration')
PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');

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
%%                       QUEST parameters
%--------------------------------------------------------------------
tGuess= -3; % prior threshold estimate in log10
tGuessSd= 4;% sd of your prior
pThreshold=0.9; % threshold criterion estimate as probability of response == 1

% Weibull psychometric function parameters
beta=2.5;       % Control steepness 
delta=0.01;     % Fraction of trials on which the observers presses blindly
gamma=0.5;      % Trials where the response==1

q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma);
q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.

trialsDesired=80;
% Declare that it is threshold experiment
thrExp = 1;
%----------------------------------------------------------------------
%%                      Start Experimental Loop
%----------------------------------------------------------------------

% Store responses and contrasts
respThr = zeros(trialsDesired,1);
cntrst = zeros(trialsDesired,1);

for i=1:trialsDesired
    fprintf('\n\n Trial %d starting... \n', i);
    % Get Quest recommendation for the next trial intensity
    tTest = QuestQuantile(q);
    % Contrast levels are on log scale, transform it here for drawing
    cntrst(i)=10^(tTest);
    
    fprintf('Contrast is %.4f.\n', cntrst(i));
    % Generate stimulus with the new contrast value
    [posDots, intensityMap, intensityDots] = updateIntensity(minIntensity,numIntensities, numDots, cntrst(i), gradientTest, thrExp);
    Priority(topPriorityLevel);
    % Draw fixation
    DrawFixation(window, fixationSecs, xCenter, yCenter, dotAreaX, dotAreaY, hexAreaX, hexAreaY, space, allCoords, lineWidthPix, textColor, hexagonTest);
    % Draw hexagons
    [imageGrid] = DrawHexagon(window, 2, numDots, hexEdge, intensityMap, intensityDots, hexXpos, hexYpos);
    % Collect response
    responseSetting = true;
    [reactionTime, response] = GetResponse(respSecs, afterRespTime, window, xCenter, yCenter, dotAreaX, dotAreaY,hexAreaX, hexAreaY, allCoords,lineWidthPix, textColor, hexagonTest, responseSetting);                                 
        
    if response == 0
        response = 1;
    elseif response == 1
        response = 0;
    else
        response = 0;
    end
    
    % Save the response
    respThr(i) = response;

    % Show blank screen
    DrawBlankScreen(window,blankSecs);
    
    % Draw mask
    DrawMask(window, windowRect, hexArea, maskSecs);
    
    % Update pdf
    q=QuestUpdate(q,tTest,response); % Add the new datum (actual test intensity and observer response) to the database.
    
    figure(1)
    plot(q.x+q.tGuess,q.pdf)
    title('Posterior PDF');
    xlabel('log contrast');
    hold on
end


t=QuestMean(q);  % Recommended by Pelli (1989) and King-Smith et al. (1994). Still our favorite.
sd=QuestSd(q);
fprintf('Final threshold estimate (mean+-sd) is %.2f +- %.2f\n',t,sd);
contrast = 10^cntrst(i);

%% Fit your results to psychometric curve
figure(2);
QuestSimulate(q,tTest,t,2);
title('Psychometric function, and the points tested.');
xlabel('log contrast');
xl=xlim;

%% Save results
% Save figures
pathname = fileparts('results/figs/');
pdfFig = fullfile(pathname,'thrExp_pdf.fig');
pcFig = fullfile(pathname,'thrExp_PC.fig');

savefig(figure(1),pdfFig);
savefig(figure(2),pcFig);

% Save results
filename = sprintf('%s_thr_results.mat', participant);
save(filename, 'q','contrast');

%% End the experiment
sca
ListenChar(0); % Enable input to command window
ShowCursor();