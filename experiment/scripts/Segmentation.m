function [segA, intensA, segB, intensB] = Segmentation(v_partition, posDots, intensityDots)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

segA = posDots(v_partition > 0, :);
segB = posDots(v_partition < 0, :);

intensA = intensityDots(v_partition > 0, :);
intensB = intensityDots(v_partition < 0, :);

end

