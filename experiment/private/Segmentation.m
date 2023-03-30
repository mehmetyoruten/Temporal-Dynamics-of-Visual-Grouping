function [segA, intensA, segB, intensB] = Segmentation(v_partition, posDots, intensityDots)
%SEGMENTATION Create two segments using direction vector x (1 x n darray) with values -1 and 1.
%
%     Parameters
%     ------------
%     v_partition   (1 x n darray)          : Direction vector wih two
%     groups.
%
%     posDots       (n x 2 darray)          : Position of nodes from img.
%     intensityDots (N x N darray)          : Intensity of nodes from img.
% 
%     Returns
%     -------------
%     segA     (n x 2 array )         : Position matrix of segA.
%     intensA  (n x 2 array )         : Intensity matrix of segA.
%     segB     (n x 2 array )         : Position matrix of segB.
%     intensB  (n x 2 array )         : Intensity matrix of segB.

segA = posDots(v_partition > 0, :);
segB = posDots(v_partition < 0, :);

intensA = intensityDots(v_partition > 0, :);
intensB = intensityDots(v_partition < 0, :);

end

