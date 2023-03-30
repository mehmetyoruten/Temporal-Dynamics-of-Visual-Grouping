function [intensityDots] = GaussianRandomization(numDots, posDots, numIntensities, intensities, gradientTest)


% Your matrix
numRows = length(posDots);
numGroups = numIntensities; % The number of groups

%% Voronoi Diagram
cx = [2,5,8,2,5,8];
cy = [3,3,3,7,7,7];

stdx = normrnd(0,1,[1,numGroups]);
stdy = normrnd(0,1,[1,numGroups]);

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
for j=1:numGroups
    cluster = clusters{j};
    lenCluster = size(cluster,1);

    for k=1:lenCluster
        intensityDots(cluster(k,1), cluster(k,2)) = intensities(j);
    end
    
end


%% GMM segmentation
% mu = [3, 3; 6,7];
% % Concatanate covariances on third dimension
% sigma = cat(3,[.5 .5],[1 1]);
% % Create equal proportion mixture
% gm = gmdistribution(mu,sigma);
% % Generate random clusters with the provided means and sigmas
% [Y,compIdx] = random(gm,100);
% 
% % Find the range
% ranges = cell(numGroups,2);
% for i=1:numGroups
%     ranges{i,1} = min(Y(compIdx == i));
%     ranges{i,2} = max(Y(compIdx == i));
% end
% 
% gmFit = fitgmdist(posDots, 6);
% groupIndex = cluster(gmFit, posDots);

%% K-means Segmentation
% % Generate an index that assigns each dot into one of the groups
% [groupIndex, C] = kmeans(posDots,6);


% Assign dots into the groups
% clusters = cell(numGroups,1);
% for i=1:numGroups
%     clusters{i} = posDots(groupIndex == i,:); 
% end


% Initialize the matrix
% intensityDots = zeros(numDots, numDots);
% for j=1:numGroups
%     cluster = clusters{j};
%     lenCluster = length(cluster);
% 
%     for k=1:lenCluster
%         intensityDots(cluster(k,1), cluster(k,2)) = intensities(j);
%     end
%     
% end



%% Gradient Test

if gradientTest == true
    intensities = linspace(50,255-50,numDots);
    for i=1:numDots
        intensityDots(i,:) = intensities(i) * ones(numDots,1);
    end
end

end