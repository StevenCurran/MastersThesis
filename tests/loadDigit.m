function [images,locations] = loadDigit(digit, fullImageList, imageLabels)
%LOADDIGIT return a vector of the digits from the test_x variable
    locations = find(imageLabels(:,digit+1)==1);
    images = zeros(size(locations),784);
    for i = 1:size(locations)
        images(i,:) = fullImageList(locations(i),:);
    end
    
end

