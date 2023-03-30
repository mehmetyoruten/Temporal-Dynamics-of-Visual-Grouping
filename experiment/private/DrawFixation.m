function DrawFixation(window, fixationSecs, hexAreaX, hexAreaY, lineWidthPix, textColor)
% Draw fixation cross in the center of the screen

ifi=Screen('GetFlipInterval', window);
waitframes = 1;
waitduration = waitframes * ifi;

% Draw fixation cross
vbl = Screen('Flip', window);
vblendtime = vbl + fixationSecs;

upperRight = [-40  0  0 0; 
               0   0  0 40];

upperLeft = [0 40 0 0; 
             0 0 0 40];

bottomRight = [-40 0  0  0; 
                0  0  0 -40];

bottomLeft = [0 40 0  0; 
              0  0 0 -40];


while (vbl < vblendtime)
%     Screen('DrawLines', window, allCoords,lineWidthPix, textColor, [xCenter yCenter], 2); 
    
    % Upper right corner
    Screen('DrawLines', window, upperRight,lineWidthPix, textColor, [hexAreaX(2)  hexAreaY(1)], 2); 
    % Upper left corner
    Screen('DrawLines', window, upperLeft,lineWidthPix, textColor, [hexAreaX(1)  hexAreaY(1)], 2); 
    % Bottom left corner
    Screen('DrawLines', window, bottomLeft,lineWidthPix, textColor, [hexAreaX(1)  hexAreaY(2)], 2); 
    % Bottom right corner
    Screen('DrawLines', window, bottomRight,lineWidthPix, textColor, [hexAreaX(2)  hexAreaY(2)], 2); 
    

    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end

return

