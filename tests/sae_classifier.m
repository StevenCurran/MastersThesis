load mnist_uint8;

train_x = double(train_x)/255;
test_x  = double(test_x)/255;
train_y = double(train_y);
test_y  = double(test_y);

%%  ex1 train a 100 hidden unit SDAE and use it to initialize a FFNN
%  Setup and train a stacked denoising autoencoder (SDAE)

s = loadAllDigitsIntoStruct(test_x, test_y);
test = vertcat(s.f0, s.f8);
labels = createLabelVector([length(s.f0) length(s.f8)],['0' '8']);

%training = datasample(test,784);
rand('state',0)
%sae = saesetup([784 100]);
sae = saesetup([size(test,2) 100]);
sae.ae{1}.activation_function       = 'sigm';
sae.ae{1}.learningRate              = 1;
sae.ae{1}.inputZeroMaskedFraction   = 0.5;
opts.numepochs =   5;
opts.batchsize = 2;
%sae = saetrain(sae, train_x, opts);
sae = saetrain(sae, test, opts);
visualize(sae.ae{1}.W{1}(:,2:end)')

disp('initialising a neural net from trained weights')

% Use the SDAE to initialize a FFNN
nn = nnsetup([size(test,2) 100 size(test,2)]);
nn.activation_function              = 'sigm';
nn.learningRate                     = 1;
nn.W{1} = sae.ae{1}.W{1};

disp('training the net from the labels and our new output')

% Train the FFNN
opts.numepochs =   5;
opts.batchsize = 2;
nn = nntrain(nn, test, labels, opts);

%[er, bad] = nntest(nn, test_x, test_y);
%assert(er < 0.16, 'Too big error');



