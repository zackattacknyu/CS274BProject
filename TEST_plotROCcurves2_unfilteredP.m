
%{
If true, then all the methods are compared with the data that
    is contained inside each of the patches
If false, whole map is compared
%}
useOnlyWindows = false;

if(useOnlyWindows)
    crfAndLogData = load('logRegressionAndCrfROCvars_sep2012data_new3_inWindow_unfilteredP.mat');
    patchCRFdata = load('ROCvars_sep2012_new3PatchTrainP_testInds_unfilteredP.mat');
    rocxData = {crfAndLogData.rocx3,crfAndLogData.rocx,patchCRFdata.rocx};
    rocyData = {crfAndLogData.rocy3,crfAndLogData.rocy,patchCRFdata.rocy};
    
    crfAndLogDataTrain = load('logRegressionAndCrfROCvars_sep2011data_new3_inWindow_unfilteredP.mat');
    patchCRFdataTrain = load('ROCvars_sep2011_patchPred_new3_trainingInds_unfilteredP.mat');
    rocxDataTrain = {crfAndLogDataTrain.rocx3,crfAndLogDataTrain.rocx,patchCRFdataTrain.rocx};
    rocyDataTrain = {crfAndLogDataTrain.rocy3,crfAndLogDataTrain.rocy,patchCRFdataTrain.rocy};
else
    LogData = load('logisticRegressionTest_sep2012data_new3.mat');
    crfdata = load('ROCvars_sep2012_3edgeFeats_cliqueLoss_testInds_new3');
    patchCRFdata = load('ROCvars_sep2012_new3PatchTrainP_testInds_wholeMap_unfilteredP.mat');
    rocxData = {LogData.rocx3,crfdata.rocx,patchCRFdata.rocx};
    rocyData = {LogData.rocy3,crfdata.rocy,patchCRFdata.rocy};
    
    LogDataTrain = load('logisticRegressionTest_sep2011data_new3_trainingInds.mat');
    crfdataTrain = load('ROCvars_sep2011_3edgeFeats_cliqueLoss_trainingInds_new3');
    patchCRFdataTrain = load('ROCvars_sep2011_new3PatchTrainP_trainingInds_wholeMap.mat');
    rocxDataTrain = {LogDataTrain.rocx3,crfdataTrain.rocx,patchCRFdataTrain.rocx};
    rocyDataTrain = {LogDataTrain.rocy3,crfdataTrain.rocy,patchCRFdataTrain.rocy};
end

figure

subplot(1,2,1);
hold on
title('Training Data ROC Curve');
plot(rocxDataTrain{1},rocyDataTrain{1},'r-');
plot(rocxDataTrain{2},rocyDataTrain{2},'g-');
plot(rocxDataTrain{3},rocyDataTrain{3},'k-');
plot(0:0.05:1,0:0.05:1,'b--');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
hold off

subplot(1,2,2);
hold on
title('Test Data ROC Curve');
plot(rocxData{1},rocyData{1},'r-');
plot(rocxData{2},rocyData{2},'g-');
plot(rocxData{3},rocyData{3},'k-');
plot(0:0.05:1,0:0.05:1,'b--');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
legend('Logistic Regression',...
    'CRF','Patch-based CRF',...
    'Random Guessing','Location','eastoutside');
hold off


%%


load('logisticRegressionTest_sep2012data_new2.mat');
load('ROCvars_sep2012_3edgeFeats_cliqueLoss_testInds_new2');

%patchROC = load('ROCvars_sep2012_patchPred_randInds1.mat');
patchROC = load('ROCvars_sep2012_patchPred_new2testInds.mat');
figure
hold on
title('Test Data ROC Curve');
plot(rocx3,rocy3,'r-');
plot(patchROC.rocx,patchROC.rocy,'k-');
plot(rocx,rocy,'g-');
plot(0:0.05:1,0:0.05:1,'b--');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
legend('Logistic Regression',...
    'CRF on Patches','CRF on whole maps','Random Guessing','Location','eastoutside');
hold off
