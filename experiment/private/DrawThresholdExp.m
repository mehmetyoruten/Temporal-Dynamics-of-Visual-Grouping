function [contrast, cntrst, respThr] = DrawThresholdExp(...
    window, numDots, minIntensity, numIntensities, trialsDesired, topPriorityLevel,  fixationSecs, ...
    xCenter, yCenter, hexEdge, hexAreaX, hexAreaY, ...
    hexXpos, hexYpos, allCoords, lineWidthPix, textColor, ...
    respSecs, afterRespTime, blankSecs, gradientTest, ...
    windowRect, hexArea, maskSecs)

%% Instruction parameters
pressKey = 'Press any key to continue the next page.';


upperRight = [-40  0  0 0; 
               0   0  0 40];

upperLeft = [0 40 0 0; 
             0 0 0 40];

bottomRight = [-40 0  0  0; 
                0  0  0 -40];

bottomLeft = [0 40 0  0; 
              0  0 0 -40];

textLocBottom = [xCenter-100 yCenter*1.5 xCenter+100 yCenter*1.5 + 100];
textLocTop = [xCenter-100 yCenter*0.25 xCenter+100 yCenter*0.25 + 100];
textLocTopLarge = [xCenter-100 yCenter*0.1 xCenter+100 yCenter*0.1 + 400];

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

%% Instructions - Fixation

welcome = 'Welcome to our experiment!';
fixation1 = '\n Each trial starts with a fixation window.';
fixation2 = '\n You should look in the middle of the window, at the center point between the four edges. ';

keyPress = false;
while keyPress == false
    % Text output 
    DrawFormattedText(window, [welcome, fixation1, fixation2], 'center', 'center', textColor, [],[],[],[2],[],textLocTop);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom); 
        
    
    % Upper right corner
    Screen('DrawLines', window, upperRight,lineWidthPix, textColor, [hexAreaX(2)  hexAreaY(1)], 2); 
    % Upper left corner
    Screen('DrawLines', window, upperLeft,lineWidthPix, textColor, [hexAreaX(1)  hexAreaY(1)], 2); 
    % Bottom left corner
    Screen('DrawLines', window, bottomLeft,lineWidthPix, textColor, [hexAreaX(1)  hexAreaY(2)], 2); 
    % Bottom right corner
    Screen('DrawLines', window, bottomRight,lineWidthPix, textColor, [hexAreaX(2)  hexAreaY(2)], 2); 

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


%% Instructions - Grid 

grid1 = 'After the fixation window disappears, an image made of hexagons will appear.';
grid2 = '\n The image contains six groups of hexagons, with varying brightness levels.';
grid3 = '\n After a certain time, the image will disappear.';

pracContrast = 0.071;
[~, intensityMap, intensityDots] = updateIntensity(minIntensity,numIntensities, numDots, pracContrast, gradientTest, 1);
keyPress = false;
while keyPress == false    
    % Text output 
    DrawFormattedText(window, [grid1, grid2, grid3], 'center', 'center', textColor, [],[],[],[2],[],textLocTop);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom);

    N = numDots^2;
    % Flatten the intensity array for easier computations
    intensityDots = reshape(intensityDots, [N,1]);
    
    % Transform intensity keys to values
    for i=1:size(intensityMap,1)
        intensityDots(intensityDots == intensityMap(i,1)) = intensityMap(i,2);
    end
    
    % Flatten the intensity array for easier computations
    intensityDots = reshape(intensityDots, [numDots,numDots]);

        
    % Draw 10x10 dot grid given the positions on the screen
    % Draw odd rows
    for x = 1:numDots
        for y = 1:2:numDots
            pointList = GetPointList(hexXpos,hexYpos, hexEdge, x,y); % Get the corners of single hexagon
            Screen('FillPoly', window, intensityDots(x,y), pointList);
        end  
    end
    
    % Draw even rows with a shift
    hexXposNew = hexXpos - (hexEdge/2)*sqrt(3);
    for x = 1:numDots
        for y = 2:2:numDots
           pointList = GetPointList(hexXposNew,hexYpos, hexEdge, x,y); % Get the corners of single hexagon
           Screen('FillPoly', window, intensityDots(x,y), pointList);
        end  
    end

    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi); 

    [keyIsDown,~,keyCode] = KbCheck;
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



