function labels = nnpredict(nn, x)
    nn.testing = 1;
    nn = nnff(nn, x, zeros(size(x,1), nn.size(end))); %this is the size of the testing vector and the output layer of the net
    nn.testing = 0;
    
    [~, i] = max(nn.a{end},[],2);
    labels = i;
end
