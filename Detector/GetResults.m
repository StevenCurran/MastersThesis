function [precision,recall] = GetResults(cnn, frameRange, nms)

decOut = [];
finalBoxes = [];
for k = 1:length(frameRange)
    frame = frameRange(k);
    disp(strcat('working', num2str(frame)));
    frameBoxes = DisplayPeds(cnn, frame, nms);
    disp(strcat('done', num2str(frame)));
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
save('3000_3500_results2.mat', 'precision', 'recall');
end