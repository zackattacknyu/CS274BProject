sizr = 500;
sizc = 750;
rho = 0.5;
nvals = 2;

yFiles11 = dir('projectData/ytarget1109*');
xFiles11 = dir('projectData/xdata1109*');
ccsFiles11 = dir('projectData/ccspred1109*');
xOneFiles11 = dir('projectData/xone1109*');
segFiles11 = dir('projectData/seg1109*');

yFiles12 = dir('projectData/ytarget1209*');
xFiles12 = dir('projectData/xdata1209*');
ccsFiles12 = dir('projectData/ccspred1209*');
xOneFiles12 = dir('projectData/xone1209*');
segFiles12 = dir('projectData/seg1209*');

loss_spec = 'trunc_cl_trwpll_5';
crf_type  = 'linear_linear';
options.print_times = 0; % since this is so slow, print stuff to screen
options.gradual     = 1; % use gradual fitting
options.maxiter     = 1000;
options.rho         = rho;
options.reg         = 1e-4;
options.opt_display = 0;


%load('domkeCRFrun_3edgeFeats','p');
load('domkeCRFrun_3edgeFeats_cliqueLoss_new3','p','trainingInds');

%load('avgProbs_sep2011_trainingData','trialInds');

%trainingInds = trainingInds(1:5);
[feats,efeats,labels,models,precipImages,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles3_add2col(trainingInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11,segFiles11);

%load('domkeCRFrun_3edgeFeats_cliqueLoss_new3','p','validationInds');
load('ROCvars_sep2012_3edgeFeats_cliqueLoss_testInds_new3','trialInds2');

%trialInds2 = trialInds2(1:5);
[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles3_add2col(trialInds2,...
    xFiles12,yFiles12,ccsFiles12,xOneFiles12,segFiles12);

%[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
%    obtainDataFromFiles3(validationInds,...
%    xFiles11,yFiles11,ccsFiles11,xOneFiles11);

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
%%
XX = XdataTrain(testPixels,[1:13 16:17]); %take out the two constant columns
XXwo = XdataTrain(testPixels,[1 16]);
XXwo2 = XdataTrain(testPixels,1);
YY = categorical(YdataTrain(testPixels)-2);

bb = mnrfit(XX,YY);
bbwo = mnrfit(XXwo,YY);
bbwo2 = mnrfit(XXwo2,YY);

testPixels2 = find(YdataTest>1);
XX2 = XdataTest(testPixels2,[1:13 16:17]);
XX2wo = XdataTest(testPixels2,[1 16]);
XX2wo2 = XdataTest(testPixels2,1);
YY2 = categorical(YdataTest(testPixels2)-2);

YHAT = mnrval(bb,XX2);
YHATwo = mnrval(bbwo,XX2wo);

YHATwo2 = mnrval(bbwo2,XX2wo2);


YHAT1 = YHAT(:,1);
YHAT2 = YHAT(:,2);

YHAT1wo = YHATwo(:,1);
YHAT2wo = YHATwo(:,2);

YHAT2wo2 = YHATwo2(:,2);

[rocx3,rocy3,rocThr3,rocAuc3] = perfcurve(YY2,YHAT2,1);
[probDet3,falseAlarm3,thr3,auc3] = perfcurve(YY2,YHAT2,1,'XCrit','accu','YCrit','fpr');

[rocx2,rocy2,rocThr2,rocAuc2] = perfcurve(YY2,YHAT2wo,1);
[probDet2,falseAlarm2,thr2,auc2] = perfcurve(YY2,YHAT2wo,1,'XCrit','accu','YCrit','fpr');

[rocx4,rocy4,rocThr4,rocAuc4] = perfcurve(YY2,YHAT2wo2,1);
[probDet4,falseAlarm4,thr4,auc4] = perfcurve(YY2,YHAT2wo2,1,'XCrit','accu','YCrit','fpr');
%%
%save('logisticRegressionTest_sep2011data_new2_validationInds.mat',...
save('logisticRegressionTest_sep2012data_new3_withAndWoOther2.mat',...
    'rocx3','rocy3','rocThr3','rocAuc3',...
    'probDet3','falseAlarm3','thr3','auc3',...
    'rocx2','rocy2','rocThr2','rocAuc2',...
    'probDet2','falseAlarm2','thr2','auc2',...
    'rocx4','rocy4','rocThr4','rocAuc4',...
    'probDet4','falseAlarm4','thr4','auc4');
%%

load('logisticRegressionTest_sep2012data_new3_withAndWoOther2.mat');

%RESULT: NEARLY NO DIFFERENCE BETWEEN THE ROC CURVES
%        THUS OTHER CLOUD PATCH FEATURES MAKE NEARLY NO DIFFERENCE
figure
    
subplot(1,2,1);
hold on
title('ROC curves');
plot(rocx2,rocy2,'g-');
plot(rocx3,rocy3,'r-');
plot(rocx4,rocy4,'K-');
plot(0:0.05:1,0:0.05:1,'b--');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
legend('Logistic Regression with only temp and new feature',...
    'Logistic Regression with all features','Logistic Regression with only temp',...
    'Baseline ROC');
hold off

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