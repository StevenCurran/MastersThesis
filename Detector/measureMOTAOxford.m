 %Format of tracking file: frame-number tneasurerack-number image-position bounding-box-size
%Format of ground truth file:
%personNumber, frameNumber, headValid, bodyValid, headLeft, headTop, headRight, headBottom, bodyLeft, bodyTop, bodyRight, bodyBottom

function [mota,motp,precision,recall] = measureMOTAOxford(groundTruth,tracking,verbose)
       
    groundTruth = csvread('TownCentre-groundtruth.top');
    %tracking = csvread('../detections/Oxford Results/TownCentre-output-BenfoldReidCVPR2011.csv');
    %tracking = csvread('../detections/Oxford Results/TownCentre-output-BenfoldReidBMVC2009.csv');
    
    %tracking = csvread('../../tracker output/trackerOutputMulti_test_linking_1_march_14.csv');
    
%     strict settings
%     correctAspectRatio = false;
%     strictMatching = true;
%     matchingThreshold = 0.5;    

    verbose = false;

    %my usual settings
    correctAspectRatio = true;
    strictMatching = true;
    matchingThreshold = 0.5;
        
    topfile = false;
    
    %make sure the head is centred in the bounding box
    correctBBLocation = true;
    
    %correct for the mismatch betweeen the ground truth frame numbering and
    %our tracker's output numbering (set to 0 if using Oxford results).
    synchronisationDelay = 3;
    
    [mota,motp,precision,recall] = doThings(groundTruth,tracking,topfile,strictMatching,matchingThreshold,correctAspectRatio,correctBBLocation,synchronisationDelay,verbose)
    
    %     mota
    %     motp
    %     precision
    %     recall
    
end

function [mota,motp,precision,recall] = doThings(groundTruth,tracking,topfile,strictMatching,matchingThreshold,correctAspectRatio,correctBBLocation,syncDelay,verbose)

    %maskImg = imread('mask.png');
    %maskImg = sum(maskImg,3) > 0;

    %tracking = csvread('realResults.csv');    
    %tracking = csvread('../../tracker output/trackerOutputMulti_jan_test_debug_9.csv');
    %tracking = csvread('../tracker output/trackRecords_test_pretty.csv');
    %tracking = csvread('../tracker output/trackRecords.csv');
    %tracking = csvread('../tracker output/trackRecords_ml.csv');
    
    %tracking = csvread('../../tracker output/trackRecords_adv_11_debug_11.csv');
    %tracking = csvread('../../tracker output/trackerOutputMulti_test_adv11_debug_23.csv');
    
    %tracking = csvread('TownCentre-output-BenfoldReidCVPR2011.top');
    
%   groundTruth = csvread('TownCentre-groundtruth.top');
    %tracking = groundTruth;
    %groundTruth = tracking;
    
    if topfile == false
        min(tracking(:,1))
        max(tracking(:,1))
    else
        min(tracking(:,2))
        max(tracking(:,2))
    end
    
    %startFrame = 1;%min(tracking(:,1));
    %endFrame = 4500;%max(tracking(:,1));%4500;%4500;%min(startFrame + 1980,4500); %last frame of gt data - 4500
    
    startFrame = min(tracking(:,1));
    endFrame = max(tracking(:,1));
            
    %endFrame = max(tracking(:,1));
    nFrames = endFrame - startFrame;
    
    %strictMatching = false;
    
    totalDist = 0;
    totalMatches = 0;
    
    prevMapping = [];
    frameMapping = [];
    
    %Store the data from each time step into this array in the format
    %[numberOfObjects missedDetections falsePositives mismatchError]
    allResults = zeros(nFrames,6);    
            
    t = 1;
    for frame = startFrame:endFrame
        
        %put condiiton here
        currentFrameGT = groundTruth(find(groundTruth(:,2) == frame-syncDelay),:);
        
        
        if topfile == false
            currentFrameTF = tracking(find(tracking(:,1) == frame),:);
        else
            currentFrameTF = tracking(find(tracking(:,2) == frame),:);
            currentFrameTF(:,1:2) = fliplr(currentFrameTF(:,1:2));                        
        end
        
        %[currentFrameGT,currentFrameTF] = filterDets(currentFrameGT,currentFrameTF,maskImg);
        
        %img = drawGTFrame(currentFrameGT,currentFrameTF);
        %imagesc(img);
        
        %currentFrameTF = tracking(find(tracking(:,1) == frame),:);
        %currentFrameTF = currentFrameGT;
        %currentFrameTF(:,1:2) = fliplr(currentFrameTF(:,1:2));
        
        %img = drawGTFrame(currentFrameGT,currentFrameTF);
