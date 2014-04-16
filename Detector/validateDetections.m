function [mota,motp,precision,recall] = validateDetections( frameNumber, detectorOutput)


% frame trackNumber boundingBoxPosition_y boundingBoxPosition_x boundingBoxWidth boundingBoxHeight
decOut = [];
for i = 1 : length(detectorOutput)
    y = detectorOutput(i, 1); 
    x = detectorOutput(i, 2); 
    y2 = detectorOutput(i, 3); 
    x2 = detectorOutput(i, 4); 
    decOut = vertcat(decOut, [frameNumber 0 x y x2 - x y2-y]);
end



produceVideo = false;
videoFilename = 'TownCentreXVID.avi';

groundTruthFile = 'TownCentreGTHalfRes.csv';
verbose = true;    
isOxford = false; 


[mota,motp,precision,recall] = measureMOTAOxford(groundTruthFile,decOut,verbose,isOxford,produceVideo,videoFilename);
[mota,motp,precision,recall]
end

