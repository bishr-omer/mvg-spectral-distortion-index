function features = specfeature(image)
% Extracts 21D spectral features: 9D FDD (HCS Benford) + 12D CM (RGB+NIR).
image = double(image);
fdd_feats = extractFDDFeatures(image);  % Note: Simplified; add HCS if full impl.
moment_feats = extractColorMoments(image);
features = [fdd_feats(:)', moment_feats(:)'];
end
