function [W, D] = GenerateAdjacency(N, intensityDots, posDots, r, sigma_I, sigma_X)
%GENERATE ADJACENCY MATRIX. Generate W(ndots x ndots) matrix with the
%calculated weights using the intensity values. D(ndots x ndots) diagonal
%matrix.


% Normalize intensities between 0 and 1
normedIntensities = (intensityDots - min(intensityDots)) / (max(intensityDots) - min(intensityDots));



D = zeros(N);
W = zeros(N);

for i=1:N
    for j=i:N

        F_i = normedIntensities(i);
        F_j = normedIntensities(j);

        X_i = posDots(i, :);
        X_j = posDots(j, :);
    
        spatial_proximity = (X_i(1) - X_j(1))^2 + (X_i(2) - X_j(2))^2;
        distance = sqrt(spatial_proximity);
        spatial_proximity = sqrt(spatial_proximity);
        
        % Check if the target dot is in the range
        if distance < r
            feature_similarity = abs(F_i - F_j);

            weight = exp(-(feature_similarity/sigma_I)-(spatial_proximity/sigma_X));              
            W(i, j) = weight;
            W(j, i) = weight;
        end
    
    end
    D(i,i) = sum(W(i,:));
end

