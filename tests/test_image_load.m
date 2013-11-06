function test_image_load
%load mnist_uint8;

imageFiles = dir(fullfile('Q:', 'MATLAB', 'images','training','training','all','*.png'))

training = zeros(length(imageFiles),256*256);
parfor i = 1:length(imageFiles)
    fileName = imageFiles(i).name
    singleImage = rgb2gray(imread(fileName))/255;
    flatten = reshape(singleImage, 1,256*256);
    training(i,:) = flatten;
end


%%  ex1 train a 100 hidden unit RBM and visualize its weights
rand('state',0)
dbn.sizes = [100];
opts.numepochs =   10;
opts.batchsize = 5;
opts.momentum  =   0.5;
opts.alpha     =   1;
dbn = dbnsetup(dbn, training, opts);
dbn = dbntrain(dbn, training, opts);
figure; visualize(dbn.rbm{1}.W');   %  Visualize the RBM weights

