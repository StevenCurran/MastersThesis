function [ output_args ] = validateDetections( frameNumber, detectorOutput, width, height )


% frame trackNumber boundingBoxPosition_y boundingBoxPosition_x boundingBoxWidth boundingBoxHeight
decOut = [];
for i = 1 : length(detectorOutput)
    y = finalBoxes(es, 1); 
    x = finalBoxes(es, 2); 
    decOut = vertcat(decOut, [x y width height]);
    
end



produceVideo = false;
videoFilename = 'TownCentreXVID.avi';




end

