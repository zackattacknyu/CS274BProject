function [ rocx,rocy,rocThr,rocAuc,probDet,falseAlarm,thr,auc ] = CURRENT_computeROCstats(p, trialInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11,loss_spec,crf_type,rho )
%CURRENT_COMPUTEROCSTATS Summary of this function goes here
%   Detailed explanation goes here


[feats_test,efeats_test,labels_test,models_test,~,~,~] = ...
    obtainDataFromFiles3(trialInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11);

fprintf('get the marginals for test images...\n');
close all
E = zeros(1,length(feats_test));
T = zeros(1,length(feats_test));
Base = zeros(1,length(feats_test));
CCS = zeros(1,length(feats_test));
biArrays = cell(1,length(feats_test));
for n=1:length(feats_test)
    [b_i b_ij] = eval_crf(p,feats_test{n},efeats_test{n},models_test{n},loss_spec,crf_type,rho);
    biArrays{n} = b_i;
end

allCloudLabels = [];
allCloudScores = [];

for n = 1:length(trialInds)
    curTargetLabels = labels_test{n};
    cloudPixels = find(curTargetLabels>1);
    allCloudLabels = [allCloudLabels curTargetLabels(cloudPixels)'];

    biCur = biArrays{n};
    allCloudScores = [allCloudScores biCur(3,cloudPixels)];

end
[rocx,rocy,rocThr,rocAuc] = perfcurve(allCloudLabels,allCloudScores,3);
[probDet,falseAlarm,thr,auc] = perfcurve(allCloudLabels,allCloudScores,3,'XCrit','accu','YCrit','fpr');

end

