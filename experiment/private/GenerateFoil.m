function [selectedImage, imgInt, posFoil, shownFoils, chosenFoilImg, selectedSegIdx] = GenerateFoil(segSet,segments, trialSegment, shownFoils, numDots, overlapThr, leafOnly)
%   GENERATE CONTROL SEGMENT. Generate foils for control condition.
%   Get a segment matching the target from the given set. Rotate 90/180/270 
%   degrees, and compute the overlap with the original segment. If the
%   overlap is below the threshold, keep it. Otherwise, find another
%   segment.
%   
%
%     Parameters
%     ------------
%     segSet        (1 x k cell)      : Stored images to choose leaf from.
%     segments      (struct)          : All partitions of the selected
%                                       image
%     trialSegment  (int)             : Target cut no.
%     numDots       (int)             : Number of nodes in the one row/column of
%                                       the image.
%     overlapThr    (float)           : Threshold setting. If the overlap
%                                       ratio is below, function will continue 
%                                       the search.
%     leafOnly      (logical)         : Specify your search. Leaf or
%                                       non-leaf.
% 
%     Returns
%     -------------
%     selectedImage (struct)          : A struct with all the
%                                       partitionings. Store the image that 
%                                       the foil belongs to.
%     posFoil       (n x 2 array )    : Position array of the nodes of the
%                                       generated foil.

% Shift size
shiftSize = numDots + 1;

% Initialize the overlap Variable
minOverlap = 1;

% Initialize a matrx to compute overlap scores
chosenIDs = []; % store selected segments

% Retrieve shown foils and add them to the array to not use them
chosenIDs = cat(1,chosenIDs,unique(shownFoils));

% Initialize matrix for keeping the position of the foil
allPosFoils = cell(4,1);

% Get all the borders of the leaf segments from the current image
leafSegs = segments([segments.ncut] == -1);
borderImg = FindAllSegBorders(leafSegs,numDots);

% Save all the cross correlation results
crossCorrAll = cell(length(borderImg),4);

% Save overlap ratios for the each segment and rotations
overlapBorders = NaN(length(leafSegs),4);

