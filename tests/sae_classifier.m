load mnist_uint8;

%train_x = double(train_x)/255;
test_x  = double(test_x)/255;
%train_y = double(train_y);
test_y  = double(test_y);

%%  ex1 train a 100 hidden unit SDAE and use it to initialize a FFNN
%  Setup and train a stacked denoising autoencoder (SDAE)

s = loadAllDigitsIntoStruct(test_x, test_y);

%lets hide one digit that we are gonna classify
imageToClassify = s.f8(1,:);
s.f8 = s.f8(3:end,:);

test = vertcat(s.f0, s.f8,s.f1);
labels = createLabelVector([length(s.f0) length(s.f8) length(s.f1)],['0' '8' '1']);

%training = datasample(test,784);
rand('state',0)
%sae = saesetup([784 100]);
sae = saesetup([size(test,2) 100]);
sae.ae{1}.activation_function       = 'sigm';
sae.ae{1}.learningRate              = 0.1;
sae.ae{1}.inputZeroMaskedFraction   = 0.5;
opts.numepochs =   5;
opts.batchsize = 1;
%sae = saetrain(sae, train_x, opts);
sae = saetrain(sae, test, opts);
visualize(sae.ae{1}.W{1}(:,2:end)')


%Trains the SVM

%activations = sigm(input * nn.W{i - 1}');
%activations = sigm(input * sae.ae{1}.W{1}(:,2:end)'); % should be of size 1954
activations1 = sigm(test * sae.ae{1}.W{2}(:,2:end));

%[size of test , size of hidden]
%pass to svmtrain with labels
%SVMStruct = svmtrain(activations1,labels,'showplot',true);
%try with lib svm
SVMStruct = svmtrain(activations1,labels,[]);


%Load in a new image

%Test the SVM
input = s.f8(1,:);
activations2 = sigm(imageToClassify * sae.ae{1}.W{2}(:,2:end));
%[1 , size of hidden]
%pass to svmtest
%return the label

predicted_label = svmpredict(labels, activations2, SVMStruct, []);

digit = svmclassify(SVMStruct,activations2,'showplot',true)
hold on;
plot(100,100,'ro','MarkerSize',12);
hold off




%nn = nntrain(nn, test, labels, opts);

%[er, bad] = nntest(nn, test_x, test_y);
%assert(er < 0.16, 'Too big error');



