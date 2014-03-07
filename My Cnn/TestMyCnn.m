tic
[people, nonPeople] = GetImages();
disp('Images Retrieved')

%124*76

IMAGEHEIGHT = 52;
IMAGEWIDTH = 32;
zcaPeople = reshape(people, IMAGEHEIGHT*IMAGEWIDTH, length(people));
whitenPeople = zcaWhiten(zcaPeople);
whitenPeople = reshape(whitenPeople, IMAGEHEIGHT,IMAGEWIDTH,length(people));

zcaNonPeople = reshape(nonPeople, IMAGEHEIGHT*IMAGEWIDTH, length(nonPeople));
whitenNonPeople = zcaWhiten(zcaNonPeople);
whitenNonPeople = reshape(whitenNonPeople, IMAGEHEIGHT,IMAGEWIDTH,length(nonPeople));

train_x = train_x(:,:,1:40000);
train_y = train_y(:,1:40000);

[train_x, train_y, test_x, test_y] = GenerateTestData(whitenPeople, whitenNonPeople);
disp('Generating Test Data')

%train_x = people;
%train_y = zeros(2,length(train_x));

%% height = 124 width = 76
rand('state',0)
cnn.layers = {
    struct('type', 'i') %input layer
    struct('type', 'c', 'outputmaps', 16, 'kernelsize', 11) %convolution layer
    struct('type', 's', 'scale', 2) %sub sampling layer
    struct('type', 'c', 'outputmaps', 24, 'kernelsize', 6) %convolution layer
    struct('type', 's', 'scale', 2) %subsampling layer
};
cnn = cnnsetup(cnn, train_x, train_y);
disp('CNN Constructed')

opts.alpha = 0.5;
div = divisor(length(train_x));
opts.batchsize = div(ceil(end/2)+1);
opts.numepochs = 3;

cnn = cnntrain(cnn, train_x, train_y, opts);
disp('CNN Trained')
clear train_x train_y
%save('cnn.mat','cnn'); Warning this is going to be massive.
disp('CNN Saved')
toc
[er, bad] = cnntest(cnn, test_x, test_y);

single_image = test_x(:,:,1000);
netout = cnnff(cnn, single_image);

%plot mean squared error
figure; plot(cnn.rL);