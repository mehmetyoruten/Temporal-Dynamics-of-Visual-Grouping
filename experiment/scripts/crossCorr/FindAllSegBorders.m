function [binaryBorderImg] = FindAllSegBorders(leafSegs, numDots)
%   FINDSEGBORDERS Find the location of the border hexagons in the given
%   segment.
% 
%     Parameters
%     ------------
%     segments   (6 x 7 struct)    : Struct with all the information regarding the leaf
%                                    nodes
% 
%     Returns
%     -------------
%     borderHex  (k x 2 array )    : k is the number of bordering hexagons
%                                    in the given segment. Array including
%                                    only the positions of the borders.
%                                    

% Put ones for the border location
binaryBorderImg = zeros(numDots);

for j = 1:length(leafSegs)
    neighbors = zeros(1,4);
    borderHex = nan(numDots^2,2);
    
    % Assign target segment
    seg = leafSegs(j).pos;
    
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
            borderHex(i,:) = seg(i,:);
        end
    end

    borderHex = borderHex (~isnan(borderHex (:,1)),:);
    
    for i=1:length(borderHex)
        binaryBorderImg(borderHex(i,1), borderHex(i,2)) = 1;
    end
end

return
