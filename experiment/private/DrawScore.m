function DrawScore(window,white, scoreMatrix)
%DRAWTEXT Summary of this function goes here
%   Detailed explanation goes here

escapeKey = KbName('ESCAPE');

ifi=Screen('GetFlipInterval', window);
waitframes = 1;
waitduration = waitframes * ifi;


% Setup the text type for the window
% Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 25);

% Draw fixation cross
vbl = Screen('Flip', window);

% Drop NaN values
scoreMatrix = scoreMatrix(~isnan(scoreMatrix));

% Compute the score
score = 100*sum(scoreMatrix)/length(scoreMatrix);

line1 = ['Correct Answers: %', num2str(score)];
line2 = '\n You can rest until you feel ready.';
line3 = '\n Press any to continue the experiment.';

exitText = false;
while exitText == false
    % Check if a key is pressed
    [keyIsDown,~, keyCode] = KbCheck;    
    
    % Text output of mouse position draw in the centre of the screen
    DrawFormattedText(window, [line1, line2, line3], 'center', 'center', white, [],[],[],[2]);
    
    % Flip to the screen
    Screen('Flip', window);
    
%     if keyCode(enterKey)==1
    if (keyIsDown==1) && (keyCode(escapeKey) == 0)
        exitText = true;    
    elseif keyCode(KbName('ESCAPE')) == 1
        sca;
        ListenChar(0);
        fprintf('*** Experiment terminated *** \n' );
        return      
    end

end

return

