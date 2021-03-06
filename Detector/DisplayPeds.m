function [finalBoxes] = DisplayPeds(cnn, frame, scales)

frameNumber = frame;
boxH = 150;
boxW = 80;

boxH = 52;
boxW = 32;

movie = VideoReader('TownCentreXVID.avi');
frame = read(movie, frameNumber);
colorFrame = frame;
frame = rgb2gray(frame);

framesMap = containers.Map;

%get all the frames from the image...
scales = [0.33 0.5];
for h = 1 : length(scales)
    scaledFrame = imresize(frame, scales(h));
    for i = 1 : 10 :(size(scaledFrame, 1) - boxH)
        for j = 1 : 10 :(size(scaledFrame , 2)-boxW)
            image = scaledFrame(i:i+boxH-1, j:j+boxW-1);
            image = double(image)/255;
            %image = imresize(image, [52 32]);
            framesMap([num2str(scales(h)) ':' num2str(i) ':' num2str(j)]) = image;
        end
    end
end

testImages = ConvertFromCellArray(framesMap.values);

%testImages = imresize(testImages, [52 32]);

% zcaPeople = reshape(testImages, boxH*boxW, length(testImages));
% whitenPeople = zcaWhiten(zcaPeople);
% whitenPeople = reshape(whitenPeople, boxH,boxW,length(testImages));

zcaPeople = reshape(testImages, 52*32, length(testImages));

% for i = 1:length(zcaPeople)
%     %whitenPeople(i) = zcaWhiten(zcaPeople(i,:));
%     whitenPeople(i,:) = 10;
% end

whitenPeople = zcaWhiten(zcaPeople);
whitenPeople = reshape(whitenPeople, 52,32,length(testImages));

keys = framesMap.keys();

% keys = keys(1:5:end);
% whitenPeople = whitenPeople(:,:,1:5:end);

net = cnnff(cnn, whitenPeople);

estimate = find(net.o(2,:) > 0.95);

% figure;
% imshow(colorFrame);
% axis on;
% hold on;
% 
% for es = 1 : length(keys)
%     xy = strsplit(keys{es}, ':');
%     x = str2double(xy{2});
%     y = str2double(xy{3});
%    plot(y,x,'r');
%     
% end

boxes = [];
colorcode=['y';'c';'b'];
for es = 1 : length(estimate)
    xy = strsplit(keys{estimate(es)}, ':');
    scale = str2double(xy{1});
    x = str2double(xy{2});
    y = str2double(xy{3});
    
    %//multiply / divide by the scale (xy{1}) for x, y, and boxW, boxH
  % h=rectangle('Position', [y, x,boxW, boxH], 'Tag' , 'hello');
   boxes = vertcat(boxes, [x,y,x+boxW,y+boxH]/scale);
   
   if net.o(2,estimate(es))>0.99
       col=colorcode(3);
   elseif net.o(2,estimate(es))>0.95
       col=colorcode(2);
   else
       col=colorcode(1);
   end
%   set(h,'EdgeColor',col)
    
end

%boxes = [];
for es = 1 : length(net.o(2,:))
    xy = strsplit(keys{es}, ':');
    x = str2double(xy{2});
    y = str2double(xy{3});
    x2 = ceil(x/15); % this is the dimenson of the box
    y2 = ceil(y/15);
    map(y2,x2)=net.o(2,es);
%    boxes = vertcat(boxes, [x,y,x2,y2]);
    
 %rectangle('Position', [y, x,boxW, boxH], 'Tag' , 'hello');
end

hold off;

%surf(map);


finalBoxes = nms(boxes, 0.5);
%finalBoxes = boxes;
% 
figure;
imshow(colorFrame);
hold on;
for es = 1 : length(finalBoxes)
    y = finalBoxes(es, 1); 
    x = finalBoxes(es, 2); 
    y2 = finalBoxes(es, 3);
    x2 = finalBoxes(es, 4); 
    h=rectangle('Position', [x, y, y2-y, x2 - x], 'Tag' , 'hello');
    set(h,'EdgeColor','r')
end

finalBoxes2 = maxBoxVals(finalBoxes);
backup = finalBoxes2
finalBoxes2(:,[1,2])=finalBoxes2(:,[2,1]);%have to flip columns here, not sure why

figure
imshow(colorFrame)
for es = 1 : length(finalBoxes2)
    y = finalBoxes2(es, 1); 
    x = finalBoxes2(es, 2); 
    y2 = finalBoxes2(es, 3);
    x2 = finalBoxes2(es, 4); 
    %h=rectangle('Position', finalBoxes2(es,:), 'Tag' , 'hello');
    h=rectangle('Position', [x, y, y2, x2], 'Tag' , 'hello');
    set(h,'EdgeColor','g')
end

hold off;
% 
% saveas(gcf,strcat('OutputVideoBoxCom/frame', num2str(frameNumber)),'png'); 
% close all;
 
% img = read(movie,[3000 4500]);
% for ii = 1:1501
%     imwrite(img(:,:,:,ii),sprintf('OutputImages/img%d.png',ii));
% end

end


