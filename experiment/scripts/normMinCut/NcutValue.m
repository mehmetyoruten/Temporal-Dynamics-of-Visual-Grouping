function [Ncut] = NcutValue(W,D,v_partition)
%Computes the N cut value to decide if further bipartition is necessary.

%     Parameters
%     ------------
%     x (1-D ndarray)             : Groups from eigenvector
%     D (n x n ndrarray)          : Diagonal matrix with d_ii is total connection from node i to all the nodes --> assoc(A,V) or assoc(B,V)
%     W (n x n ndrarray)          : Weight matrix of the graph that is evaluated.
% 
%     Returns
%     -------------
%     N_cut_value (float)         : Computed N cut value


x = v_partition;
d = diag(D);
k = sum(d(x > 0)) / sum(d);
b = k/(1-k);
y = (1 + x) - b*(1-x);

Ncut = (y' * (D - W) * y) / ( y' * D * y );

end

