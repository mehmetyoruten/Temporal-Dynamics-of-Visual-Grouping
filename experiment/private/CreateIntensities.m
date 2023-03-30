function [intensities] = CreateIntensities(minIntensity, numIntensities, contrast)

%   CREATE INTENSITIES. Compute the set of intensities which will be used
%   in the experiment using the contrast value computed with the threshold
%   experiment.
%
%     Parameters
%     ------------
%     minIntensity   (float)    : Number of nodes in one row/column.
%     numIntensities (int)      : Intensity value of the gray level.
%     contrast       (float)    : Contrast level that you obtain. Multiply it
%                                 with the gray level to find current
%                                 intensity.
%
%     Returns
%     -------------
%     intensities    (1 x numIntensities array )  : Subject specific
%                                                   intensity values


intensities = zeros(numIntensities,1);
intensities(1) = minIntensity;

i = 1;
while i < 6
    i = i+1;
    intensities(i) = intensities(i-1) + (intensities(i-1)*contrast);
end

return