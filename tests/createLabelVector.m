function [labelVec] = createLabelVector(vectors, labels)
%CREATELABELVECTOR Summary of this function goes here
%   Takes 2 vectors as inputs and creates a 1D vector to output the
%   relevent labels based on the size of the vectors that has been fed to
%   the function.
labelVec = [];
for i=1 : numel(vectors)
    for j=1 : vectors(i)
        %labelVec = [labelVec labels(i)];
        labelVec = [labelVec ; genLabelVector(labels(i))];
    end
end

end



function [labelVector] = genLabelVector(label)
    switch(label)
        case '0'
            labelVector = [0]; % [0 1]
        case '1'
            labelVector = [1];
        case '2'
            labelVector = [2];
        case '3'
            labelVector = [3];
        case '4'
            labelVector = [4];
        case '5'
            labelVector = [5];
        case '6'
            labelVector = [6];            
        case '7'
            labelVector = [7];
        case '9'
            labelVector = [9];            
        case '8'
            labelVector = [8];
    end
end