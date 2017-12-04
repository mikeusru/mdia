% [correction, nLine, Data] = PQC_readBuffer_intoFrame(device, correction, pixelTime, isize, lineID, flag);
%% function PQC_readBuffer_intoFrame
% This is a function to acquire image from PicoQuant card.
% Writen in C for the speed.
%% INPUT
% device: device ID
% correction: 1x2 array. It is necessary to feed correction parameters when device is
% continuously running. Should be set to [0, 0] when starting acquisition.
% pixelTime: in second. (like 1e-5 for 10 microseconds)
% isize: 1x3 array. Requested size of image (n_time, n_pixel, n_line)
% lineID: line clock channel. 
% flag: 1x2 array. 
%       flag(1): 1 for starting, 2 for stopping. 
%       flag(2): 1 for ttakeFLIM, 0 for NOT. 
%% CREDITS
%  Created 9/013/2016, by Ryohei Yasuda (Ryohei.Yasuda@mpfi.org)
%%%