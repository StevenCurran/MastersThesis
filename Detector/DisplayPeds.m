function [] = DisplayPeds(cnn)

frameNumber = 600;
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
    for i = 1 : 5 :(size(scaledFrame, 1) - boxH)
        for j = 1 : 5 :(size(scaledFrame , 2)-boxW)
            image = scaledFrame(i:i+boxH-1, j:j+boxW-1);
            image = double(image)/255;
            image = imresize(image, [52 32]);
            framesMap([num2str(h) ':' num2str(i) ':' num2str(j)]) = image;
        end
    end
end

testImages = ConvertFromCellArray(framesMap.values);

%testImages = imresize(testImages, [52 32]);

% zcaPeople = reshape(testImages, boxH*boxW, length(testImages));
% whitenPeople = zcaWhiten(zcaPeople);
% whitenPeople = reshape(whitenPeople, boxH,boxW,length(testImages));

zcaPeople = reshape(testImages, 52*32, length(testImages));
whitenPeople = zcaWhiten(zcaPeople);
whitenPeople = reshape(whitenPeople, 52,32,length(testImages));

keys = framesMap.keys();

keys = keys(1:5:end);
whitenPeople = whitenPeople(:,:,1:5:end);

net = cnnff(cnn, whitenPeople);

estimate = find(net.o(2,:) > 0.95);

figure;
imshow(colorFrame);
axis on;
hold on;

% for es = 1 : length(keys)
%     xy = strsplit(keys{es}, ':');
%     x = str2double(xy{2});
%     y = str2double(xy{3});
%    plot(y,x,'r');
%     
% end


for es = 1 : length(estimate)
    xy = strsplit(keys{estimate(es)}, ':');
    x = str2double(xy{2});
    y = str2double(xy{3});
   rectangle('Position', [y, x,boxW, boxH], 'Tag' , 'hello');
    
end

hold off;





end