% Get the number trials to generate random number 
numPrevSegments = length(segSet);
k = 0; % keep the track of number of iterations
val = 0;
% sizeCroCorr = numDots+numDots-1;
while  val ~= 1
    %% Choosing target image and segment from the pre-generated sets
    k = k + 1; 
    % Choose an image from the given set
    fprintf('Finding a control condition, %d \n', k);
    if leafOnly == false            
        % Randomly choose one image from the given segments
        choose = randi(numPrevSegments);
        while any(chosenIDs(:) == choose)
            choose = randi(numPrevSegments);
        end
        fprintf('Image No %d \n', choose);
        
        chosenIDs(length(chosenIDs) + 1) = choose; % add chosen Id to the list to not choose it again.
        selectedImage = segSet{choose};
        
        % Get the position array of the matched target
        if any([selectedImage.cutNo] == trialSegment)                              
            candidSegs = selectedImage([selectedImage.cutNo] == trialSegment);     
        else
            continue
        end
        choose = randi(length(candidSegs));
        pos = candidSegs(choose).pos;
               

    else
        iterNo = 0;
        % Initial array assignment for the while loop
        loopArray = [];
        % Continue looking for an image that has a suitable control
        % condition for the presented leaf
        while ~any(loopArray(:) == -1)            
            iterNo = iterNo + 1;
            fprintf('Finding a leaf condition, attempt %d \n', iterNo);
            
            % Randomly choose one image from the given segments
            choose = randi(numPrevSegments);
            while any(chosenIDs(:) == choose)
                choose = randi(numPrevSegments);
            end
            fprintf('Image No %d \n', choose);

            chosenIDs(length(chosenIDs) + 1) = choose; % add chosen Id to the list to not choose it again.

            selectedImage = segSet{choose};
            % Get the image intensity values
            imgInt = selectedImage(1).intensity;
            imgInt = reshape(imgInt, [10,10]);
            
            % Check if cutNo exists
            if any([selectedImage.cutNo] == trialSegment)                              
               candidSegs = selectedImage([selectedImage.cutNo] == trialSegment);   
               loopArray = [candidSegs.ncut];
               
               % Order all the cut segments ascending
               sortedSegs = [selectedImage.cutNo]; 
               [sortedNcuts, segIdx] = sort(sortedSegs(2:end)); % do not consider the initial grid as segment                        
               candidSegIdx = [(segIdx(sortedNcuts == trialSegment))];
               candidSegIdx = candidSegIdx + 1;

               candidSegsNcuts(1) = selectedImage(candidSegIdx(1)).ncut;
               candidSegsNcuts(2) = selectedImage(candidSegIdx(2)).ncut;
               
               foundSeg = find(candidSegsNcuts == -1,1);

            else
                continue
            end
        end
        
        selectedSegIdx = candidSegIdx(foundSeg);
        chosenSeg = selectedImage(selectedSegIdx);
        pos = chosenSeg.pos;
               
    end

    %% Rotate for 0, 90, 180, 270 degrees
    
    % Initialize array to store new positions
    posFoil = zeros(length(pos), 2);    
    
    % Rotate the chosen array and store the overlapping info
    rotations = [0, 90, 180, 270];

    % Initialize array to store logical values for threshold testing
    thrBelow = nan(length(borderImg),length(rotations));

    for rotationNo = 1:length(rotations)
        rotation = rotations(rotationNo);

        if rotation == 0
            % Counter clockwise 90
            posFoil = pos;
            
            % Get the binary borders and actual locations of the rotated segment
            [bordersFoil, borderSeg] = FindSegBorders(posFoil,numDots);   

        elseif rotation == 90
            % Counter clockwise 90
            posFoil(:,1) = abs(pos(:,2) - shiftSize);
            posFoil(:,2) = pos(:,1);
            
            % Get the binary borders and actual locations of the rotated segment
            [bordersFoil, borderSeg] = FindSegBorders(posFoil,numDots);   

        elseif rotation == 180
            % Counter clockwise 180
            posFoil(:,1) = abs(pos(:,1) - shiftSize);
            posFoil(:,2) = abs(pos(:,2) - shiftSize);
            
            % Get the binary borders and actual locations of the rotated segment
            [bordersFoil, borderSeg] = FindSegBorders(posFoil,numDots);   
        
        elseif rotation == 270
            % Counter clockwise 270
            posFoil(:,1) = abs(pos(:,2) - shiftSize);
            posFoil(:,2) = abs(pos(:,1) - shiftSize);
            
            % Get the binary borders and actual locations of the rotated segment
            [bordersFoil, borderSeg] = FindSegBorders(posFoil,numDots);   
        end        
                
        allPosFoils{rotationNo} = posFoil;


        %% Compute the cross correlation for each separate segment in the image
        % and for each rotation
        for segNo=1:length(borderImg)
            targetSeg = borderImg{rotationNo,1};
            targetLen = length(borderImg{rotationNo,2});

            crosCorr = xcorr2(targetSeg, bordersFoil);
            normedCC = crosCorr/targetLen;
            crossCorrAll{segNo,rotationNo} = crosCorr;
            
            sumThr = sum(normedCC < overlapThr, 'all');            
            thrBelow(segNo, rotationNo) = sumThr == length(crosCorr)^2;
            
            % Old style comparison scores
            compSegs = ismember(borderSeg, borderImg{segNo,2}, 'rows');
            compSegsRatio = sum(compSegs)/length(compSegs);
            overlapBorders(segNo,rotationNo) = compSegsRatio;
        end
        
        % Save overlap scores for each rotation
%         overlapScores(rotationNo) = sum(normedCC < overlapThr, 'all');
       
    end    
    
    % Find the rotation with minimum overlap
%     [val, idx] = max(overlapScores);      
    
    % Compute if all the segments in the image (6) are below threshold    
    if any(sum(thrBelow) == 6)
        [idx] = find(sum(thrBelow) == 6);

        if any(~(overlapBorders(:,idx) < overlapThr))
            continue
        end

        val = 1;
        
        fprintf('Segment %d degrees rotated. \n', rotations(idx))
        posFoil = allPosFoils{idx};

        % If it satisfies the conditions add chosen foil to the matrix to not
        % present it in other trials
        shownFoils(length(shownFoils) + 1) = choose;
        chosenFoilImg = choose;

    else
        val = 0;
    end


    if k > numPrevSegments
        fprintf('No control segment found. \n')
        return
    end

end

end

