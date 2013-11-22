function [activations] = getActivations(nn, x)
%GETACTIVATIONS return the activations of the output neurons from the network.
%   Detailed explanation goes here

    n = nn.n;
    m = size(x, 1);
    x = [ones(m,1) x]; %adding of the bias
    nn.a{1} = x;
    val = n-1;
    nn.a{val} = sigm(nn.a{val - 1} * nn.W{val - 1}');
    nn.a{val} = [ones(m,1) nn.a{val}];
    %nn.a{end} = [ones(m,1) nn.a{end}];  may not need this line
    nn.a{n} = sigm(nn.a{n - 1} * nn.W{n - 1}');
    activations = nn.a{n};

end

