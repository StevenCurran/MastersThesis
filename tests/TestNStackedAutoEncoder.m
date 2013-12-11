 
load mnist_uint8;

test_x = double(test_x)/255;
test_y = double(test_y);


input = [784 200 100 10];

rand('state',0)


[Sae,Activations] = CreateNStackedAutoEncoder(input, test_x);

svmlabels = convertLabels(test_y);

SVMStruct = svmtrain(svmlabels,Activations,[]);

[~, accuracy, ~] = svmpredict(convertLabels(test_y), GetFinalActivations(Sae,test_x), SVMStruct, []);


