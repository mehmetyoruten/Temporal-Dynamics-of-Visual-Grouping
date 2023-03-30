load practiceSegmentsLevel.mat;
numIntensities = 6;

    
% Store ids of failed imgs
failedImgs = zeros(length(practiceSegments),1);
failedImgs2 = zeros(length(practiceSegments),1);
for imgId=1:length(practiceSegments)
    allSegs = practiceSegments{imgId};
    intensityDots = allSegs(1).intensity;
    imgPos = allSegs(1).pos;    
    
    % get all the segments found by norm min cut
    allSegsSize = length(allSegs);
    segmentsId = 1:allSegsSize;
    leafId = segmentsId([allSegs.ncut] == -1);
    
    % Check if the number of leaf nodes are equal to number of ground truth
    % segments
    if allSegsSize == 11
        fprintf('Number of segments found matched for img %d! \n', imgId); 
        
        % Store real positions of the target segment
        realPos = cell(numIntensities,1);
        
        for i=1:numIntensities
            posFilter = intensityDots == i;
            realPos{i} = imgPos(posFilter,:);
        end
    
        % Store found positions of the segments
        foundPos = cell(numIntensities,1);
        
        for i=1:numIntensities
            % Find which intensity it found
            allIntVal = [allSegs(leafId(i)).intensity];
            intVal = allIntVal(1);
            foundPos{intVal} = allSegs(leafId(i)).pos;
        end

        % Compare the position in these cells
        for i=1:numIntensities
            compMatrix= realPos{i} == foundPos{i};
            if (size(compMatrix,1) == sum(compMatrix(:,1))) && ...
                    (size(compMatrix,1) == sum(compMatrix(:,2)))
                fprintf('Positions match for img %d! \n', imgId);
            else
                fprintf('Positions did not match for img %d! \n', imgId);
                failedImgs2(imgId) = imgId;
            end
        end
    else
        fprintf('Number of segments found did not match for img %d! \n', imgId);
        failedImgs(imgId) = imgId;
    end  

end
failedImgs = failedImgs(failedImgs ~= 0);
failedImgs2 = failedImgs2(failedImgs2 ~= 0);