%% Instructions - Response Phase
response0 = 'Response phase starts with a fixation cross.';
response1 = '\n If you could see 6 different segments in the presented image, please press the "UP" arrow key.';
response2 = '\n If you could not see all the 6 segments, please press the "DOWN" arrow key.';

response4 = '\n \n Please respond as fast as possible.';
response5 = '\n After you submit your response, fixation cross will change its color to black.';
response6 = '\n After it disappears, a new trial will begin.';

keyPress = false;
while keyPress == false
    DrawFormattedText(window, [response0, response1 response2, response4 response5 response6], 'center', 'center', textColor, [],[],[],[2],[],textLocTopLarge);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom);
    
    Screen('DrawLines', window, allCoords,lineWidthPix, [255 255 255], [xCenter yCenter], 2); 

    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi); 
   
    [keyIsDown,~,keyCode] = KbCheck;
    if (keyIsDown==1) && (keyCode(escapeKey) == 0)
        keyPress = true;
    elseif keyCode(escapeKey) == 1
        sca;
        ListenChar(0);
        fprintf('*** Experiment terminated *** \n');
        return
    end
end

WaitSecs(0.3);


%% Instructions - Start the Experiment
startKey = 'You can start the experiment by pressing ENTER key.';

keyPress = false;
while keyPress == false
    % Text output 
    DrawFormattedText(window, [startKey], 'center', 'center', textColor, [],[],[],[2]); 
    
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

%--------------------------------------------------------------------
%%                       QUEST parameters
%--------------------------------------------------------------------
tGuess= -1.5; % prior threshold estimate in log10
tGuessSd= 0.5;% sd of your prior
pThreshold=0.9; % threshold criterion estimate as probability of response == 1

% Weibull psychometric function parameters
beta=3.5;       % Control steepness 
delta=0.01;     % Fraction of trials on which the observers presses blindly
gamma=0.5;      % Trials where the response==1

q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma);
q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.

% Declare threshold experiment
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
    % Create stimulus with two different intensity Values
    [~, intensityMap, intensityDots] = updateIntensity(minIntensity,numIntensities, numDots, cntrst(i), gradientTest, thrExp);
    Priority(topPriorityLevel);
    % Draw fixation
    DrawFixation(window, fixationSecs, hexAreaX, hexAreaY, lineWidthPix, textColor);
    % Draw hexagons
    [~] = DrawHexagon(window, 2, numDots, hexEdge, intensityMap, intensityDots, hexXpos, hexYpos);
    % Collect response
    responseSetting = true;    
    [~, response] = GetResponse(respSecs, afterRespTime, window, xCenter, yCenter, allCoords,lineWidthPix, textColor, responseSetting);
    if response == 0
        response = 1;
    elseif response == 1
        response = 0;
    else
        response = 0;
    end

    % If it is the first trial always press yes
    if i == 1
        response = 1;
    end
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

%% Fit your results to psychometric curve
figure(2);
QuestSimulate(q,tTest,t,2);
title('Psychometric function, and the points tested.');
xlabel('log contrast');
xl=xlim;

%% Final contrast level that you will use in the experiment
contrast = 10^t;

%% Save figures
pathname = fileparts('results/my/');
pdfFig = fullfile(pathname,'thrExp_pdf.fig');
pcFig = fullfile(pathname,'thrExp_PC.fig');

savefig(figure(1),pdfFig);
savefig(figure(2),pcFig);

%% Intertitle
WaitSecs(0.3);

fprintf('Threshold experiment ended. \n')
fprintf('********************************* \n');


intertitle1 = 'First part of the experiment ended.';
intertitle2= '\n Press any key to continue the experiment';

exitText = false;
while exitText == false
    % Check if a key is pressed
    [keyIsDown,~, keyCode] = KbCheck;    
    
    % Text output of mouse position draw in the centre of the screen
    DrawFormattedText(window, [intertitle1, intertitle2], 'center', 'center', textColor, [],[],[],[2]);
    
    % Flip to the screen
    Screen('Flip', window);
    
%     if keyCode(enterKey)==1
    if keyIsDown == 1  
        exitText = true;
    elseif keyCode(escapeKey) == 1
        sca;
        ListenChar(0);
        fprintf('*** Experiment terminated *** \n');
        return
    end
end

end

