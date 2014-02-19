%This function will perform ZCA whitening of the data in x
%Each column contains the vectorised pixels of a single image e.g. to pass
%10000 images that are each 12x12 pixels, x will be in the format
%x: 144x10000
function xZCAWhite = zcaWhiten(x)
        
    x = bsxfun(@minus,x,mean(x,1)); %subtract the mean image

    epsilon = 0.1;
    xPCAWhite = zeros(size(x));

    sigma = 1 / size(x,2) * (x * x');
    [u,s,v] = svd(sigma); %PCA        
    xRot = u' * x;
    xPCAWhite = bsxfun(@times,1 ./ (sqrt(diag(s) + epsilon)),xRot);

    xZCAWhite = zeros(size(x));
    xZCAWhite = u * xPCAWhite;
          
end
