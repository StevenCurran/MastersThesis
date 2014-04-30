function [precision,recall] = GetResults(cnn, frameRange)

decOut = [];
finalBoxes = [];
for k = 1:length(frameRange)
    frame = frameRange(k);
    frameBoxes = DisplayPeds(cnn, frame);
    
    % frame trackNumber boundingBoxPosition_y boundingBoxPosition_x boundingBoxWidth boundingBoxHeight

for i = 1 : length(frameBoxes)
    y = frameBoxes(i, 1); 
    x = frameBoxes(i, 2); 
    y2 = frameBoxes(i, 3); 
    x2 = frameBoxes(i, 4); 
    decOut = vertcat(decOut, [frame 0 x y x2 - x y2-y]);
end
    
end

[~,~,precision,recall] = validateDetections(decOut);
precision
recall
end