%         figure;
%         imagesc(img./max(img(:)));
                        
        [sMatrix,overlapMatrix] = similarityMatrix(currentFrameGT,currentFrameTF,strictMatching,matchingThreshold,correctAspectRatio,topfile,correctBBLocation);
        [matching,matchingOverlap] = greedyMatching(sMatrix,overlapMatrix);
        %This array holds the matches between ground truth and the observed
        %tracks in this frame. We can build this into a current mapping between 
        %the track numbers in the GT file and observed track numbers
        
        frameMapping = ones(size(currentFrameGT,1),3) * - 1;
        
        frameMapping(:,1) = currentFrameGT(:,1);        
        for i = 1:size(matching,2)                        
            if matching(i) > 0
                frameMapping(i,2) = currentFrameTF(matching(i),2);
                frameMapping(i,3) = matchingOverlap(i);
            end            
        end
                        
        mismatchError = 0;
        %count mismatch error - this is where the mapping from ground truth
        %to observed tracks changes between frames
        if frame > startFrame
                        
            for i = 1:size(frameMapping(:,1),1)                

                p = find(prevMapping(:,1) == frameMapping(i,1));
                
                if ~isempty(p)
                    
                    oldMatch = prevMapping(p,2);
                    newMatch = frameMapping(i,2);
                    try
                    if oldMatch ~= newMatch && oldMatch ~= -1 && newMatch ~= -1
                        mismatchError = mismatchError + 1;
                    end
                    catch e
                        asdf=1;
                    end
                    
                end
                                
            end
                        
        end
        prevMapping = frameMapping;
                        
        %false positives - where an observed track does not match to
        %anything in the ground truth
        %Check the frame mapping - FP means the observed track is not
        %associated with any of the ground truth tracks
        falsePositives = 0;
        for i = currentFrameTF(:,2)'            
            if isempty(find(frameMapping(:,2) == i))                
                falsePositives = falsePositives + 1;                
            end
        end
                                
        %missed detections
        missedDetections = sum(frameMapping(:,2) == -1);
                
        numberOfObjects = size(currentFrameGT,1);% size(frameMapping(:,1),1);
        
        if missedDetections == numberOfObjects
            asdf=1;
        end
        
        %sum the overlap of matched track-detections for calculating MOTP
        sumMatchedOverlap = 0;
        truePositives = 0;
        for i = currentFrameTF(:,2)'
            f = find(frameMapping(:,2) == i);
            if ~isempty(f)
                truePositives = truePositives + 1;
                sumMatchedOverlap = sumMatchedOverlap + frameMapping(f(1,1),3);
            end
        end
           
        allResults(t,:) = [numberOfObjects missedDetections falsePositives mismatchError sumMatchedOverlap truePositives];
        t = t + 1;

%         if rand() > 0.1
%             img = drawGTFrame(currentFrameGT,currentFrameTF);
%             imagesc(img);
%         end
        
        %Now do things with the mapping
        
        %true positives
        %false positives
        %missed detections
        %etc
        
    end
    
    %sum(allResults(:,2:4),1) ./ sum(allResults(:,1))
    %[sum(allResults(:,2:4),1) sum(allResults(:,1),1)]
    
    if verbose == true
        sum(allResults(:,2))
        sum(allResults(:,3))
        sum(allResults(:,4))
    end
    
    mota = 1 - (sum(sum(allResults(:,2:4),1)) / sum(allResults(:,1)));    
    %moda = 1 - (sum(sum(allResults(:,2:3),1)) / sum(allResults(:,1)));
    motp = sum(allResults(:,5)) / sum(allResults(:,6));
    
    %precision = truePos / (truePos + falsePos)
    %recall = truePos / (truePos + falseNeg)
    %precision && recall == confusing.    
    precision = sum(allResults(:,6)) / (sum(allResults(:,6)) + sum(allResults(:,3)));
    recall = sum(allResults(:,6)) / (sum(allResults(:,6)) + sum(allResults(:,2)));
        
    if verbose == true
        figure;
        plot(allResults(:,1),'color','cyan');
        hold on;
        plot(allResults(:,2),'color','red');   %missedDetections
        plot(allResults(:,3),'color','green'); %falsePositives
        plot(allResults(:,4),'color','blue');  %mismatchError
        hold off;
    end
    
