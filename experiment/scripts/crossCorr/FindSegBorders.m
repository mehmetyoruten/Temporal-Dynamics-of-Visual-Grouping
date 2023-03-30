function [binaryBorderSeg] = FindSegBorders(seg, numDots)
%   FINDSEGBORDERS Find the location of the border hexagons in the given
%   segment.
% 
%     Parameters
%     ------------
%     seg        (n x 2 array)      : Position array of the segment.
% 
%     Returns
%     -------------
%     borderHex  (k x 2 array )    : k is the number of bordering hexagons
%                                    in the given segment. Array including
%                                    only the positions of the borders.
%                                    



neighbors = zeros(1,4);
borderSeg = nan(100,2);
for i=1:length(seg)
    targetRow = seg(i,1);
    targetCol = seg(i,2);    
    
    % Define the position of neighboring hexagons
    upNeigh = [targetRow + 1, targetCol];
    bottomNeigh = [targetRow - 1, targetCol];
    leftNeigh = [targetRow, targetCol - 1];
    rightNeigh = [targetRow, targetCol + 1];
    
    % Check if they exist in the same segment
    neighbors(1) = ismember(upNeigh,seg, 'rows');
    neighbors(2) = ismember(bottomNeigh,seg, 'rows');
    neighbors(3) = ismember(leftNeigh,seg, 'rows');
    neighbors(4) = ismember(rightNeigh,seg, 'rows');
    
    if sum(neighbors) < 4
        borderSeg(i,:) = seg(i,:);
    end
end

borderSeg = borderSeg (~isnan(borderSeg (:,1)),:);

% Put ones for the border location
binaryBorderSeg = zeros(numDots);
for i=1:length(borderSeg)
    binaryBorderSeg(borderSeg(i,1), borderSeg(i,2)) = 1;
end

return
