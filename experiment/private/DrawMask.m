function DrawMask(window, winRect, hexArea, maskSecs);
%UNTITLED Summary of this function goes here
    

% Draw one noise patch
numRects = 1;
rectSize = hexArea; % Default patch size is 256 by 256 noisels.
scale = 1; % Don't up- or downscale patch by default.
syncToVBL = 1; % Synchronize to vertical retrace by default.
asyncflag = 0;
dontclear = 0; % Clear backbuffer to background color by default after each bufferswap.
if dontclear > 0
    % A value of 2 will prevent any change to the backbuffer after a
    % bufferswap. In that case it is your responsibility to take care of
    % that, but you'll might save up to 1 millisecond.
    dontclear = 2;
end


ifi=Screen('GetFlipInterval', window);
waitframes = 1;
waitduration = waitframes * ifi;

vbl = Screen('Flip', window);
vblendtime = vbl + maskSecs;


% 'objRect' is a rectangle of the size 'rectSize' by 'rectSize' pixels of
% our Matlab noise image matrix:
objRect = SetRect(0,0, rectSize, rectSize);

% ArrangeRects creates 'numRects' copies of 'objRect', all nicely
% arranged / distributed in our window of size 'winRect':
dstRect = ArrangeRects(numRects, objRect, winRect);

% Now we rescale all rects: They are scaled in size by a factor 'scale':
for i=1:numRects
    % Compute center position [xc,yc] of the i'th rectangle:
    [xc, yc] = RectCenter(dstRect(i,:));
    % Create a new rectange, centered at the same position, but 'scale'
    % times the size of our pixel noise matrix 'objRect':
    dstRect(i,:)=CenterRectOnPoint(objRect * scale, xc, yc);
end

% Compute noiseimg noise image matrix with Matlab:
% Normally distributed noise with mean 128 and stddev. 50, each
% pixel computed independently:
noiseimg=(50*randn(rectSize, rectSize) + 128);

% Init framecounter to zero and take initial timestamp:
count = 0;    
tstart = GetSecs;

% Run noise image drawing loop for 1000 frames:
while (vbl < vblendtime)
    % Generate and draw 'numRects' noise images:
    for i=1:numRects

        % Convert it to a texture 'tex':
        tex=Screen('MakeTexture', window, noiseimg);

        % Draw the texture into the screen location defined by the
        % destination rectangle 'dstRect(i,:)'. If dstRect is bigger
        % than our noise image 'noiseimg', PTB will automatically
        % up-scale the noise image. We set the 'filterMode' flag for
        % drawing of the noise image to zero: This way the bilinear
        % filter gets disabled and replaced by standard nearest
        % neighbour filtering. This is important to preserve the
        % statistical independence of the noise pixels in the noise
        % texture! The default bilinear filtering would introduce local
        % correlations when scaling is applied:
        Screen('DrawTexture', window, tex, [], dstRect(i,:), [], 0);

        % After drawing, we can discard the noise texture.
        Screen('Close', tex);
    end
    
    % Done with drawing the noise patches to the backbuffer: Initiate
    % buffer-swap. If 'asyncflag' is zero, buffer swap will be
    % synchronized to vertical retrace. If 'asyncflag' is 2, bufferswap
    % will happen immediately -- Only useful for benchmarking!
    vbl = Screen('Flip', window, 0, dontclear, asyncflag);

    % Increase our frame counter:
    count = count + 1;
end

