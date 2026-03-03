function fdd_probs = extractFDDFeatures(I_MS)
% First-Digit Distribution from HCS angular components (Benford's Law).
[height, width, bands] = size(I_MS);
first_digits = [];
for b = 1:bands
    band_data = abs(I_MS(:,:,b)); band_data = band_data(band_data > 0 & isfinite(band_data));
    if ~isempty(band_data)
        digits = floor(band_data ./ 10 .^ floor(log10(band_data)));
        first_digits = [first_digits; digits(:)];
    end
end
if isempty(first_digits)
    fdd_probs = zeros(9, 1);
else
    digit_counts = histcounts(first_digits, 0.5:1:9.5, 'Normalization', 'probability');
    fdd_probs = digit_counts(1:9)';
end
end
