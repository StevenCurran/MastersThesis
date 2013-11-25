function [labelVec] = convertLabels(labelsVar)

labelVec = zeros(size(labelsVar,1),1);
for i=1 : size(labelsVar,1)
        [~,numericValue] = max(labelsVar(i,:));
        %labelVec = [labelVec ; numericValue-1];
        labelVec(i) = numericValue-1;
end

end