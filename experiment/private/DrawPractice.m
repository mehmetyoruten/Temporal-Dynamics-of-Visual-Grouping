function [presentedPracticeSegs, respPracticeMatrix, shownPracticeFoils] = DrawPractice(window, ...
    windowRect, practiceSegments, practiceControlSegments, numPractice,numDots, fixationSecs, ...
    blankSecs, afterRespTime, gridSecs,maskSecs, practiceRespSecs,...
    segSecs, xCenter, yCenter, ...
    hexAreaX, hexAreaY, hexXpos, hexYpos, hexEdge, ...
    allCoords, lineWidthPix, textColor, topPriorityLevel, ...
    overlapThr, leafOnly, intensityMap, shownPracticeFoils, shownPracticeImgs, intensities)

%% Keyboard namings
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
% enterKey = KbName('Return');


hexArea = floor(numDots * (hexEdge*(sqrt(3))));

% create an empty cell to store presented segs
presentedPracticeSegs = cell(numPractice,2);

allPracticeSegs = cell(numPractice);

% Create arrays to store responses
respPracticeMatrix = NaN(numPractice,5);

% Create trials layout
% practiceLayout = SetExperiment(1,gridSecs, 0);
trialId = 1:numPractice;

[practiceLayout] = SetExperimentOffline(numPractice, 1, gridSecs, 0);
practiceLayout = practiceLayout{1};
% Randomly choose segments
% practiceChooseSegs = randperm(length(practiceSegments), numPractice);

% practiceChooseSegs = practiceSegments;
N = numDots^2;

%% Start trial
fprintf('********************************* \n');
fprintf('Practice trials started. \n')

