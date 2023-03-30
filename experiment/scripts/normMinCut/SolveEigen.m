function [U2] = SolveEigen(W,D)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

D_half_inv = diag(sqrt(1./diag(D)));
L = D - W;
A = D_half_inv * L * D_half_inv;
[V, W] = eig(A); % Generate eigenvector V and diagonal eigenvalue matrix W
W = diag(W); % get eigenvalues

[~, index] = sort(W); % Sort eigenvalues in ascending order and get their indexes
U2 = V(:,index(2)); % get the eigenvector corresponding to the second lowest eigenvalue

% [U,S] = eigs(D-W, D, 2, 'sm');

% [U,W] = eig(D-W);
% [~,idx] = sort(diag(W)); % sort the eigenvalues and obtain indices
% U2 = U(:, idx(2)); % get the minimum

% % Check if the vector is stable
% if CheckStability(U2)
%     % Find the optimum partition point and do bipartition
%     % v_partition = sign(U2);
%     v_partition = Vpartition(W,D,U2);
% else
%     v_partition = false;
% end
% 


end

