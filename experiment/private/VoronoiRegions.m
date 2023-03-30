function [intensityMap, intensityDots] = VoronoiRegions(numDots, posDots, numIntensities, intensities, gradientTest, thrExp)


% Your matrix
numRows = length(posDots);
numGroups = numIntensities; % The number of groups

%% Voronoi Diagram
cx = [2,5,8,2,5,8];
cy = [3.5,3.5,3.5,7.5,7.5,7.5];

if thrExp == 0
    stdx = randn(1,numGroups);
    stdy = randn(1,numGroups);
elseif thrExp == 1
    stdx = 0;
    stdy = 0;
end

cx = cx + stdx;
cy = cy + stdy;

groupIndex = NaN(1,length(posDots));

for i=1:length(posDots)
    x = posDots(i,1);
    y = posDots(i,2);

    minD = 100; % minimal distanced center
    c = 1; % center

    for k=1:numGroups
        if (x - cx(k))^2 + (y - cy(k))^2 <=minD
            minD = (x - cx(k))^2 + (y - cy(k))^2;
            c = k;
        end
    end

    groupIndex(i) = c;
end

% Assign dots into the groups
clusters = cell(numGroups,1);
for i=1:numGroups
    clusters{i} = posDots(groupIndex == i,:); 
end


% Initialize the matrix
intensityDots = zeros(numDots, numDots);

% Randomize the order of the intensities
intensityKeys = randperm(length(intensities));
randIntensities = intensities(randperm(length(intensities)));
% Match each hexagon in one Voronoi with the randomized intensities
for j=1:numGroups
    cluster = clusters{j};
    lenCluster = size(cluster,1);    
    for k=1:lenCluster
        intensityDots(cluster(k,1), cluster(k,2)) = randIntensities(j);
    end    
end

% Create mapping
intensityMap = nan(numIntensities,2);
intensityMap(:,1) = 1:length(intensities);
intensityMap(:,2) = intensities;


%% Gradient Test

if gradientTest == true
    intensities = linspace(50,255-50,numDots);
    for i=1:numDots
        intensityDots(i,:) = intensities(i) * ones(numDots,1);
    end
end

end