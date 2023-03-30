function [posDots, intensityDots] = GenerateGrid(numDots, numIntensities, intensities, gradientTest)
    
% Compute relative dot positions (e.g. (1,1), (1,2), (1,3))
posDots = zeros(numDots, numDots, 2);

for x=1:numDots
    for y = 1:numDots
        posDots(x,y, :) = [x y];
    end
end
posDots = reshape(posDots, [numDots^2,2]);


% Create an array with different intensities
intensityDots = zeros(numDots,numDots);


% for i=1:numDots
%     intensityDots(i,:) = intensities(i) * ones(numDots,1);
% end

[intensityDots] = GaussianRandomization(numDots, posDots, numIntensities, intensities, gradientTest);

end