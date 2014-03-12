function [] = DisplayPeds( cnn, frameNumber, boxH, boxW)

frameNumber = 10;
boxH = 52;
boxW = 32;

movie = VideoReader('TownCentreXVID.avi');
frame = read(movie, frameNumber);
 frame = rgb2gray(frame);
 
 framesMap = containers.Map;

%get all the frames from the image...
for i = 1 : 50 :(size(frame, 1) - boxH)
    for j = 1 : 50 :(size(frame, 2)-boxW)
        image = frame(i:i+boxH-1, j:j+boxW-1);
        image = double(image)/255;
        
        %zcaNonPeople = reshape(image, boxH*boxW, 1);
        %whitenNonPeople = zcaWhiten(zcaNonPeople);
        %image = reshape(whitenNonPeople, boxH,boxW,1);
        
        framesMap([num2str(i) ':' num2str(j)]) = image;
    end
end

testImages = ConvertFromCellArray(framesMap.values);

net = cnnff(cnn, testImages);








end

