function [U2] = SolveEigen(W,D)
% Solve Eigen System  
% Solve the generalized eigen system for the eigenvectors with the smallest
% eigenvalues.  

D_half_inv = diag(sqrt(1./diag(D))); % Compute half inverse of D.
L = D - W;
A = D_half_inv * L * D_half_inv;
[V, W] = eig(A); % Generate eigenvector V and diagonal eigenvalue matrix W
W = diag(W); % get eigenvalues

[~, index] = sort(W); % Sort eigenvalues in ascending order and get their indexes
U2 = V(:,index(2)); % get the eigenvector corresponding to the second lowest eigenvalue


end

