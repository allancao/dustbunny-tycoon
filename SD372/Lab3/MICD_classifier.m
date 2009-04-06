function [confusion, error, mean, sigma] = MICD_classifier(train, test)

    c = 10;     % number of images
    n = 16;     % number of blocks
    m = 2;      % number of features
    
    mean = zeros(m, c);
    sigma = zeros(m, m, c);
    sigma_j = zeros(m, m, n);

    for i = 1:c
        mean(:, i) = sum(train(1:2, (i-1)*n+1:i*n), 2)/n;
        %mean(:, i)
        for j = 1:n
            %train(1:2, c*(i-1)+j)-mean(:, i)
            sigma_j(:, :, j) = (train(1:2, n*(i-1)+j) - mean (:, i)) * (train(1:2, n*(i-1)+j) - mean (:, i))';
            %sigma_j(:, :, j)
        end
        sigma(:, :, i) = sum(sigma_j, 3)/n;
        %sigma(:, :, i)
    end
        
    %confusion=0;
    %error=0;
    [confusion, error] = confusion_matrix(test, mean, sigma);
    
%     classifier = zeros(length(y),length(x));
%     
%     for i=1:length(y)
%         for j=1:length(x)
%             classifier(i, j)=classify_ML_gaussian([x(j);y(i)], mean', sigma, n);
%         end
%     end
%     
%     hold on
%     
%     colors = 'rgb';    
%     for i = 1:c      
%         plot(data(:, 1, i), data(:, 2, i), strcat('.', colors(i)));
%     end;
%     
%     contour(x, y, classifier, c-1, 'k-', 'LineWidth', 2);
%     
%     hold off