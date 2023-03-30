function DrawHexagonBorders(window, hexXpos,hexYpos, hexEdge, x,y)

lineWidthPix = 2;
lineColor = [0,0,0];


linesMatrix = [0, (hexEdge/2)*sqrt(3), -hexEdge, -(hexEdge/2);
             (hexEdge/2)*sqrt(3), (hexEdge/2)*sqrt(3), -(hexEdge/2), (hexEdge/2);
             (hexEdge/2)*sqrt(3), 0, (hexEdge/2), (hexEdge);
             0, -(hexEdge/2)*sqrt(3), (hexEdge), (hexEdge/2);
             - (hexEdge/2)*sqrt(3), -(hexEdge/2)*sqrt(3), (hexEdge/2), -(hexEdge/2);
             - (hexEdge/2)*sqrt(3), 0, -(hexEdge/2), -hexEdge];

% Draw a hexagon
for i=1:6
    pointList = [linesMatrix(i,1:2); linesMatrix(i,3:4)];
    Screen('DrawLines', window, pointList, lineWidthPix, lineColor , [hexXpos(x) hexYpos(y)], 2); 
end

end