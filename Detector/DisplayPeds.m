function [] = DisplayPeds( cnn, frameNumber, boxH, boxW)

frameNumber = 10;
boxH = 52;
boxW = 32;

movie = VideoReader('TownCentreXVID.avi');
frame = read(movie, frameNumber);
frame = frame(:,:,1);

for i = 1 : 5 :size(frame, 1)
    for j = 1 : 5 :size(frame, 2)
        
    end
end



imshow(frame);




end

