load('logisticRegressionTest_sep2011data_new2_trainingInds.mat');
load('ROCvars_sep2011_3edgeFeats_cliqueLoss_trainingInds_new2');
patchTrain2 = load('ROCvars_sep2011_patchPred_new2_trainingInds');
figure
    %{
subplot(1,3,1);
hold on
title('ROC curves');
plot(rocx3,rocy3,'r-');
plot(rocx,rocy,'g-');
plot(0:0.05:1,0:0.05:1,'b--');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
%legend('Logistic Regression ROC curve',...
%    'CRF ROC Curve','Baseline ROC');
hold off

load('logisticRegressionTest_sep2011data_new2_validationInds.mat');
load('ROCvars_sep2011_3edgeFeats_cliqueLoss_validationInds_new2');
%}
subplot(1,2,1);
hold on
title('Training Data ROC Curve');
plot(rocx3,rocy3,'r-');
plot(rocx,rocy,'g-');
plot(patchTrain2.rocx,patchTrain2.rocy,'k-');
plot(0:0.05:1,0:0.05:1,'b--');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
%legend('Logistic Regression ROC curve',...
%    'CRF ROC Curve','Baseline ROC');
hold off

load('logisticRegressionTest_sep2012data_new2.mat');
load('ROCvars_sep2012_3edgeFeats_cliqueLoss_testInds_new2');
patchTrain = load('ROCvars_sep2012_new2PatchTrainP_testInds.mat');

subplot(1,2,2);
hold on
title('Test Data ROC Curve');
plot(rocx3,rocy3,'r-');
plot(rocx,rocy,'g-');
plot(patchTrain.rocx,patchTrain.rocy,'k-');
plot(0:0.05:1,0:0.05:1,'b--');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
legend('Logistic Regression',...
    'CRF','CRF trained on patches','Random Guessing','Location','eastoutside');
hold off


%{
subplot(1,2,2);
hold on
title('Threshold versus Error Rates for Logistic Regression');
plot(rocThr3,rocy3,'r-');
plot(rocThr3,rocx3,'b-');
plot(thr3,probDet3,'k-');
legend('True Positive','False Positive','Accuracy');
xlabel('Score Threshold for Rainfall');
ylabel('Rate');
hold off
%%
figure
hold on
plot(XX2,YHAT2,'r.')
plot(XX2,double(YY2)-1,'b.');
hold off
%}

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
