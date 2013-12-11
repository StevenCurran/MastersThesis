function [input] = GetFinalActivations(saeVec, test)


input = test;

for i = 1 : length(saeVec)
activs = getActivations(saeVec(i).ae{1}, input);
input = activs;

end

