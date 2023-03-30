function imageArray = DrawHexagon(window, imageSecs, numDots, hexEdge, intensityMap, intensityDots, hexXpos, hexYpos)


ifi=Screen('GetFlipInterval', window);
waitframes = 1;
waitduration = waitframes * ifi;

vbl = Screen('Flip', window);
vblendtime = vbl + imageSecs;

% Get the size of the on screen window in pixels.
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

frameCounter = 1;

N = numDots^2;
% Flatten the intensity array for easier computations
intensityDots = reshape(intensityDots, [N,1]);

% Transform intensity keys to values
for i=1:size(intensityMap,1)
    intensityDots(intensityDots == intensityMap(i,1)) = intensityMap(i,2);
end

% Flatten the intensity array for easier computations
intensityDots = reshape(intensityDots, [numDots,numDots]);


while (vbl < vblendtime) 
    
    % Increment the counter
    frameCounter = frameCounter + 1;

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

    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);   


    imageArray = Screen('GetImage', window, [hexXposNew(1)-2*hexEdge hexYpos(1)-2*hexEdge hexXpos(numDots)+2*hexEdge hexYpos(numDots)+2*hexEdge]);    
%     imageArray = Screen('GetImage', window);    
end


return

