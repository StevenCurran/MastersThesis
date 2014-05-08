%Format of tracking file: frame-number tneasurerack-number image-position bounding-box-size
%Format of ground truth file:
%personNumber, frameNumber, headValid, bodyValid, headLeft, headTop, headRight, headBottom, bodyLeft, bodyTop, bodyRight, bodyBottom

function [mota,motp,precision,recall,missedDets,falsePos] = measureMOTAOxfordOld(groundTruth,tracking,verbose,isOxford,produceVideo,videoFilename)

    if isOxford == true
        groundTruth = csvread('TownCentre-groundtruth.top');
    else
        groundTruth = csvread(groundTruth);
        %groundTruth = csvread('../ground truth/PETS/PETS2009-S2L1-cropped.csv');
        
        %groundTruth = csvread('../ground truth/PETS/PETS2009-S2L1_v2.csv'); %- use this for pets
        %frame trackno x y w h ?
        
        %groundTruth2 = csvread('../detections/TUD DETS/ground truth/PETS2009-S2L1.csv'); %- use this for pets
        %frame trackno x y h w
        
%         groundTruth = zeros(size(groundTruth2,1),size(groundTruth2,2)+1);
%         groundTruth(:,1) = groundTruth2(:,1);
%         groundTruth(:,2) = groundTruth2(:,2);
%         groundTruth(:,3) = groundTruth2(:,3) - groundTruth2(:,6)/2;
%         groundTruth(:,4) = groundTruth2(:,4) - groundTruth2(:,5)/2;
%         groundTruth(:,5) = groundTruth2(:,6);
%         groundTruth(:,6) = groundTruth2(:,5);
        
        
        %groundTruth = csvread('../ground truth/TUD/TUD-Stadtmitte2.csv');
        %groundTruth = csvread('../ground truth/TUD/TUD_stadtmitte_cropped.csv');
        
         groundTruth(:,3) =  groundTruth(:,3) * 2;
         groundTruth(:,4) =  groundTruth(:,4) * 2;
         groundTruth(:,5) =  groundTruth(:,5) * 2;
         groundTruth(:,6) =  groundTruth(:,6) * 2;
         
         %groundTruth = [10 1 100 100 80 150];
         %tracking = [10 1 100 100 150 80];
         
         tracking(:,[5,6])=tracking(:,[6,5]);
         
         
        
    end

    %tracking = csvread('example.csv');
    %tracking = csvread('../detections/Oxford Results/TownCentre-output-BenfoldReidCVPR2011.csv');
    %tracking = csvread('../detections/Oxford Results/TownCentre-output-BenfoldReidBMVC2009.csv');
    %tracking = csvread('../../tracker output/trackerOutputMulti_test_linking_1_march_14.csv');

    %     strict settings
    %     correctAspectRatio = false;
    %     strictMatching = true;
    %     matchingThreshold = 0.5;

    %verbose = true;
    
    if isOxford == true

        %Oxford settings

        correctAspectRatio = true;
        strictMatching = true;
        matchingThreshold = 0.5;

        topfile = false;
        petsfile = false;

        %make sure the head is centred in the bounding box
        correctBBLocation = true;

        %correct for the mismatch betweeen the ground truth frame numbering and
        %our tracker's output numbering (set to 0 if using official Oxford results).
        %this is a total hack
        synchronisationDelay = 3;
        %synchronisationDelay = 0;

    else

        %PETS 2009 settings

        correctAspectRatio = false;
        strictMatching = true;
        matchingThreshold = 0.5;

        topfile = false;
        petsfile = true;

        %make sure the head is centred in the bounding box
        correctBBLocation = false;

        %correct for the mismatch betweeen the ground truth frame numbering and
        %our tracker's output numbering (set to 0 if using Oxford results).
        synchronisationDelay = 0; %seems to be best for PETS

    end
    %produceVideo = false;
    
    
%     %TUD settings    
%     correctAspectRatio = true;
%     strictMatching = true;
%     matchingThreshold = 0.5;    
%     topfile = false;
%     petsfile = true;    
%     %make sure the head is centred in the bounding box
%     correctBBLocation = false;
%     
%     %correct for the mismatch betweeen the ground truth frame numbering and
%     %our tracker's output numbering (set to 0 if using Oxford results).
%     synchronisationDelay = 0; %seems to be best for PETS
%     
%     produceVideo = true;

%      tracking = csvread('../tracker output/OxfordTest_refactor.csv');
%      results = [];
%      verbose = false;
%      produceVideo = false;
%     for synchronisationDelay = -10:10
        [mota,motp,precision,recall,missedDets,falsePos] = doThings(groundTruth,tracking,topfile,petsfile,strictMatching,matchingThreshold,correctAspectRatio,correctBBLocation,synchronisationDelay,verbose,produceVideo,videoFilename);
%         results = [results; synchronisationDelay mota motp precision recall];
%     end
    
    %     mota
    %     motp
    %     precision
    %     recall    
end

