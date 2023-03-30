function [outputArg1,outputArg2] = ang2pix(inputArg1,inputArg2)
%ANG2PIX Summary of this function goes here
%   Detailed explanation goes here

visang_rad = 2 * atan(screenwidth/2/totdist);
visang_deg = visang_rad * (180/pi);
pix_pervisang = screenres / visang_deg;

size_x = round(visanglex * pix_pervisang);
size_y = round(visangley*pix_pervisang);
end

