sizr = 500;
sizc = 750;
rho = 0.5;
nvals = 2;

yFiles11 = dir('projectData/ytarget1109*');
xFiles11 = dir('projectData/xdata1109*');
ccsFiles11 = dir('projectData/ccspred1109*');
xOneFiles11 = dir('projectData/xone1109*');

yFiles12 = dir('projectData/ytarget1209*');
xFiles12 = dir('projectData/xdata1209*');
ccsFiles12 = dir('projectData/ccspred1209*');
xOneFiles12 = dir('projectData/xone1209*');

loss_spec = 'trunc_cl_trwpll_5';
crf_type  = 'linear_linear';
options.print_times = 0; % since this is so slow, print stuff to screen
options.gradual     = 1; % use gradual fitting
options.maxiter     = 1000;
options.rho         = rho;
options.reg         = 1e-4;
options.opt_display = 0;


%load('domkeCRFrun_3edgeFeats','p');
load('domkeCRFrun_3edgeFeats_cliqueLoss_new2','p','trainingInds');

%load('avgProbs_sep2011_trainingData','trialInds');

[feats,efeats,labels,models,precipImages,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles3(trainingInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11);

%load('domkeCRFrun_3edgeFeats_cliqueLoss_new2','p','validationInds');
%load('ROCvars_sep2012_3edgeFeats_cliqueLoss_testInds_new2','trialInds2');

%[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    %obtainDataFromFiles3(trialInds2,...
    %xFiles12,yFiles12,ccsFiles12,xOneFiles12);

[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles3(trainingInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11);

XdataTrain = [];
YdataTrain = [];

for i = 1:length(feats)
    i
    XdataTrain = [XdataTrain;feats{i}];
    YdataTrain = [YdataTrain;floor(labels{i}(:))];
end

XdataTest = [];
YdataTest = [];

for i = 1:length(feats_test)
    i
    XdataTest = [XdataTest;feats_test{i}];
    YdataTest = [YdataTest;floor(labels_test{i}(:))];
end

testPixels = find(YdataTrain>1);

%XX = Xdata(testPixels,1:13); %take out the two constant columns
XX = XdataTrain(testPixels,1); %take out the two constant columns
YY = categorical(YdataTrain(testPixels)-2);

bb = mnrfit(XX,YY);

testPixels2 = find(YdataTest>1);
XX2 = XdataTest(testPixels2,1);
YY2 = categorical(YdataTest(testPixels2)-2);

YHAT = mnrval(bb,XX2);


YHAT1 = YHAT(:,1);
YHAT2 = YHAT(:,2);

[rocx3,rocy3,rocThr3,rocAuc3] = perfcurve(YY2,YHAT2,1);
[probDet3,falseAlarm2,thr3,auc3] = perfcurve(YY2,YHAT2,1,'XCrit','accu','YCrit','fpr');

save('logisticRegressionTest_sep2011data_new2_trainingInds.mat',...
    'rocx3','rocy3','rocThr3','rocAuc3',...
    'probDet3','falseAlarm2','thr3','auc3');
%%

load('logisticRegressionTest_sep2011data_new2_trainingInds.mat');
load('ROCvars_sep2011_3edgeFeats_cliqueLoss_trainingInds_new2');
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
title('Validation Data ROC Curve');
plot(rocx3,rocy3,'r-');
plot(rocx,rocy,'g-');
plot(0:0.05:1,0:0.05:1,'b--');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
%legend('Logistic Regression ROC curve',...
%    'CRF ROC Curve','Baseline ROC');
hold off

load('logisticRegressionTest_sep2012data_new2.mat');
load('ROCvars_sep2012_3edgeFeats_cliqueLoss_testInds_new2');

subplot(1,2,2);
hold on
title('Test Data ROC Curve');
plot(rocx3,rocy3,'r-');
plot(rocx,rocy,'g-');
plot(0:0.05:1,0:0.05:1,'b--');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
legend('Logistic Regression',...
    'CRF','Random Guessing','Location','eastoutside');
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