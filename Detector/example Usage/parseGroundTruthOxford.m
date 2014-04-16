%take row from the ground truth file and parse out the info
function [trackNumber,pos,w,h] = parseGroundTruthOxford(record,correctBBLocations)

    trackNumber = record(1);
    
    if correctBBLocations == false
        % ORIGINAL
        pos = round(fliplr(record(9:10)) / 2);
        h = round((record(11) - record(9))/2);
        w = round((record(12) - record(10))/2);                
    else        
        % MOD - This code will re-centre the body bounding box

        %get the head position
        pos = round(fliplr(record(5:6)) / 2);
        h = round((record(7) - record(5))/2);
        w = round((record(8) - record(6))/2);

        %get the centre position of the head
        pos = pos + [h w] ./ 2;

        %get body width / height
        bh = round((record(11) - record(9))/2);
        bw = round((record(12) - record(10))/2);

        %move body position back by 1/2 body width
        pos = pos - [0 bh/2];

        h = bh;
        w = bw;
    end

end