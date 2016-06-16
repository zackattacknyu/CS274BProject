%NOTE: MUST UNZIP JGMT4.zip TO HERE BEFORE RUNNING THE CODE
%   THE FOLDER MUST THEN BE ADDED TO THE PATH


sizr = 500;
sizc = 750;
rho = 0.5;
nvals = 2;

addpath(genpath('JustinsGraphicalModelsToolboxPublic'))

yFiles11 = dir('projectData/ytarget1109*');
xFiles11 = dir('projectData/xdata1109*');
ccsFiles11 = dir('projectData/ccspred1109*');
xOneFiles11 = dir('projectData/xone1109*');

yFiles12 = dir('projectData/ytarget1209*');
xFiles12 = dir('projectData/xdata1209*');
ccsFiles12 = dir('projectData/ccspred1209*');
xOneFiles12 = dir('projectData/xone1209*');

totalN = length(xFiles11);
%trialInds = 1:totalN;
numRandInds = 100;
load('highestPrecipInds1109');
trialInds = highestPrecipInds(1:numRandInds);

loss_spec = 'trunc_cl_trwpll_5';
%loss_spec = 'em_mnf_1e5';
%loss_spec = 'trunc_uquad_trwpll_5';

crf_type  = 'linear_linear';
%options.viz         = @viz;
options.print_times = 0; % since this is so slow, print stuff to screen
options.gradual     = 1; % use gradual fitting
options.maxiter     = 1000;
options.rho         = rho;
options.reg         = 1e-4;
options.opt_display = 0;

load('domkeCRFrun_3edgeFeats_emTRW','p');

[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
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

save('ROCvars_sep2011_highestPrecipMaps_3edgeFeats_emTRW.mat',...
    'rocx','rocy','rocThr','rocAuc',...
    'probDet','falseAlarm','thr','auc');
%%
figure
hold on
plot(rocx,rocy);
plot(0:0.05:1,0:0.05:1,'b--');
legend('ROC Curve','Baseline ROC');
xlabel('False positive rate')
ylabel('True positive rate')
hold off

figure
hold on
title('Threshold versus Error Rates for CRF model');
plot(rocThr,rocy,'r-');
plot(rocThr,rocx,'b-');
plot(thr,probDet,'k-');
legend('True Positive','False Positive','Accuracy');
xlabel('Score Threshold for Class 3');
ylabel('Rate');
hold off



