function [activations] = getActivations(nn, x)
%GETACTIVATIONS return the activations of the output neurons from the network.
%   Detailed explanation goes here

    n = nn.n;
    m = size(x, 1);
    x = [ones(m,1) x]; %adding of the bias
    %nn.a{1} = x;
    val = n-1;
    activations = sigm(x * nn.W{val - 1}');
    
end

