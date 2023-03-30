function imageArray = DrawDots(window, imageSecs, numDots, dotSizePix, colorDots, dotsXpos, dotsYpos);

ifi=Screen('GetFlipInterval', window);
waitframes = 1;
waitduration = waitframes * ifi;

vbl = Screen('Flip', window);
vblendtime = vbl + imageSecs;

% Get the size of the on screen window in pixels.
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

frameCounter = 1;


while (vbl < vblendtime) 
    
    % Increment the counter
    frameCounter = frameCounter + 1;

    % Draw 10x10 dot grid given the positions on the screen
    for x = 1:numDots
        for y = 1:numDots
            Screen('DrawDots', window, [dotsXpos(x) dotsYpos(y)], dotSizePix, colorDots(x,y), [], 2);
        end  
    end

    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);   
    imageArray = Screen('GetImage', window, [dotsXpos(1)-dotSizePix dotsYpos(1)-dotSizePix dotsXpos(numDots)+dotSizePix dotsYpos(numDots)+dotSizePix]);    
end


return

