%take row from the ground truth file and parse out the info
function [trackNumber,pos,w,h] = parseGroundTruthPETS(record,correctBBLocations)

    trackNumber = record(2);

    pos = round((record(3:4)));
    w = round(record(5));
    h = round(record(6));

end