end

%Use greedy matching to associate ground truth bounding boxes with
%detections.
function [mapping,overlapMapping] = greedyMatching(sMatrix,overlapMatrix)

    mapping = zeros(1,size(sMatrix,1));
    overlapMapping = zeros(1,size(sMatrix,1));

    while(sum(sMatrix(:)) > 0)
       
        [v,p] = max(sMatrix(:));
        [g,t] = ind2sub(size(sMatrix),p);
        
        mapping(g) = t;
        overlapMapping(g) = overlapMatrix(g,t);
        
        sMatrix(:,t) = 0;
        sMatrix(g,:) = 0;
        
    end    

end

%Similarity matrix computed between the positions of all ground truth
%records and tracks. The similarity is the euclidean distance between their
%top right corners, if there is at least a 50% overlap
function [simMatrix,overlapMatrix] = similarityMatrix(currentFrameGT,currentFrameTF,strict,thresh,correctAspectRatio,topfile,correctBBLocations)

    nGround = size(currentFrameGT,1);
    nTracks = size(currentFrameTF,1);
    
    simMatrix = zeros(nGround,nTracks);
    overlapMatrix = zeros(nGround,nTracks);
    
    for i = 1:nGround
        
        [gtrackNumber,gpos,gw,gh] = parseGroundTruth(currentFrameGT(i,:),correctBBLocations);
        
        for j = 1:nTracks
            
            if topfile == false
                [ttrackNumber,tpos,tw,th] = parseTracking(currentFrameTF(j,:));
            else
                [ttrackNumber,tpos,tw,th] = parseGroundTruth(currentFrameTF(j,:),correctBBLocations);
            end
            
%             if strict == true
                %This is the way the oxford paper is evaluated - however it is a bit unfair as objects can be tracked
                %but are not marked as such unless they are rel. similar in size to the
                %ground truth.
                
%                 %correct the aspect ratios to 0.5
%                 if (gw + gpos(2)) > 500
%                     thresh = 0;
%                 else
%                     thresh = 0.5;
%                 end
                
                if correctAspectRatio == true
                    %correct the aspect ratio
                    cntr = gpos + floor([gw,gh]/2);
                    gh = floor(gw * 0.5);
                    gpos = cntr - [floor(gw/2),floor(gh/2)];

                    %correct the aspect ratio
                    cntr = tpos + floor([tw,th]/2);
                    th = floor(tw * 0.5);
                    tpos = cntr - [floor(tw/2),floor(th/2)];
                end
                
                overlap = rectint([gpos gw gh],[tpos tw th]);
                %overlap = overlap / min((tw*th),(gw * gh));
                union = (tw * th) + (gw * gh) - overlap;
                
                d = 0;
                if strict == true
                    d = overlap / union;
                else
                    %cover 50% of the ground truth
                    d = overlap / (gw * gh);
                end
                
                if d >= thresh %default >= 0.5
                    dist = (sqrt(sum((tpos - gpos).^2)) + 0.1);
                    simMatrix(i,j) = 1 / dist;
                    overlapMatrix(i,j) = overlap / union;
                end
                
%             else
%                 
%                 %slighly more fair given the bounding boxes produced by poselets, I think! 
%                 %Count the overlap as match if we overlap the GT by more than 50%
%                 overlap = rectint([gpos gw gh],[tpos tw th]);
%                 d = overlap / (gw * gh);
%                 
%                 if d > 0
%                     simMatrix(i,j) = 1 / sqrt(sum((tpos - gpos).^2));
%                 end
%                 
%             end

        end
    end

