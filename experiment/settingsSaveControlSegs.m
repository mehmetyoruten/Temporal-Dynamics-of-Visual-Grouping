% Settings for image sequence experiment


% Clear the workspace and the screen

gradientTest = false;
hexagonTest = true;
segTest = false;
leafOnly = false;
noControl = true;

%----------------------------------------------------------------------
%%                          Participant Info
%----------------------------------------------------------------------
% Participant initials
participant = 'testImages';

%----------------------------------------------------------------------
%%                          Screen Settings
%----------------------------------------------------------------------
W = 47.5;   %  Width of the monitor (cm)
H = 30;     %  Height of the monitor (cm)
X = 1920;   %  X Resolution (px)
Y = 1200;   %  Y Resolution (px)
V = 120;    %  Viewing Distance (cm)

[pixels_per_degree, degrees_per_pixel] = angle_pixels(X, Y, W, H, V);

%----------------------------------------------------------------------
%%             Initialize Parameters for Norm Min Cut
%----------------------------------------------------------------------
r = 1.5;
sigma_I = .005;
sigma_X = 2;
nCutThr = 1;

%----------------------------------------------------------------------
%%                 Setup Dot Positions on the Screen
%----------------------------------------------------------------------

% Dot size in pixels
dotDiameter = 40;

numDots = 10;
numIntensities = 6;
space = 0; 

% Area that dots occupy
dotArea = (numDots * dotDiameter) + (numDots*space);
%----------------------------------------------------------------------
%%                 Setup Hexagon Positions on the Screen
%----------------------------------------------------------------------
hexEdge = 15;   % for 3 deg
% hexEdge = 19.5; % for 4 deg

% Area that hexagons occupy
hexArea = floor(numDots * (hexEdge*(sqrt(3))));
hexAreaDeg = degrees_per_pixel*hexArea;

%----------------------------------------------------------------------
%%                      Setup the Fixation Cross
%----------------------------------------------------------------------

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 2*hexEdge;

% Set the line width for our fixation cross
lineWidthPix = 4;

%----------------------------------------------------------------------
%%                     Setup Intensity Levels
%----------------------------------------------------------------------
% % for gray background
% intensities = linspace(30,gray-20,numIntensities);
% intensities = linspace(194,white-50,numIntensities);
intensities = linspace(190,255-50,numIntensities);

% for white background
% intensities = linspace(160,white-50,numIntensities);

% % for white background dots
% intensities = linspace(90,white-50,numIntensities);

% % for black background
% intensities = linspace(75,white-20,numIntensities);

%----------------------------------------------------------------------
%%                          Setup Colors
%----------------------------------------------------------------------
% backgroundColor = black;
% textColor = white;

backgroundColor = gray;
textColor = white;
% 
% backgroundColor = white;
% textColor = black;

%----------------------------------------------------------------------
%%                          Foil Information
%----------------------------------------------------------------------
% Set the threshold for generating foils. If the overlap is higher than
% thr, it will keep looking for another segment from the previous trials
overlapThr = 0.2;

%----------------------------------------------------------------------
%%                       Timing Information
%----------------------------------------------------------------------
% Interstimulus interval time in seconds and frames
isiTimeSecs = 1;

% Numer of frames to wait before re-drawing
waitframes = 1;

% Numer of frames to show fixation cross
fixationSecs = 0.05;

% How long should the whole grid stay up on the screen in time and frames
% gridSecs = [0.8 2];
% gridSecs = [0.6 1.2];
gridSecs = [0.05 0.05];


% How long should the segment stay up on the screen in time and frames
segSecs = 0.05;

% Duration of the mask during flicker
maskSecs = 0.05;

% Duration of the response screen
respSecs = 0.05;
afterRespTime = 0.05;
practiceRespSecs = 0.05; % set longer response phase for practice trials

% Duration of blank screen
blankSecs = 0.05;

%----------------------------------------------------------------------
%%                       Experimental Settings
%----------------------------------------------------------------------
% % screenNumber=1; % If you want to show the experiment in the other screen
numPractice = 1;    
numBlocks = 1;
numTest = 5000; % how many times you will
% Number
numTrials = 5*length(gridSecs)*2 * numTest; 
thrExp = 0;

%----------------------------------------------------------------------
%%                         Save the Settings
%----------------------------------------------------------------------
settings = cell(4,1);
settings{1} = gridSecs;                         % Image presentation duration
settings{2} = intensities;                      % Intensity range
settings{3} = [r, sigma_I, sigma_X, nCutThr];   % NormMinCut parameters    
settings{4} = hexEdge;                          % Size of hexagon edge
