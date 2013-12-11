load mnist_uint8;

train_x = double(train_x)/255;
test_x  = double(test_x)/255;
train_y = double(train_y);
test_y  = double(test_y);

%%  ex1 train a 100 hidden unit SDAE and use it to initialize a FFNN
%  Setup and train a stacked denoising autoencoder (SDAE)

s = loadAllDigitsIntoStruct(test_x, test_y);

%lets hide one digit that we are gonna classify
imageToClassify = s.f8(1,:);
s.f8 = s.f8(3:end,:);

test = vertcat(s.f0, s.f8, s.f2);
labels = createLabelVector([length(s.f0) length(s.f8) length(s.f2)],['0' '8' '2']);

%training = datasample(test,784);
rand('state',0)
%sae = saesetup([784 100]);
sae = saesetup([size(test,2) 100]);
sae.ae{1}.activation_function       = 'sigm';
sae.ae{1}.learningRate              = 0.05;
sae.ae{1}.inputZeroMaskedFraction   = 0.5;
opts.numepochs =   3;
opts.batchsize = 1;
%sae = saetrain(sae, train_x, opts);
sae = saetrain(sae, train_x, opts); %to stack this we pass in the activations from
% the previous autoencoder, instead of train.
visualize(sae.ae{1}.W{1}(:,2:end)')

sae;
%Trains the SVM

%activations = sigm(input * nn.W{i - 1}');
%activations = sigm(input * sae.ae{1}.W{1}(:,2:end)'); % should be of size 1954
%activations1 = sigm(test * sae.ae{1}.W{1}(:,2:end));

activations1 = getActivations(sae.ae{1}, train_x);


%- When computing the activations you are forgetting the bias term. This happens on line 9 of nnff.m where a 1 is appended to all training examples. 

%- When computing the activations you are using the weights from the wrong layer. You should be using W{1}. See line 17 of nnff.m

%[size of test , size of hidden]
%pass to svmtrain with labels
%SVMStruct = svmtrain(activations1,labels,'showplot',true);
%try with lib svm

svmlabels = convertLabels(train_y);

SVMStruct = svmtrain(svmlabels,activations1,[]);


%Load in a new image


activations2 = getActivations(sae.ae{1}, test_x);
%[1 , size of hidden]
%pass to svmtest
%return the label

[predicted_label, accuracy, prob] = svmpredict(convertLabels(test_y), activations2, SVMStruct, []);


AccuVector(index)=accuracy;
%digit = svmclassify(SVMStruct,activations2);


figure
plot([1:10],AccuVector)
hold on
plot([1:10],AccuVector*1.3,'r')


%plot individual numbers
figure
ii=reshape(imageToClassify,[28 28])
imagesc(ii')