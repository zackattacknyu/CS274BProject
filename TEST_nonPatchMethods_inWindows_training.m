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
load('domkeCRFrun_3edgeFeats_cliqueLoss_new3','p','trainingInds');

%load('avgProbs_sep2011_trainingData','trialInds');

[feats,efeats,labels,models,precipImages,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles3(trainingInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11);

[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles3(trainingInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11);
%%
%[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
%    obtainDataFromFiles3(validationInds,...
%    xFiles11,yFiles11,ccsFiles11,xOneFiles11);

XdataTrain = [];
YdataTrain = [];

load('ROCvars_sep2011_patchPred_new3_trainingInds_patchData.mat',...
    'patchCoordsTrain')

for n = 1:length(patchCoordsTrain)
    n
   
   curWholeX = reshape(feats{n}(:,1),sizr,sizc);
   curWholeY = labels{n};
   
   for nn = 1:length(patchCoordsTrain{n})
      coords = patchCoordsTrain{n}{nn};
      minR = coords(1); maxR = coords(2); 
      minC = coords(3); maxC = coords(4);
      
      curXpatch = curWholeX(minR:maxR,minC:maxC);
      curYpatch = curWholeY(minR:maxR,minC:maxC);

      XdataTrain = [XdataTrain;curXpatch(:)];
      YdataTrain = [YdataTrain;curYpatch(:)];
   end

end

%{
for i = 1:length(feats)
    i
    XdataTrain = [XdataTrain;feats{i}];
    YdataTrain = [YdataTrain;floor(labels{i}(:))];
end
%}
XdataTest = [];
YdataTest = [];

patchCoords = patchCoordsTrain;

biArrays = cell(1,length(feats_test));
for n=1:length(feats_test)
    [b_i b_ij] = eval_crf(p,feats_test{n},efeats_test{n},models_test{n},loss_spec,crf_type,rho);
    biArrays{n} = b_i;    
end

allCloudLabels = [];
allCloudScores = [];

%{
for i = 1:length(feats_test)
    i
    XdataTest = [XdataTest;feats_test{i}];
    YdataTest = [YdataTest;floor(labels_test{i}(:))];
end
%}
for n = 1:length(patchCoords)
    n
   
   curWholeX = reshape(feats_test{n}(:,1),sizr,sizc);
   curWholeY = labels_test{n};
   
   currentBi = biArrays{n}(3,:);
   currentBiMap = reshape(currentBi,sizr,sizc);
   
   for nn = 1:length(patchCoords{n})
      coords = patchCoords{n}{nn};
      minR = coords(1); maxR = coords(2); 
      minC = coords(3); maxC = coords(4);
      
      curXpatch = curWholeX(minR:maxR,minC:maxC);
      curYpatch = curWholeY(minR:maxR,minC:maxC);
      currentBiPatch = currentBiMap(minR:maxR,minC:maxC);
      
      cloudPixels = find(curYpatch>1);
      allCloudLabels = [allCloudLabels curYpatch(cloudPixels)'];
      allCloudScores = [allCloudScores currentBiPatch(cloudPixels)'];

      XdataTest = [XdataTest;curXpatch(:)];
      YdataTest = [YdataTest;curYpatch(:)];
   end

end

[rocx,rocy,rocThr,rocAuc] = perfcurve(allCloudLabels,allCloudScores,3);
[probDet,falseAlarm,thr,auc] = perfcurve(allCloudLabels,allCloudScores,3,'XCrit','accu','YCrit','fpr');

testPixels = find(YdataTrain>1);

%XX = Xdata(testPixels,1:13); %take out the two constant columns
XX = XdataTrain(testPixels,1); %take out the two constant columns
YY = categorical(YdataTrain(testPixels)-2);

bb = mnrfit(XX,YY);

testPixels2 = find(YdataTest>1);
XX2 = XdataTest(testPixels2);
YY2 = categorical(YdataTest(testPixels2)-2);

YHAT = mnrval(bb,XX2);


YHAT1 = YHAT(:,1);
YHAT2 = YHAT(:,2);

[rocx3,rocy3,rocThr3,rocAuc3] = perfcurve(YY2,YHAT2,1);
[probDet3,falseAlarm2,thr3,auc3] = perfcurve(YY2,YHAT2,1,'XCrit','accu','YCrit','fpr');

%save('logisticRegressionTest_sep2011data_new2_validationInds.mat',...
save('logRegressionAndCrfROCvars_sep2011data_new3_inWindow.mat',...
    'rocx','rocy','rocThr','rocAuc','probDet','falseAlarm','thr','auc',...
    'rocx3','rocy3','rocThr3','rocAuc3',...
    'probDet3','falseAlarm2','thr3','auc3');
%{

load('logisticRegressionTest_sep2011data_new2_validationInds.mat');

figure
    
subplot(1,2,1);
hold on
title('ROC curves');
plot(rocx3,rocy3,'r-');
plot(rocx,rocy,'g-');
plot(0:0.05:1,0:0.05:1,'b--');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
legend('Logistic Regression ROC curve',...
    'CRF ROC Curve','Baseline ROC');
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