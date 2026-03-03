%% MVG-SDI Demo (Sensors 2026)
% Load sample NBU data (add your .mat/.tif)
MS = double(imread('ms_sample.tif'));  % HxWxB
Fused = double(imread('fused_sample.tif'));

quality = MVG_Spectral(MS, Fused);
fprintf('Spectral Distortion: %.4f (lower better)\n', quality);
