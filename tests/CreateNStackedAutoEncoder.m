function [saeVec,activations] = CreateNStackedAutoEncoder(input, train_x)



sae = saesetup([input(1) input(2)]);
sae.ae{1}.activation_function = 'sigm';
sae.ae{1}.learningRate = 0.1;
sae.ae{1}.inputZeroMaskedFraction = 0.5;
opts.numepochs = 1;
opts.batchsize = 1;


sae = saetrain(sae, train_x, opts);

saeVec = [sae];

activations = getActivations(sae.ae{1}, train_x);

for i = 2 : length(input)-1
    sae2 = saesetup([input(i) input(i+1)]);
    sae2.ae{1}.activation_function = 'sigm';
    sae2.ae{1}.learningRate = 0.1;
    sae2.ae{1}.inputZeroMaskedFraction = 0.5;
    opts.numepochs = 1;
    opts.batchsize = 1;
    sae2 = saetrain(sae2, activations, opts);
    activations1 = getActivations(sae2.ae{1}, activations);
    activations = activations1;
    saeVec = [saeVec sae2]
    sae = sae2;
end





end

