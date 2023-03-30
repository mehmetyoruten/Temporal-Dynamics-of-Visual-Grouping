function DrawSegment(window, intensityDots, seg, imageSecs, dotSizePix, dotsXpos, dotsYpos)

ifi=Screen('GetFlipInterval', window);
waitframes = 1;
waitduration = waitframes * ifi;

vbl = Screen('Flip', window);
vblendtime = vbl + imageSecs;

% Get the size of the on screen window in pixels.
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

frameCounter = 1;


segIntensityArray = nan(length(seg),1);
for i=1:length(seg)
    segIntensityArray(i) = intensityDots(seg(i,1),seg(i,2));
end
avrgSegIntensity = sum(segIntensityArray)/length(segIntensityArray);


while (vbl < vblendtime) 
    
    % Increment the counter
    frameCounter = frameCounter + 1;

    % Draw 10x10 dot grid given the positions on the screen

    for i = 1:size(seg,1)
        x = seg(i,1);
        y = seg(i,2);
                
        % Screen('DrawDots', window, [dotsXpos(x) dotsYpos(y)], dotSizePix, avrgSegIntensity, [], 2);
        % Draw empty circles
        Screen('FrameOval',window,[0 0 0],[(dotsXpos(x)-dotSizePix/2) (dotsYpos(y)-dotSizePix/2) (dotsXpos(x)+dotSizePix/2) (dotsYpos(y)+ dotSizePix/2)], 2);
    end

    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);   
end


end


% EnableDataPixxM16Output()