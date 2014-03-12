function [] = DisplayPeds()

frameNumber = 10;
boxH = 150;
boxW = 80;

movie = VideoReader('TownCentreXVID.avi');
frame = read(movie, frameNumber);
colorFrame = frame;
frame = rgb2gray(frame);

framesMap = containers.Map;

%get all the frames from the image...
for h = 1 : 1
    scaledFrame = imresize(frame, h);
    for i = 1 : 15 :(size(scaledFrame, 1) - boxH)
        for j = 1 : 15 :(size(scaledFrame , 2)-boxW)
            image = scaledFrame(i:i+boxH-1, j:j+boxW-1);
            image = double(image)/255;
            framesMap([num2str(h) ':' num2str(i) ':' num2str(j)]) = image;
        end
    end
end

testImages = ConvertFromCellArray(framesMap.values);

zcaPeople = reshape(testImages, boxH*boxW, length(testImages));
whitenPeople = zcaWhiten(zcaPeople);
whitenPeople = reshape(whitenPeople, boxH,boxW,length(testImages));


keys = framesMap.keys();
xy = strsplit(keys{100}, ':')

smallerPeople = imresize(whitenPeople, [52 32]);

net = cnnff(cnn, whitenPeople);

estimate = find(net.o(2,:) > 0.95);

figure;
imshow(colorFrame);
hold on;

for es = 1 : length(estimate)
    xy = strsplit(keys{es}, ':')
    x = str2num(xy{2});
    y = str2num(xy{3});
    rectangle('Position', [x, y,boxW, boxH]);
    
end

hold off;





end

