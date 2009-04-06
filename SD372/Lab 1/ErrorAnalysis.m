function ErrorAnalysis( mean1, sigma1, n1, mean2, sigma2, n2, mean3, sigma3, n3)

    plotDistributions = false;

    nothing = 0; %So the non-parametric classifer signature matches the parametric classifier signature

    dist1 = generate_cluster(n1, mean1, sigma1, 'g', plotDistributions);
    dist2 = generate_cluster(n2, mean2, sigma2, 'y', plotDistributions);
    if n3 ~= 0
       dist3 = generate_cluster(n3, mean3, sigma3, 'c', plotDistributions);
       trainingData = ConcatenateClasses(dist1, dist2, dist3);
    else
        trainingData = ConcatenateClasses(dist1, dist2, 0);
    end
    
    z = [mean1, mean2];
    sigma = [sigma1, sigma2];

    dist1 = generate_cluster(n1, mean1, sigma1, 'r', plotDistributions);
    dist2 = generate_cluster(n2, mean2, sigma2, 'b', plotDistributions);
    if n3 ~= 0
       dist3 = generate_cluster(n3, mean3, sigma3, 'm', plotDistributions);
       testData = ConcatenateClasses(dist1, dist2, dist3);
       
       z = [z mean3];
       sigma = [sigma sigma3];
       
    else
        testData = ConcatenateClasses(dist1, dist2, 0);
    end
    
    
    [nnConfusionMatrix, nnProbOfError] = GenerateConfusionMatrix(testData, trainingData, nothing, @(testData, trainingData, nothing)classify_NN(testData, trainingData))
    [knnConfusionMatrix, knnProbOfError] = GenerateConfusionMatrix(testData, trainingData, nothing, @(testData, trainingData, nothing)classify_5NN(testData, trainingData))
    
    [gedConfusionMatrix, gedProbOfError] = GenerateConfusionMatrix(testData, z, sigma, @classify_GED)
    [medConfusionMatrix, medProbOfError] = GenerateConfusionMatrix(testData, z, nothing, @(x, sigma, nothing)classify_MED(x, sigma))
    
end
