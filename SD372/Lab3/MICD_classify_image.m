function cimage = MICD_classify_image(train, image)

    c = 10;     % number of images
    n = 16;     % number of blocks
    m = 2;      % number of features
    
    [row col m] = size(image);
    cimage = zeros(row, col);
    
    mean = zeros(m, c);
    sigma = zeros(m, m, c);
    sigma_j = zeros(m, m, n);

    for i = 1:c
        mean(:, i) = sum(train(1:2, (i-1)*n+1:i*n), 2)/n;
        for j = 1:n
            sigma_j(:, :, j) = (train(1:2, n*(i-1)+j) - mean (:, i)) * (train(1:2, n*(i-1)+j) - mean (:, i))';
        end
        sigma(:, :, i) = sum(sigma_j, 3)/n;
    end
    
    for i=1:row
        for j=1:col
            cimage(i, j)=classify_ML_gaussian([image(i, j, 1); image(i, j, 2)], mean, sigma);
        end
    end