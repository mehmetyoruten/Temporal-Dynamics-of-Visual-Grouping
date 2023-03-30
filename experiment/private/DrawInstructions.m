function DrawInstructions(window, xCenter, yCenter, allCoords, lineWidthPix, numDots, hexEdge, hexAreaX, hexAreaY, hexXpos, hexYpos, textColor, intensityMap)


%% Assign keys
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

%% Set the segment to present
load preGenImgs/instructionSegments.mat segments;
% intensityDots = reshape(segments(1).intensity,[10,10]);

intensityDots = segments(1).intensity;

% Transform intensity keys to values
for i=1:size(intensityMap,1)
    intensityDots(intensityDots == intensityMap(i,1)) = intensityMap(i,2);
end

avgImgIntensity = mean(intensityDots,'all');
colorDots = reshape(intensityDots,[10,10]);


%% Set the positions of fixation area


upperRight = [-40  0  0 0; 
               0   0  0 40];

upperLeft = [0 40 0 0; 
             0 0 0 40];

bottomRight = [-40 0  0  0; 
                0  0  0 -40];

bottomLeft = [0 40 0  0; 
              0  0 0 -40];

pressKey = 'Press any key to continue the next page.';

textLocBottom = [xCenter-100 yCenter*1.5 xCenter+100 yCenter*1.5 + 100];
textLocTop = [xCenter-100 yCenter*0.25 xCenter+100 yCenter*0.25 + 100];
textLocTopLarge = [xCenter-100 yCenter*0.1 xCenter+100 yCenter*0.1 + 400];

%% Fixation instructions
fixation1 = 'Each trial starts with a fixation window.';
fixation2 = '\n You should look in the middle of the window, at the center point between the four edges. ';

keyPress = false;
while keyPress == false
    % Text output 
    DrawFormattedText(window, [fixation1, fixation2], 'center', 'center', textColor, [],[],[],[2],[],textLocTop);
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

%% Grid Instructions
grid1 = 'After the fixation window disappears, an image made of hexagons will appear.';
grid2 = '\n The image contains six groups of hexagons, with varying brightness levels.';
grid3 = '\n You will be able to look at the image before it disappears, followed by a noisy screen.';


vblendtime= vbl + 5; 
while (vbl < vblendtime)

    % Text output 
    DrawFormattedText(window, [grid1, grid2, grid3], 'center', 'center', textColor, [],[],[],[2],[],textLocTop);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom);
    
    % Draw 10x10 dot grid given the positions on the screen
    % Draw each row separately
    for x = 1:numDots
        for y = 1:2:numDots
            pointList = [hexXpos(x), hexYpos(y) - (hexEdge);
                         hexXpos(x) + (hexEdge/2)*sqrt(3), hexYpos(y) - (hexEdge/2);
                         hexXpos(x) + (hexEdge/2)*sqrt(3), hexYpos(y) + (hexEdge/2);
                         hexXpos(x), hexYpos(y) + (hexEdge);
                         hexXpos(x) - (hexEdge/2)*sqrt(3), hexYpos(y) + (hexEdge/2);
                         hexXpos(x) - (hexEdge/2)*sqrt(3), hexYpos(y) - (hexEdge/2);];
            Screen('FillPoly', window, colorDots(x,y), pointList);
        end  
    end
    
    hexXposNew = hexXpos - (hexEdge/2)*sqrt(3);
    for x = 1:numDots
        for y = 2:2:numDots
            pointList = [hexXposNew(x), hexYpos(y) - (hexEdge);
                         hexXposNew(x) + (hexEdge/2)*sqrt(3), hexYpos(y) - (hexEdge/2);
                         hexXposNew(x) + (hexEdge/2)*sqrt(3), hexYpos(y) + (hexEdge/2);
                         hexXposNew(x), hexYpos(y) + (hexEdge);
                         hexXposNew(x) - (hexEdge/2)*sqrt(3), hexYpos(y) + (hexEdge/2);
                         hexXposNew(x) - (hexEdge/2)*sqrt(3), hexYpos(y) - (hexEdge/2);];
           Screen('FillPoly', window, colorDots(x,y), pointList);
        end  
    end
    
    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi); % time of flip
end

keyPress = false;
while keyPress == false    
    % Text output 
    DrawFormattedText(window, [grid1, grid2, grid3], 'center', 'center', textColor, [],[],[],[2],[],textLocTop);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom);

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

%% Segment Instructions
segment1 = 'In the next step of the experiment, a segment with hexagons will appear.';
segment2 = '\n Your task is to decide if the segment belongs to the image.';
segment3 = '\n You can submit your response after the segment disappears.';

seg = segments(9).pos;

keyPress = false;
while keyPress == false
    [keyIsDown,~,keyCode] = KbCheck;
    if (keyIsDown==1) && (keyCode(escapeKey) == 0)
        keyPress = true;
    elseif keyCode(escapeKey) == 1
        sca;
        ListenChar(0);
        fprintf('*** Experiment terminated *** \n');
        return
    end
    
    DrawFormattedText(window, [segment1 segment2 segment3], 'center', 'center', textColor, [],[],[],[2],[],textLocTop);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom);

    for i = 1:size(seg,1)
        x = seg(i,1);
        y = seg(i,2);       
            
        if rem(x,2) == 0
            hexXposNew = hexXpos - (hexEdge/2)*sqrt(3);
        elseif rem(x,2) == 1
            hexXposNew = hexXpos;
        end        

        pointList = [hexXposNew(y), hexYpos(x) - (hexEdge);
                     hexXposNew(y) + (hexEdge/2)*sqrt(3), hexYpos(x) - (hexEdge/2);
                     hexXposNew(y) + (hexEdge/2)*sqrt(3), hexYpos(x) + (hexEdge/2);
                     hexXposNew(y), hexYpos(x) + (hexEdge);
                     hexXposNew(y) - (hexEdge/2)*sqrt(3), hexYpos(x) + (hexEdge/2);
                     hexXposNew(y) - (hexEdge/2)*sqrt(3), hexYpos(x) - (hexEdge/2);];

        Screen('FillPoly', window, [avgImgIntensity avgImgIntensity avgImgIntensity], pointList);           
            
    end

    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi); 
end

WaitSecs(0.3);
%% Response Instructions
response1 = 'If you think that the displayed segment belongs to the image, press the "UP" arrow key.';
response2 = '\n If you think that the displayed segment does not belong to the image, press the "DOWN" arrow key.';
response3 = '\n \n Remember that some of the segments do not belong to the image.';
response4 = '\n Please respond as fast as possible.';
response5 = '\n After you submit your response, fixation cross will change its color to black.';
response6 = '\n After it disappears, a new trial will begin.';

keyPress = false;
while keyPress == false
    DrawFormattedText(window, [response1 response2 response3 response4 response5 response6], 'center', 'center', textColor, [],[],[],[2],[],textLocTopLarge);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom);
    
    Screen('DrawLines', window, allCoords,lineWidthPix, [0 0 0], [xCenter yCenter], 2); 


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

%% Start button
startpractice1 = 'You can start the practice trials by pressing any key.';

keyPress = false;
while keyPress == false

    % Text output of mouse position draw in the centre of the screen
    DrawFormattedText(window, [startpractice1], 'center', 'center', textColor);

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


return