function features = extractColorMoments(image)
image = double(image(:,:,1:4));  % RGB + NIR
features = zeros(12, 1);
for i = 1:4
    channel = image(:,:,i(:));
    features((i-1)*3 + 1) = mean(channel(:));
    features((i-1)*3 + 2) = std(channel(:));
    features((i-1)*3 + 3) = skewness(channel(:));
end
end
