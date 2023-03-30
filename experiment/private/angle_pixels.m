%% ************************************************************************ 
%*************** Function for converting visual angles into pixels ********
%**************************************************************************
% 
% Franklenin Sierra
% Department of Neuroscience
% Max Planck Institute for Empirical Aesthetics
%
% franklenin.sierra@protonmail.com
% https://www.aesthetics.mpg.de/en.html
%
% *************************************************************************
%
% This function calculates the visual angle subtendend by a single pixel on the screen.
%
% Inputs:
%   X = Resolution of the monitor X axis   in pixels
%   Y = Resolution of the monitor Y axis   in pixels
%   W = Width of the screen                in cm
%   H = Height of the screen               in cm
%   V = Viewing distance of the subject    in cm 
% 
% Outputs:
%   Pixels per degree
%   Degrees per pixel
%
% For a deep explanation on how to convert visual angles into pixels, check "Eye,
% Brain and Vision" (1995) by David Hubel. 
% W = 47.5
% H = 30
% X = 1920
% Y = 1200
% V = 120

function [pixels_per_degree, degrees_per_pixel] = angle_pixels(X, Y, W, H, V)

pixel = [W H]./[X Y];

degrees_per_pixel = (2*atan(pixel./(2*V))).*(180/pi);
pixels_per_degree = 1./degrees_per_pixel;

degrees_per_pixel = degrees_per_pixel(1); 
pixels_per_degree = pixels_per_degree(1);
