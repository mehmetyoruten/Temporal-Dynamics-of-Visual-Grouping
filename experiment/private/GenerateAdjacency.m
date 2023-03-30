function [W, D] = GenerateAdjacency(N, intensityDots, posDots, r, sigma_I, sigma_X)
%   GENERATE ADJACENCY MATRIX. Generate adjacency matrix (W) and degree matrix (D) with the
%   calculated weights using the intensity values. 
%
%     Parameters
%     ------------
%     N (int)                              : Groups from eigenvector
%     intensityDots (N x N array)          : Diagonal matrix with d_ii is total connection from node i to all the nodes --> assoc(A,V) or assoc(B,V)
%     posDots       (N x N array)          : Weight matrix of the graph that is evaluated.
%     r             (float)                : Distance between two nodes i
%                                            and j.
%     sigma_I       (float)                : Feature similarity factor.
%     sigma_X       (float)                : Spatial Proximity factor.
% 
%     Returns
%     -------------
%     W     (N x N array )         : Symmetrical adjacency matrix with
%                                   W(i,j) = w_ij
%
%     D     (N x N array )         : Degree matrix. Diagonal.

% Normalize intensities between 0 and 1
normedIntensities = intensityDots/255;

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

