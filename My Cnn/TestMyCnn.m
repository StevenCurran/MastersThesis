tic
[people, nonPeople] = GetImages();
disp('Images Retrieved')

zcaPeople = reshape(people, 124*76, length(people));
whitenPeople = zcaWhiten(zcaPeople);
whitenPeople = reshape(whitenPeople, 124,76,length(people));

zcaNonPeople = reshape(nonPeople, 124*76, length(nonPeople));
whitenNonPeople = zcaWhiten(zcaNonPeople);
whitenNonPeople = reshape(whitenNonPeople, 124,76,length(nonPeople));



[train_x, train_y, test_x, test_y] = GenerateTestData(whitenPeople, whitenNonPeople);
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

opts.alpha = 0.5;
div = divisor(length(train_x));
opts.batchsize = div(ceil(end/2)+1);
opts.numepochs = 10;

cnn = cnntrain(cnn, train_x, train_y, opts);
disp('CNN Trained')
clear train_x train_y
%save('cnn.mat','cnn'); Warning this is going to be massive.
disp('CNN Saved')
toc
[er, bad] = cnntest(cnn, test_x, test_y);

%plot mean squared error
figure; plot(cnn.rL);