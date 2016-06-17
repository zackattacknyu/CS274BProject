%PIXELWISE ERROR RATES COMPUTED HERE
fprintf('get the marginals for test images...\n');
close all
allProbsAmongRain = [];
allProbsAmongNoRain = [];
for n=1:length(feats_test)
    n
    [b_i b_ij] = eval_crf(p,feats_test{n},efeats_test{n},models_test{n},loss_spec,crf_type,rho);
    
    bi3re=reshape(b_i(3,:),sizr,sizc);
    curTargetLabels = labels_test{n};

    rainfallPixels = find(curTargetLabels==3);
    noRainPixels = find(curTargetLabels==2);
    
    probsAmongNoRain = bi3re(noRainPixels);
    probsAmongRain = bi3re(rainfallPixels);
    
    allProbsAmongRain = [allProbsAmongRain;probsAmongRain];
    allProbsAmongNoRain = [allProbsAmongNoRain;probsAmongNoRain];
    
end

avgProbAmongRainPixels = mean(allProbsAmongRain);
avgProbAmongNoRainPixels = mean(allProbsAmongNoRain);

%{
IMPORTANT NOTE:
IN AVGPROBS_SEP2011.MAT AND
IN AVGPROBS_SEP2012.MAT THE 
AVERAGE PROBABILITIES ARE SWITCHED DUE TO AN
EARLIER BUG
%}