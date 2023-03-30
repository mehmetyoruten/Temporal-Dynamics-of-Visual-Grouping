function [segments, posDots, intensityDots, intensityMap] = PG_ChooseImg(trialImages, chosenImg, trialSegment, intensities)
    

% Continue looking for an image that has a suitable control
% condition for the presented leaf

selectedImage = trialImages{chosenImg};

% Check if cutNo exists.
if any([selectedImage.cutNo] == trialSegment)                              
   candidSegs = selectedImage([selectedImage.cutNo] == trialSegment);   
   segments = selectedImage;
   fprintf('Cut no exists \n');
else
   fprintf('Chosen image failed \n');
end


posDots = segments(1).pos;
intensityDots = segments(1).intensity;
intensityDots = reshape(intensityDots,10,10);                
intensityMap = [[1:6]', intensities];    

end

