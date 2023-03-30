function [visanglex,visangley] = pix2ang(sizex, sizey, totdist,screenwidth, screenres)

visang_rad = 2 * atan(screenwidth/2/totdist);
visang_deg = visang_rad * (180/pi);

visang_perpix = visang_deg / screenres;

visanglex = sizex * visang_perpix;
visangley = sizey * visang_perpix;

end