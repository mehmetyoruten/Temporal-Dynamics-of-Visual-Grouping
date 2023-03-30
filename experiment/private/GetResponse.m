function   [rt, respMade] = GetResponse(blankSecs, afterRespTime, window, xCenter, yCenter, allCoords, lineWidthPix, textColor, responseSetting)

% Collect reaction time (in ms) and key presses from each trial.
% 0 for left, 1 for right, and -1 when no key was pressed.

ifi=Screen('GetFlipInterval', window); 
waitframes = 1;
waitduration = waitframes * ifi;


vbl=Screen('Flip', window);
startTime = vbl;
vblendtime= vbl + blankSecs; 


% -2 when there is no response    
respMade = NaN;  
% If no key is pressed
rt = NaN;
while (vbl < vblendtime)
    % Listen for keyboard press    
    
    [~, responseTime, keyCode, ~] = KbCheck;
    if (keyCode(KbName('UpArrow')) == 1)  && (responseSetting == true)
        respMade = 0;
        responseSetting = false;        
        rt = 1000.*(responseTime - startTime);    
        fprintf('Left Key was pressed \n');
        fprintf('RT: %f \n', rt);
        textColor = [0];
        vblendtime = vbl + afterRespTime;
                
    elseif (keyCode(KbName('DownArrow'))  == 1) && (responseSetting == true)
        respMade = 1;
        responseSetting = false;        
        rt = 1000.*(responseTime - startTime); 
        fprintf('Right Key was pressed \n');        
        fprintf('RT: %f \n', rt);
        textColor = [0];            
        vblendtime = vbl + afterRespTime;
        
    elseif keyCode(KbName('ESCAPE')) == 1
        sca;
        fprintf('*** Experiment terminated *** \n');
        return
    end  
    
    Screen('DrawLines', window, allCoords,lineWidthPix, textColor, [xCenter yCenter], 2); 

%     % Upper right corner
%     Screen('DrawLines', window, upperRight,lineWidthPix, textColor, [dotAreaX(2)  dotAreaY(1)], 2); 
%     % Upper left corner
%     Screen('DrawLines', window, upperLeft,lineWidthPix, textColor, [dotAreaX(1)  dotAreaY(1)], 2); 
%     % Bottom left corner
%     Screen('DrawLines', window, bottomLeft,lineWidthPix, textColor, [dotAreaX(1)  dotAreaY(2)], 2); 
%     % Bottom right corner
%     Screen('DrawLines', window, bottomRight,lineWidthPix, textColor, [dotAreaX(2)  dotAreaY(2)], 2); 

    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi); % time of flip
    
end

return