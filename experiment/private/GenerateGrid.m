function [posDots, intensityMap, intensityDots] = GenerateGrid(numDots, numIntensities, intensities, gradientTest, thrExp)
    
% Compute relative dot positions (e.g. (1,1), (1,2), (1,3))
posDots = zeros(numDots, numDots, 2);

for x=1:numDots
    for y = 1:numDots
        posDots(x,y, :) = [x y];
    end
end
posDots = reshape(posDots, [numDots^2,2]);



% Form different instensity groups to Voronoi regions
[intensityMap, intensityDots] = VoronoiRegions(numDots, posDots, numIntensities, intensities, gradientTest, thrExp);

% Transform intensity values into keys
for i=1:length(intensityMap)
    intensityDots(intensityDots == intensityMap(i,2)) = intensityMap(i,1);
end

intensityDots = reshape(intensityDots, [numDots,numDots]);

end