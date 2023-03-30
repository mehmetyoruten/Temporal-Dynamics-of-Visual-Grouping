function DrawBlankScreen(window,blankSecs)
%DRAWBLANKSCREEN Summary of this function goes here
%   Detailed explanation goes here

ifi=Screen('GetFlipInterval', window); 
waitframes = 1;
waitduration = waitframes * ifi;

vbl=Screen('Flip', window);
startTime = vbl;
vblendtime= vbl + blankSecs; 

while (vbl < vblendtime)
    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi); % time of flip
end


end

