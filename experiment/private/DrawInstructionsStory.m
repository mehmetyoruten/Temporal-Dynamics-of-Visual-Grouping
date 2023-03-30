function DrawInstructionsStory(window, xCenter, yCenter, allCoords, lineWidthPix, numDots, hexEdge, hexAreaX, hexAreaY, hexXpos, hexYpos, textColor)


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
load instructionSegments.mat;
colorDots = reshape(segments(1).intensity,[10,10]);
avgImgIntensity = mean(colorDots,'all');

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


%% Cover story page 1 - Show Grid
grid1 = 'Welcome to join our human exploration team!';
grid2 = '\n\n You are a geographer landing on an alien planet. You will be seeing some pebble maps on this planet.';
grid3 = '\n We invited you here to categorize some of the pebbles. Due to gravitational distortion, every piece of pebble is in the shape of a hexagon on this planet.';

keyPress = false;
while keyPress == false
    % Text output 
    DrawFormattedText(window, [grid1, grid2, grid3], 'center', 'center', textColor, [],[],[],[2],[],textLocTop);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom); 
    
    % Draw Hexagons
    for colNo = 1:numDots
        for rowNo = 1:2:numDots
            pointList = GetPointList(hexXpos,hexYpos, hexEdge, colNo,rowNo);
            Screen('FillPoly', window, colorDots(colNo,rowNo), pointList);
        end  
    end
    
    hexXposNew = hexXpos - (hexEdge/2)*sqrt(3);
    for colNo = 1:numDots
        for rowNo = 2:2:numDots
            pointList = GetPointList(hexXposNew,hexYpos, hexEdge, colNo,rowNo);
           Screen('FillPoly', window, colorDots(colNo,rowNo), pointList);
        end  
    end

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

%% Cover story page 2 - Show cut1 segment
segment1 = '\n The geographical situation on this continent is: that similar pebble regions will have similar intensity (they will look similar).';
segment2 = '\n For example, this is one case where this will happen';

% Choose segment
seg = segments(5).pos;

keyPress = false;
while keyPress == false
    % Text output 
    DrawFormattedText(window, [segment1, segment2], 'center', 'center', textColor, [],[],[],[2],[],textLocTop);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom); 
   
    for i = 1:size(seg,1)
        colNo = seg(i,1);
        rowNo = seg(i,2);       
  
        if rem(rowNo,2) == 0
            hexXposNew = hexXpos - (hexEdge/2)*sqrt(3);
        elseif rem(rowNo,2) == 1
            hexXposNew = hexXpos;
        end        

        pointList = GetPointList(hexXposNew,hexYpos, hexEdge, colNo,rowNo);
        
        Screen('FillPoly', window, avgImgIntensity, pointList);  
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


%% Cover story page 3 - Show grid for a limited time
story6 = 'This is a challenging job, you need to look at the pebble map.';
story7 = '\n Because we have really bad detectors on this planet, once a pebble map is opened, they will vanish in a short amount of time.';
story8 = '\n Therefore you will only be able to see the map for a moment.';

vbl=Screen('Flip', window);
vblendtime= vbl + 5; 

while (vbl < vblendtime)
    DrawFormattedText(window, [story6,story7,story8], 'center', 'center', textColor, [],[],[],[2],[],textLocTop);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom); 
    
     % Draw Hexagons
    for colNo = 1:numDots
        for rowNo = 1:2:numDots
            pointList = GetPointList(hexXpos,hexYpos, hexEdge, colNo,rowNo);            
            Screen('FillPoly', window, colorDots(colNo,rowNo), pointList);
        end  
    end
    
    hexXposNew = hexXpos - (hexEdge/2)*sqrt(3);
    for colNo = 1:numDots
        for rowNo = 2:2:numDots
           pointList = GetPointList(hexXposNew,hexYpos, hexEdge, colNo,rowNo);
           Screen('FillPoly', window, colorDots(colNo,rowNo), pointList);
        end  
    end


    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi); % time of flip
end


keyPress = false;
while keyPress == false
    % Text output 
    DrawFormattedText(window, [story6,story7,story8], 'center', 'center', textColor, [],[],[],[2],[],textLocTop);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom); 
    

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

%% Cover story page 4 - Segment
segment1 = 'Once a map vanishes, an alien will show you an outline of pebble regions.';
segment2 = '\n And ask you whether you see patches of the earth or not.';

seg = segments(8).pos;
keyPress = false;
while keyPress == false
    % Text output 
    DrawFormattedText(window, [segment1, segment2], 'center', 'center', textColor, [],[],[],[2],[],textLocTop);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom); 
  
     for i = 1:size(seg,1)
        colNo = seg(i,1);
        rowNo = seg(i,2);       
    
        if rem(rowNo,2) == 0
            hexXposNew = hexXpos - (hexEdge/2)*sqrt(3);
        elseif rem(rowNo,2) == 1
            hexXposNew = hexXpos;
        end        

        pointList = GetPointList(hexXposNew,hexYpos, hexEdge, colNo,rowNo);
        Screen('FillPoly', window, avgImgIntensity, pointList);  
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


%% Cover Story 5 - Response
response1 = 'The aliens can only receive your signal when the pebble vanishes, and a fixation cross shows up.';
response2= '\n When the cross turns green, it means that the alien has received your signal.';

keyPress = false;
while keyPress == false
    DrawFormattedText(window, [response1, response2], 'center', 'center', textColor, [],[],[],[2],[],textLocTopLarge);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom);
    
    Screen('DrawLines', window, allCoords,lineWidthPix, [255 255 255], [xCenter-100 yCenter], 2); 
    Screen('DrawLines', window, allCoords,lineWidthPix, [0 0 0], [xCenter+100 yCenter], 2); 

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

%% Cover Story 5 - Control
control1 = 'But be careful, the aliens are sneaky. They will sometimes show you pebble groups that are not in the map, like this one.';
control2= '\n Your job as a geographer is to respond correctly to the pebble groups showed by aliens, whether it belong to the map, or not.';


keyPress = false;
while keyPress == false
    DrawFormattedText(window, [control1, control2], 'center', 'center', textColor, [],[],[],[2],[],textLocTopLarge);
    DrawFormattedText(window, [pressKey], 'center', 'center', textColor, [],[],[],[2],[],textLocBottom);
    

    for i = 1:size(controlSeg,1)
        colNo = controlSeg(i,1);
        rowNo = controlSeg(i,2);       
  
        if rem(rowNo,2) == 0
            hexXposNew = hexXpos - (hexEdge/2)*sqrt(3);
        elseif rem(rowNo,2) == 1
            hexXposNew = hexXpos;
        end        

        pointList = GetPointList(hexXposNew,hexYpos, hexEdge, colNo,rowNo);
        
        Screen('FillPoly', window, avgImgIntensity, pointList);  
    end

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

%% Fixation instructions
fixation1 = 'Each of your tasks will start with a fixation window.';
fixation2 = '\n You should look in the middle of the window, at the center point between the four edges before starting your analysis.';


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