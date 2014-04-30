function [mota,motp,precision,recall] = validateDetections(detectorOutput)

produceVideo = false;
videoFilename = 'TownCentreXVID.avi';

groundTruthFile = 'TownCentreGTHalfRes.csv';
verbose = true;    
isOxford = false; 


[mota,motp,precision,recall] = measureMOTAOxford(groundTruthFile,detectorOutput,verbose,isOxford,produceVideo,videoFilename);
[mota,motp,precision,recall]
end

