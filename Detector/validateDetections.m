function [mota,motp,precision,recall] = validateDetections( frameNumber, detectorOutput, width, height )


% frame trackNumber boundingBoxPosition_y boundingBoxPosition_x boundingBoxWidth boundingBoxHeight
decOut = [];
for i = 1 : length(detectorOutput)
    y = detectorOutput(i, 1); 
    x = detectorOutput(i, 2); 
    decOut = vertcat(decOut, [frameNumber 0 y x width height]);
end



produceVideo = false;
videoFilename = 'TownCentreXVID.avi';

groundTruthFile = 'TownCentreGTHalfRes.csv';
verbose = true;    
isOxford = false; 


[mota,motp,precision,recall] = measureMOTAOxford(groundTruthFile,decOut,verbose,isOxford,produceVideo,videoFilename);

end