function [mota,motp,precision,recall,missedDets,falsePos] = doThings(groundTruth,tracking,topfile,petsfile,strictMatching,matchingThreshold,correctAspectRatio,correctBBLocation,syncDelay,verbose,produceVideo,videoFilename)

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
    
    if produceVideo
        outputVideo = VideoWriter([videoFilename]);
        outputVideo.FrameRate = floor(30);
        open(outputVideo);
    end
    
    startFrame = 0;
    endFrame = 0;
    if topfile == false
        min(tracking(:,1))
        max(tracking(:,1))
        startFrame = min(tracking(:,1));
        endFrame = max(tracking(:,1));
    else
        min(tracking(:,2))
        max(tracking(:,2))
        startFrame = min(tracking(:,2));
        endFrame = max(tracking(:,2));
    end
    
    %startFrame = 1;
    %endFrame = 794;
    
    %startFrame = 1;%min(tracking(:,1));
    %endFrame = 4500;%max(tracking(:,1));%4500;%4500;%min(startFrame + 1980,4500); %last frame of gt data - 4500
    
    %startFrame = min(tracking(:,1));
    %endFrame = max(tracking(:,1));
            
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
        
        if frame == 50
            sadf=1;
        end
        
        %put condiiton here
        if petsfile == false
            currentFrameGT = groundTruth(find(groundTruth(:,2) == frame-syncDelay),:);
        else
            currentFrameGT = groundTruth(find(groundTruth(:,1) == frame-syncDelay),:);
        end
        
        if topfile == false
            currentFrameTF = tracking(find(tracking(:,1) == frame),:);
        else
            currentFrameTF = tracking(find(tracking(:,2) == frame),:);
            currentFrameTF(:,1:2) = fliplr(currentFrameTF(:,1:2));                        
        end
        
        %remove ground-truth and 
        try
            ignoreBorders = false;
            if ignoreBorders
                
                imgSize = [768,576];
                %imgSize = [1920,1080] ./ 2;
                borderWidth = 50;
                
                toRemove = zeros(1,size(currentFrameGT,1));
                for v = 1:size(currentFrameGT,1)
                    
                    pos = currentFrameGT(v,3:4);
                    w = currentFrameGT(v,5);
                    h = currentFrameGT(v,6);
                    centrePos = pos + ([w,h]./2);
                    
                    if centrePos(1) > (imgSize(1) - borderWidth) || ...
                            centrePos(1) < (borderWidth) || ...
                            centrePos(2) > (imgSize(2) - borderWidth) || ...
                            centrePos(2) < (borderWidth) ...
                            toRemove(v) = 1;
                    end
                end
                currentFrameGT = currentFrameGT(find(toRemove == 0),:);
                
                toRemove = zeros(1,size(currentFrameTF,1));
                for v = 1:size(currentFrameTF,1)
                    
                    pos = fliplr(currentFrameTF(v,3:4));
                    h = currentFrameTF(v,5);
                    w = currentFrameTF(v,6);
                    centrePos = pos + ([w,h]./2);
                    
                    if centrePos(1) > (imgSize(1) - borderWidth) || ...
                            centrePos(1) < (borderWidth) || ...
                            centrePos(2) > (imgSize(2) - borderWidth) || ...
                            centrePos(2) < (borderWidth) ...
                            toRemove(v) = 1;
                    end
                end
                currentFrameTF = currentFrameTF(find(toRemove == 0),:);
                
            end
        catch e
            sdf=1;
        end
        
        if size(currentFrameTF,1) == 0
            sdf=1;
        end
        if size(currentFrameGT,1) == 0
            asd=1;
        end
        
        %[currentFrameGT,currentFrameTF] = filterDets(currentFrameGT,currentFrameTF,maskImg);
        
        %img = drawGTFrame(frame,currentFrameGT,currentFrameTF);
        %imagesc(img);
        %drawnow;
        
        %currentFrameTF = tracking(find(tracking(:,1) == frame),:);
        %currentFrameTF = currentFrameGT;
        %currentFrameTF(:,1:2) = fliplr(currentFrameTF(:,1:2));
        
%         img = drawGTFrame(currentFrameGT,currentFrameTF);
%         figure;
%         imagesc(img./max(img(:)));
                        
        [sMatrix,overlapMatrix] = similarityMatrix(currentFrameGT,currentFrameTF,strictMatching,matchingThreshold,correctAspectRatio,topfile,petsfile,correctBBLocation);
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
        falsePositivesMap = zeros(1,size(currentFrameTF,1));
        falsePositives = 0;
        c=1;
        for i = currentFrameTF(:,2)'            
            if isempty(find(frameMapping(:,2) == i))                
                falsePositives = falsePositives + 1; 
                falsePositivesMap(c) = 1;
            end
            c=c+1;
        end
                                
        %missed detections
        missedDetections = sum(frameMapping(:,2) == -1);
        missedDetectionsMap = frameMapping(:,2) == -1;
                
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

        if produceVideo == true
            %blue - missed detection
            %red - false positive
            %green - correctly associated ground-truth
            %white - correctly associated track            
            %img = zeros(600,1000,3);
            %img = zeros(576,768,3);
            img = zeros(1024/2,1980/2,3);
            img = drawGTFrame(img,currentFrameGT,missedDetectionsMap,correctBBLocation);
            img = drawTracksFrame(img,currentFrameTF,falsePositivesMap);
            
            %imagesc(img./255);
            %drawnow;
            
            writeVideo(outputVideo,img./max(255,max(img(:))));
        end
        
