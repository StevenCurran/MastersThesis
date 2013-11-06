function [labelVec] = createLabelVector(vectors, labels)
%CREATELABELVECTOR Summary of this function goes here
%   Takes 2 vectors as inputs and creates a 1D vector to output the
%   relevent labels based on the size of the vectors that has been fed to
%   the function.
labelVec = []
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
            labelVector = [0 1]
        case '8'
            labelVector = [1 0]
    end
end