end

%take row from the ground truth file and parse out the info
function [trackNumber,pos,w,h] = parseGroundTruth(record,correctBBLocations)

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

%take a row from the tracking file and parse out the info
function [trackNumber,pos,w,h] = parseTracking(record)

    record = round(record);
    
    trackNumber = record(2);
    pos = record(3:4);
    w = record(5);
    h = record(6);

end

function img = drawGTFrame(frameGT,frameTR)

    img = zeros(1080/2,1920/2,3);    
        
    for i = 1:size(frameGT,1)
    
        [trackNumber,pos,w,h] = parseGroundTruth(frameGT(i,:));
        
        %correct the aspect ratio
        cntr = pos + floor([w,h]/2);
        h = w * 0.5;
        pos = cntr - [floor(w/2),floor(h/2)];
        
        img = drawRect2(img,pos,h,w,[0 1 0]);

        
%         htxtins = vision.TextInserter(int2str(trackNumber));
%         htxtins.Color = [0, 1, 0]; % [red, green, blue]
%         htxtins.FontSize = 12;
%         htxtins.Location = fliplr(pos); % [x y]
%         img = step(htxtins, img);
    
    end
    
    for i = 1:size(frameTR,1)
    
        [trackNumber,pos,w,h] = parseTracking(frameTR(i,:));
        %[trackNumber,pos,w,h] = parseGroundTruth(frameTR(i,:));
        
        %correct the aspect ratio
        cntr = pos + floor([w,h]/2);
        h = w * 0.5;
        pos = cntr - [floor(w/2),floor(h/2)];
        
        img = drawRect2(img,pos,h,w,[0 1 1]);        
                
%         htxtins = vision.TextInserter(int2str(trackNumber));
%         htxtins.Color = [0, 1, 1]; % [red, green, blue]
%         htxtins.FontSize = 12;
%         htxtins.Location = fliplr(pos) + [0 20]; % [x y]
%         img = step(htxtins, img);
        
    end
    
end

function img = drawRect2(img,position,width,height,color)

    hshapeins = vision.ShapeInserter('Shape','Rectangles','BorderColor','Custom','CustomBorderColor',color);
    pts = uint16([(position(2)) (position(1)) width height]);
    img = step(hshapeins, img, pts);
   
end

function [currentFrameGT,currentFrameTF] = filterDets(frameGT,frameTR,maskImg)

    img = maskImg;%zeros(1080/2,1920/2,3);  
    
    frameGTKeep = zeros(1,size(frameGT,1));        
    for i = 1:size(frameGT,1)
    
        [trackNumber,pos,h,w] = parseGroundTruth(frameGT(i,:));
        
        feetPos = round([pos(1) + h,pos(2) + (w/2)]);
        if feetPos(1) > 1 && feetPos(1) < size(img,1) && ...
                feetPos(2) > 1 && feetPos(2) < size(img,2)
            if maskImg(feetPos(1),feetPos(2)) == 1
                %keep
                frameGTKeep(i) = 1;
            else
                asdf=1;
            end
        else
            frameGTKeep(i) = 1;            
        end
        %img = drawRect2(img,pos,w,h,[0 1 0]);
    end
    
    frameTRKeep = zeros(1,size(frameTR,1)); 
    for i = 1:size(frameTR,1)
    
        [trackNumber,pos,w,h] = parseTracking(frameTR(i,:));
        %[trackNumber,pos,w,h] = parseGroundTruth(frameTR(i,:));
        feetPos = round([pos(1) + h,pos(2) + (w/2)]);
        if feetPos(1) > 1 && feetPos(1) < size(img,1) && ...
                feetPos(2) > 1 && feetPos(2) < size(img,2)
            if maskImg(feetPos(1),feetPos(2)) == 1
                %keep
                frameTRKeep(i) = 1;
            else
                asdf=1;
            end
        else
            frameTRKeep(i) = 1;
        end
        %img = drawRect2(img,pos,h,w,[0 1 1]);        
    end
    
    currentFrameGT = frameGT(find(frameGTKeep==1),:);
    currentFrameTF = frameTR(find(frameTRKeep==1),:);
    
end