%         drawResults = true;
%         if drawResults
%             if frame == startFrame
%                 figure;
%             end
%             for g = 1:size(currentFrameGT,1)
%                [trackNumber,pos,w,h] = parseGroundTruthPETS(currentFrameGT(g,:),0);
%                if  missedDetectionsMap(g) == 1       
%                    scatter3(pos(1),pos(2),frame,10,[1 0 0]);
%                else
%                    scatter3(pos(1),pos(2),frame,10,[0 1 0]);
%                end
%                hold on;
%             end
%             for d = 1:size(currentFrameTF,1)
%                 [trackNumber,pos,w,h] = parseTracking(currentFrameTF(d,:));
%                 if falsePositivesMap(d) == 1
%                     scatter3(pos(1),pos(2),frame,10,[0 0 1]);
%                 else
%                     scatter3(pos(1),pos(2),frame,10,[0 0 0]);
%                 end
%                 hold on;
%             end
%        end
                
    end
    
    %sum(allResults(:,2:4),1) ./ sum(allResults(:,1))
    %[sum(allResults(:,2:4),1) sum(allResults(:,1),1)]
    
    %if verbose == true
        disp(['Missed Dets ' int2str(sum(allResults(:,2)))]);
        disp(['False Pos   ' int2str(sum(allResults(:,3)))]);
        disp(['Mismatch    ' int2str(sum(allResults(:,4)))]);
        %sum(allResults(:,2))
        %sum(allResults(:,3))
        %sum(allResults(:,4))
    %end
    
    missedDets = sum(allResults(:,2));
    falsePos = sum(allResults(:,3));
    
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
    
    if produceVideo
        close(outputVideo);
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
function [simMatrix,overlapMatrix] = similarityMatrix(currentFrameGT,currentFrameTF,strict,thresh,correctAspectRatio,topfile,petsfile,correctBBLocations)

    nGround = size(currentFrameGT,1);
    nTracks = size(currentFrameTF,1);
    
    simMatrix = zeros(nGround,nTracks);
    overlapMatrix = zeros(nGround,nTracks);
    
    for i = 1:nGround
        
        if petsfile == false
            [gtrackNumber,gpos,gw,gh] = parseGroundTruthOxford(currentFrameGT(i,:),correctBBLocations);
        else
            [gtrackNumber,gpos,gw,gh] = parseGroundTruthPETS(currentFrameGT(i,:),correctBBLocations);
        end
        
        for j = 1:nTracks
            
            if topfile == false
                [ttrackNumber,tpos,tw,th] = parseTracking(currentFrameTF(j,:));
            else
                [ttrackNumber,tpos,tw,th] = parseGroundTruthOxford(currentFrameTF(j,:),correctBBLocations);
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
                %overlap = rectint([fliplr(gpos) gh gw],[fliplr(tpos) th tw]);
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

%take a row from the tracking file and parse out the info
function [trackNumber,pos,w,h] = parseTracking(record)

    record = round(record);
    
    trackNumber = record(2);
    pos = record(3:4);
    w = record(5);
    h = record(6);

end

function img = drawGTFrame(img,frameGT,missedDetectionsMap,correctBBLocation)

    for i = 1:size(frameGT,1)

        [trackNumber,pos,w,h] = parseGroundTruthPETS(frameGT(i,:),correctBBLocation);%parseGroundTruthOxford(frameGT(i,:),correctBBLocation);

        c = [];
        if missedDetectionsMap(i) == 1
            c = [0 0 255];
        else
            c = [0 255 0];
        end

        img = drawRect2(img,pos,h,w,c);


        %         htxtins = vision.TextInserter(int2str(trackNumber));
        %         htxtins.Color = [0, 1, 0]; % [red, green, blue]
        %         htxtins.FontSize = 12;
        %         htxtins.Location = fliplr(pos); % [x y]
        %         img = step(htxtins, img);

    end
    
end

function img = drawTracksFrame(img,frameTR,falsePositivesMap)

    %img = zeros(1080/2,1920/2,3);
        
    for i = 1:size(frameTR,1)
        
        [trackNumber,pos,w,h] = parseTracking(frameTR(i,:));
        
        c = [];
        if falsePositivesMap(i) == 1
            c = [255 0 0];
        else
            c = [255 255 255];
        end
        
%         %correct the aspect ratio
%         cntr = pos + floor([w,h]/2);
%         h = w * 0.5;
%         pos = cntr - [floor(w/2),floor(h/2)];

        tmp = zeros(size(img,1),size(img,2),size(img,3));
        img = img + drawRect2(tmp,pos,h,w,c);
        
%         htxtins = vision.TextInserter(int2str(trackNumber));
%         htxtins.Color = [0, 255, 0]; % [red, green, blue]
%         htxtins.FontSize = 12;
%         htxtins.Location = fliplr(pos); % [x y]
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
    
        [trackNumber,pos,h,w] = parseGroundTruthOxford(frameGT(i,:));
        
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