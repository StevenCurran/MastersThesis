function [] = SaeTestParams( input_args )

load mnist_uint8;

train_x = double(train_x)/255;
test_x  = double(test_x)/255;
train_y = double(train_y);
test_y  = double(test_y);

overallAccuracy = [];

for i = 1:length(input_args)
    
    rand('state',0)
    sae = saesetup([784 200]);
    sae.ae{1}.activation_function       = 'sigm';
    sae.ae{1}.learningRate              = input_args(i);
    sae.ae{1}.inputZeroMaskedFraction   = 0.5;
    opts.numepochs = 10;
    opts.batchsize = 1;
    
    disp('training network....');
    
    sae = saetrain(sae, train_x, opts);
    
    activations1 = getActivations(sae.ae{1}, train_x);
    svmlabels = convertLabels(train_y);
    
    disp('training svm...');
    
    SVMStruct = svmtrain(svmlabels,activations1,[]);
    
    activations2 = getActivations(sae.ae{1}, test_x);
    
    disp('predicting....');
    
    [predicted_label, accuracy, prob] = svmpredict(convertLabels(test_y), activations2, SVMStruct, []);
    
    
    overallAccuracy = [overallAccuracy ; accuracy(1,1)];
    save('learningRateAccuracy.mat', 'overallAccuracy');
    
end


end