for PracticeNo=1:numPractice
    fprintf('Trial %d starting... \n', PracticeNo);

    trialSegment = practiceLayout(PracticeNo,1);
    trialDuration = practiceLayout(PracticeNo,2);
    trialControl = practiceLayout(PracticeNo,3);
    
    
    segNcutVal = 1; % initial assignment for the while loop
    noIters = 0;    % keep track of number of iteration
    while segNcutVal ~= -1 % Generate images until you find a target leaf segment 
        noIters = noIters + 1;
        fprintf('Generating image with leaf nodes: %d \n', noIters)
        
        % Choose one of the partitioned images and get the initial info
        [segments, ~, ~, intensityMap, shownPracticeImgs] = ChooseImage(practiceSegments,shownPracticeImgs, trialSegment, intensities);                
        % Choose a segment
        [seg,~, ~, segNcutVal, ~] = ChooseSegment(segments, trialSegment);
    end
        

    % Retrieve the image from pre-generated images
    intensityDots = segments(1).intensity;
    % Map intensity keys to the subject specific values
    for i=1:length(intensityMap)
        intensityDots(intensityDots == intensityMap(i,1)) = intensityMap(i,2);
    end
    intensityDots = reshape(intensityDots, [numDots,numDots]);
    
    % Rotate the selected segment if control should be presented
    if trialControl == 1
        [segments, segInt, seg, shownPracticeFoils] = GenerateFoil(practiceControlSegments,segments, trialSegment,shownPracticeFoils,numDots, overlapThr,leafOnly);        
        intensityDotsControl = segments(1).intensity;
        for i=1:length(intensityMap)
            intensityDotsControl(intensityDotsControl == intensityMap(i,1)) = intensityMap(i,2);
        end
        intensityDotsControl = reshape(intensityDotsControl, [numDots,numDots]);
    else
        intensityDotsControl = intensityDots;
    end
    
    % Save intensity and segment for future recalls
    presentedPracticeSegs{PracticeNo,1} = intensityDots; 
    presentedPracticeSegs{PracticeNo,2} = seg; 
    

    fprintf('Presenting Level %d, for %.2f. Control = % d \n', trialSegment, trialDuration, trialControl);
    
    Priority(topPriorityLevel);
    responseSetting = false;

    % Draw fixation area    
    DrawFixation(window, fixationSecs, hexAreaX, hexAreaY, lineWidthPix, textColor)

    % Draw Image
    DrawHexagon(window, gridSecs(trialDuration), numDots, hexEdge, intensityMap, intensityDots, hexXpos, hexYpos);
    
    % Draw mask
    DrawMask(window, windowRect, hexArea, maskSecs);

    % Draw Segment 
    [~, delta_int] = DrawHexSegment(window, intensityMap, intensityDotsControl, seg, segSecs, hexEdge, hexXpos, hexYpos);        

    %% Get responses
    responseSetting = true;
    [reactionTime, keyCode] = GetResponse(practiceRespSecs, afterRespTime, window, xCenter, yCenter, allCoords,lineWidthPix, textColor, responseSetting);                                 

    % Show blank screen
    DrawBlankScreen(window,blankSecs);

    % respPracticeMatrix responses
    respPracticeMatrix(PracticeNo,1) = trialSegment; % Save which level you present
    respPracticeMatrix(PracticeNo,2) = trialDuration; % Save how long you present
    respPracticeMatrix(PracticeNo,3) = trialControl; % Save if you showed control
    respPracticeMatrix(PracticeNo,4) = keyCode; % Save which key you pressed
    respPracticeMatrix(PracticeNo,5) = reactionTime; % Save reaction time

    
    %% Feedback Phase
    if (trialControl+keyCode == 2) || (trialControl+keyCode == 0) 
        respLine = 'Correct Answer! \n';        
    else
        respLine = 'Wrong Answer! \n';        
    end
    
    fprintf(respLine);
    respLine2= '\n Press Enter to continue the next trial';

    exitText = false;
    while exitText == false
        % Check if a key is pressed
        [keyIsDown,~, keyCode] = KbCheck;    
        
        % Text output of mouse position draw in the centre of the screen
        DrawFormattedText(window, [respLine, respLine2], 'center', 'center', textColor, [],[],[],[2],[],[xCenter-100 yCenter*0.25 xCenter+100 yCenter*0.25 + 100]);
        
        hexXposPractice = hexXpos - hexArea;        
        shiftFromCentre = xCenter - hexXposPractice;

        % Draw Grid on the feedback secreen
        for x = 1:numDots
            for y = 1:2:numDots
                pointList = GetPointList(hexXposPractice,hexYpos, hexEdge, x,y); % Get the corners of single hexagon                    
                Screen('FillPoly', window, intensityDots(x,y), pointList);
            end  
        end
        
        hexXposNew = hexXposPractice - (hexEdge/2)*sqrt(3);
        for x = 1:numDots
            for y = 2:2:numDots
               pointList = GetPointList(hexXposNew,hexYpos, hexEdge, x,y); % Get the corners of single hexagon                    
               Screen('FillPoly', window, intensityDots(x,y), pointList);
            end  
        end

        
        % Shift the segment toward right
        hexXposPractice = hexXpos + hexArea;  
        % Draw Segment on the feedback screen
        for i = 1:size(seg,1)
            x = seg(i,1);
            y = seg(i,2);
                        
            if rem(y,2) == 0
                hexXposNew = hexXposPractice - (hexEdge/2)*sqrt(3);
            elseif rem(y,2) == 1
                hexXposNew = hexXposPractice;
            end
            pointList = GetPointList(hexXposNew,hexYpos, hexEdge, x,y); % Get the corners of single hexagon                    
%                 Screen('FillPoly', window, [255 0 0], pointList);
            Screen('FillPoly', window, delta_int(2), pointList);                
        
        end



        % Flip to the screen
        Screen('Flip', window);
%         if keyCode(enterKey)==1
        if (keyIsDown==1) && (keyCode(escapeKey) == 0)
            exitText = true;
        elseif keyCode(escapeKey) == 1
            ListenChar(0);
            sca;            
            fprintf('*** Experiment terminated *** \n');
            return
        end
    end
    fprintf('********************************* \n');
end
WaitSecs(0.3);

fprintf('Practice ended. \n')
fprintf('********************************* \n');

line1 = 'Practice trials ended.';
line2 = '\n Press any key to continue the experiment';

exitText = false;
while exitText == false
    % Check if a key is pressed
    [keyIsDown,~, keyCode] = KbCheck;    
    
    % Text output of mouse position draw in the centre of the screen
    DrawFormattedText(window, [line1, line2], 'center', 'center', textColor, [],[],[],[2]);
    
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

return
