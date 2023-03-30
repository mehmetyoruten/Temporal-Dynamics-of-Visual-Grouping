function [segments, posDots, intensityDots, intensityMap, shownImages, chosenImg] = ChooseImage(trialImages,shownImages, trialSegment, intensities)
    
% Initialize a matrx to compute overlap scores
chosenIDs = []; % store selected segments

% Retrieve shown foils and add them to the array to not use them
chosenIDs = cat(1,chosenIDs,unique(shownImages));

% Get number of images to generate random number
numPrevSegments = length(trialImages);

loopArray = [];
% Continue looking for an image that has a suitable control
% condition for the presented leaf
iterNo = 0;
while ~any(loopArray(:) == -1)            
    iterNo = iterNo + 1;
    fprintf('Finding a leaf condition, attempt %d \n', iterNo);
    
    % Randomly choose one image from the given segments
    chosenImg = randi(numPrevSegments);
    while any(chosenIDs(:) == chosenImg)
        chosenImg = randi(numPrevSegments);
        fprintf('Image Found with No %d \n', chosenImg);
    end
    
    chosenIDs(length(chosenIDs) + 1) = chosenImg; % add chosen Id to the list to not choose it again.
    selectedImage = trialImages{chosenImg};
    
    % Check if cutNo exists.
    if any([selectedImage.cutNo] == trialSegment)                              
       candidSegs = selectedImage([selectedImage.cutNo] == trialSegment);   
       loopArray = candidSegs.ncut;
       segments = selectedImage;
       fprintf('Cut no exists \n');

    else
        continue
    end
end


posDots = segments(1).pos;
intensityDots = segments(1).intensity;
intensityDots = reshape(intensityDots,10,10);                
intensityMap = [[1:6]', intensities];    


shownImages(length(shownImages) + 1) = chosenImg;

end

