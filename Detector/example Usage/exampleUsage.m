function exampleUsage()

% NOTES
%
% The ground-truth file should be in the format
% frame trackNumber boundingBoxPosition_x boundingBoxPosition_y boundingBoxWidth boundingBoxHeight
% 
% The test file should be in the format
% frame trackNumber boundingBoxPosition_y boundingBoxPosition_x boundingBoxWidth boundingBoxHeight
% 
% MORE NOTES
% The (x,y) positions are flipped for some obscure reason I can?t remember! You can easily correct this in the code.
% 
% Set trackNumber to zeros because you are not doing tracking.
%
% The supplied Oxford ground-truth file at half the actual resolution - because
% reasons... again easily fixed.
%
% This is real research code! It has been changed so many times it is a complete
% mess!
    
    produceVideo = false;
    videoFilename = '';

    %note we are reading this file here
    trackerOutput = csvread('networkFlowOutput_trackletLinking_maxIters_1_test.csv');
    
    %just pass the filename of the ground-truth file - note this is in
    %custom format
    groundTruthFile = 'TownCentreGTHalfRes.csv';
    
    verbose = false;    
    isOxford = false; %yes this should be false!
    
    [mota,motp,precision,recall] = measureMOTAOxford(groundTruthFile,trackerOutput,verbose,isOxford,produceVideo,videoFilename);
    [mota,motp,precision,recall] 

end