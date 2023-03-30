function [pointList] = GetPointList(hexXpos,hexYpos, hexEdge, x,y)
%GETPOINTLIST Compute the corner positions of single hexagon

pointList = [hexXpos(x), hexYpos(y) - (hexEdge);
             hexXpos(x) + (hexEdge/2)*sqrt(3), hexYpos(y) - (hexEdge/2);
             hexXpos(x) + (hexEdge/2)*sqrt(3), hexYpos(y) + (hexEdge/2);
             hexXpos(x), hexYpos(y) + (hexEdge);
             hexXpos(x) - (hexEdge/2)*sqrt(3), hexYpos(y) + (hexEdge/2);
             hexXpos(x) - (hexEdge/2)*sqrt(3), hexYpos(y) - (hexEdge/2)];
end

