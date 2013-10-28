%% Example Title
% Summary of example objective

%% Section 1 Title
% Description of first code block
a=1;

%% Section 2 Title
% Description of second code block
a=2;


min = 1
max = 503
image = IMAGES(:,:,1);
for i = 1:numpatches
    imageNumber = 1;
    if mod(1,100) == 0
        imageNumber = i;
        image = IMAGES(:,:,imageNumber);
    end
    sampleX = floor( min + (max-min).*rand(1,1))
    sampleY = sampleX + 7
    sample1 = image(sampleX:sampleY,sampleX:sampleY);
    newSample = reshape(sample1, 64,1);
    patches(:,i) = newSample;
end
size(patches)