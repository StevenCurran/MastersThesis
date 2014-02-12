tic
[people, nonPeople] = GetImages();
disp('Images Retrieved')

[train_x, train_y, test_x, test_y] = GenerateTestData(people, nonPeople);
disp('Generating Test Data')

%train_x = people;
%train_y = zeros(2,length(train_x));

%% height = 124 width = 76
rand('state',0)
cnn.layers = {
    struct('type', 'i') %input layer
    struct('type', 'c', 'outputmaps', 6, 'kernelsize', 5) %convolution layer
    struct('type', 's', 'scale', 2) %sub sampling layer
    struct('type', 'c', 'outputmaps', 12, 'kernelsize', 5) %convolution layer
    struct('type', 's', 'scale', 2) %subsampling layer
};
cnn = cnnsetup(cnn, train_x, train_y);
disp('CNN Constructed')

opts.alpha = 0.2;
div = divisor(length(train_x));
opts.batchsize = div(ceil(end/2)+1);
opts.numepochs = 1;

cnn = cnntrain(cnn, train_x, train_y, opts);
disp('CNN Trained')
clear train_x train_y
%save('cnn.mat','cnn'); Warning this is going to be massive.
disp('CNN Saved')
toc
[er, bad] = cnntest(cnn, test_x, test_y);

%plot mean squared error
figure; plot(cnn.rL);