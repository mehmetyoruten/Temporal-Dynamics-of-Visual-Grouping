function [posDots, intensityMap, intensityDots] = updateIntensity(minIntensity,numIntensities, numDots, contrast, gradientTest, thrExp)

%   UPDATE INTENSITY. Compute new intensity values for the stimulus relative to the background.
%                     This function is used for threshold experiment.
%
%     Parameters
%     ------------
%     numDots   (int)       : Number of nodes in one row/column.
%     gray      (float)     : Intensity value of the gray level.
%     contrast  (float)     : Contrast level that you obtain. Multiply it
%                             with the gray level to find current
%                             intensity.
%
%     Returns
%     -------------
%     posDots        (N x N array )  : Coordinates of the nodes.
%     intensityDots  (N x 1 array )  : Array of intensity values for the
%                                      nodes.


% Compute new intensities using the contrast as delta
intensities = CreateIntensities(minIntensity,numIntensities, contrast);

% Create grid using these intensity values
[posDots, intensityMap, intensityDots] = GenerateGrid(numDots, numIntensities, intensities, gradientTest, thrExp);


return

