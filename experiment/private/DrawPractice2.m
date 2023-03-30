function [allPracticeSegs, respPracticeMatrix] = DrawPractice2(window, windowRect, numPractice,numDots, numIntensities, intensities, gradientTest, r, sigma_I, sigma_X, nCutThr,fixationSecs, blankSecs, practiceRespSecs, afterRespTime, gridSecs,maskSecs, segSecs, xCenter, yCenter, dotsXpos, dotsYpos, dotSizePix, dotAreaX, dotAreaY, hexAreaX, hexAreaY, hexXpos, hexYpos, hexEdge, space, allCoords, lineWidthPix, textColor, topPriorityLevel, hexagonTest)

%% Keyboard namings
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
enterKey = KbName('return');


hexArea = floor(numDots * (hexEdge*(sqrt(3))));
dotArea = numDots * dotSizePix;
maskArea = dotArea + dotSizePix;

% create an empty cell to store presented segs
presentedPracticeSegs = cell(numPractice,2);

allPracticeSegs = cell(numPractice);

% Create arrays to store responses
respPracticeMatrix = NaN(numPractice,5);

% Create trials layout
practiceLayout = SetExperiment(1, gridSecs);

%% Start trial
fprintf('********************************* \n');
fprintf('Practice trials started. \n')

for PracticeNo=1:numPractice
    fprintf('Trial %d starting... \n', PracticeNo);

    trialSegment = practiceLayout(PracticeNo,1);
    trialDuration = practiceLayout(PracticeNo,2);
    trialControl = practiceLayout(PracticeNo,3);

    % Generate random grid with different intensities
    [posDots, intensityDots] = GenerateGrid(numDots, numIntensities, intensities, gradientTest);
    

    % Generate segments
    [segments] = NormMinCut(numDots, numIntensities, intensityDots, posDots, r, sigma_I, sigma_X, nCutThr);
    allPracticeSegs{PracticeNo} = segments; % add segments for future recalls

    % Order all the cut segments ascending
    sortedSegs = [segments.cutNo];
    [sortedNcuts, segIdx] = sort(sortedSegs(2:end)); % do not consider the initial grid as segment
    
    % Choose segment to show        
    choose = randi(2); % choose one of the segments from that cut
%         seg = segments(segIdx(trialSegment)).pos;
    selectedSegIdx = [(segIdx(sortedNcuts == trialSegment))];
    selectedSegIdx = selectedSegIdx(choose);
    selectedSegIdx = selectedSegIdx + 1;
    
    seg = segments(selectedSegIdx).pos;
    segNcut = sortedNcuts(segIdx(trialSegment));    
    
            
    
    % Rotate the selected segment if control should be presented
    if trialControl == 1
        overlapThr = 1;
        seg = GenerateFoil(segments,seg, trialSegment,numDots, 270, overlapThr, true);        
    end
    
    % Save intensity and segment for future recalls
    presentedPracticeSegs{PracticeNo,1} = seg; 
    presentedPracticeSegs{PracticeNo,2} = intensityDots; 

    fprintf('Presenting Level %d, for %.2f. Control = % d \n', trialSegment, trialDuration, trialControl);
    
    Priority(topPriorityLevel);
    responseSetting = false;

    % Draw fixation area
    DrawFixation(window, fixationSecs, xCenter, yCenter, dotAreaX, dotAreaY, hexAreaX, hexAreaY, space, allCoords, lineWidthPix, textColor, hexagonTest);
    
    % Draw Segment 
    if hexagonTest == false
        DrawSegment(window, intensityDots, seg, segSecs, dotSizePix, dotsXpos, dotsYpos);
    else
        DrawHexSegment(window, intensityDots, seg, segSecs, hexEdge, hexXpos, hexYpos);
    end
    
    % Draw mask
    DrawMask(window, windowRect, maskArea, maskSecs);

    % Draw image
    if hexagonTest == false
        % Draw dots
        DrawDots(window, gridSecs(trialDuration), numDots, dotSizePix, intensityDots, dotsXpos, dotsYpos);
    else
        % Draw hexagons
        imageArray = DrawHexagon(window, gridSecs(trialDuration), numDots, hexEdge, intensityDots, hexXpos, hexYpos);
    end
    

    %% Get responses
    responseSetting = true;
%     [reactionTime, keyCode] = GetResponse(practiceBlankSecs, window, responseSetting); 
    [reactionTime, keyCode] = GetResponse(practiceRespSecs, afterRespTime, window, xCenter, yCenter, dotAreaX, dotAreaY,hexAreaX, hexAreaY, allCoords, lineWidthPix, textColor, hexagonTest, responseSetting);

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
        if hexagonTest == true
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
        
        else
            for x = 1:numDots
                for y = 1:numDots
                    Screen('DrawDots', window, [dotsXpos(x)-dotArea dotsYpos(y)], dotSizePix, intensityDots(x,y), [], 2);
                end  
            end
        end
        
        % Shift the segment toward right
        hexXposPractice = hexXpos + hexArea;  
        % Draw Segment on the feedback screen
        for i = 1:size(seg,1)
            x = seg(i,1);
            y = seg(i,2);
            
            if hexagonTest == true
                if rem(y,2) == 0
                    hexXposNew = hexXposPractice - (hexEdge/2)*sqrt(3);
                elseif rem(y,2) == 1
                    hexXposNew = hexXposPractice;
                end
                pointList = GetPointList(hexXposNew,hexYpos, hexEdge, x,y); % Get the corners of single hexagon                    
%                 Screen('FillPoly', window, [255 0 0], pointList);
                Screen('FillPoly', window, mean(intensities), pointList);                
            elseif hexagonTest == false
%                 Screen('DrawDots', window, [dotsXpos(x)+ dotArea dotsYpos(y)], dotSizePix, [255 0 0], [], 2);
                % Draw empty circles
                Screen('FrameOval',window,[0 0 0],[(dotsXpos(x)+dotArea-dotSizePix/2) (dotsYpos(y)-dotSizePix/2) (dotsXpos(x)+ dotArea+dotSizePix/2) (dotsYpos(y)+ dotSizePix/2)], 2);
            end
        end



        % Flip to the screen
        Screen('Flip', window);
    
        if (keyIsDown==1) && (keyCode(escapeKey) == 0)
            exitText = true;
        elseif keyCode(escapeKey) == 1
            sca;
            ListenChar(0);
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

    if (keyIsDown==1) && (keyCode(escapeKey) == 0)
        exitText = true;
    elseif keyCode(escapeKey) == 1
        sca;
        ListenChar(0);
        fprintf('*** Experiment terminated *** \n');
        return
    end
end

return
