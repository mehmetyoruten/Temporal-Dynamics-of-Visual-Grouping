function SaveImages(imagesSegs, trialLayout)
% Save the displayed images

hexagonFull = imagesSegs{1,1};
filenameGrid = sprintf('images/grid_init.png');
imwrite(hexagonFull,filenameGrid);

for trialNo=1:length(imagesSegs)
    segNo = trialLayout(trialNo,1);

    hexagonSeg = imagesSegs{trialNo,2};
    filenameSeg = sprintf('images/seg_%d_cut%d.png',trialNo,segNo);
    imwrite(hexagonSeg,filenameSeg);
end

end

