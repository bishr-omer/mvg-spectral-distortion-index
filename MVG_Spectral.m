function quality = MVG_Spectral(MS, Fused)
% MVG_Spectral_Distortion: Assess spectral distortion using Multivariate Gaussian model.
% From: "A No-Reference Multivariate Gaussian-Based Spectral Distortion Index..." (Sensors 2026)
% Inputs: MS (HxWxB double), Fused (HxWxB double)
% Output: quality (lower = better spectral fidelity)

blocksizerow = 32; blocksizecol = 32; specfeatnum = 21;

feature_extractor_handle = @(block_struct) specfeature(block_struct.data);

% 1. Pristine model from MS
fprintf('Processing MS image...\n');
[MS_cropped, ~, ~] = croppatch(MS, blocksizerow, blocksizecol);
features_ms_raw = blockproc(MS_cropped, [blocksizerow blocksizecol], feature_extractor_handle);
features_ms = reshape(features_ms_raw, specfeatnum, [])';
mu_pristine = mean(features_ms); cov_pristine = cov(features_ms);

% 2. Test model from Fused
fprintf('Processing Fused image...\n');
[Fused_cropped, ~, ~] = croppatch(Fused, blocksizerow, blocksizecol);
features_fused_raw = blockproc(Fused_cropped, [blocksizerow blocksizecol], feature_extractor_handle);
features_fused = reshape(features_fused_raw, specfeatnum, [])';
mu_distorted = mean(features_fused); cov_distorted = cov(features_fused);

% 3. Symmetric Mahalanobis distance
fprintf('Computing score...\n');
pooled_cov = (cov_pristine + cov_distorted) / 2;
delta_mu = mu_pristine - mu_distorted;
quality = sqrt(delta_mu * pinv(pooled_cov) * delta_mu');
fprintf('MVG-SDI: %.4f\n', quality);
end

function [cropped_image, num_row_blocks, num_col_blocks] = croppatch(image, bs_row, bs_col)
[rows, cols, ~] = size(image);
num_row_blocks = floor(rows / bs_row); num_col_blocks = floor(cols / bs_col);
cropped_image = image(1:num_row_blocks*bs_row, 1:num_col_blocks*bs_col, :);
end
