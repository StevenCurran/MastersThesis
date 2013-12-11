function [] = StackedEncoderTest()

 
load mnist_uint8;

 
train_x = double(train_x)/255;
test_x = double(test_x)/255;
train_y = double(train_y);
test_y = double(test_y);

 
rand('state',0)

 
sae = saesetup([784 200]);
sae.ae{1}.activation_function = 'sigm';
sae.ae{1}.learningRate = 0.1;
sae.ae{1}.inputZeroMaskedFraction = 0.5;
opts.numepochs = 1;
opts.batchsize = 1;

 
sae = saetrain(sae, train_x, opts);

 
activations = getActivations(sae.ae{1}, train_x);

 
sae2 = saesetup([200 100]);
sae2.ae{1}.activation_function = 'sigm';
sae2.ae{1}.learningRate = 0.1;
sae2.ae{1}.inputZeroMaskedFraction = 0.5;
opts.numepochs = 1;
opts.batchsize = 1;

 
disp('training network....');

 
sae2 = saetrain(sae2, activations, opts);

 
svmlabels = convertLabels(train_y);
 
activations1 = getActivations(sae2.ae{1}, activations);

 
SVMStruct = svmtrain(svmlabels,activations1,[]);

 
 
%test
activations2 = getActivations(sae.ae{1}, test_x);
activations3 = getActivations(sae2.ae{1}, activations2);
[~, accuracy, ~] = svmpredict(convertLabels(test_y), activations3, SVMStruct, []);






 
 
 
 
 
 
end

