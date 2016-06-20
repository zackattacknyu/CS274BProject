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
%%
testPixels = find(YdataTrain>1);

%XX = Xdata(testPixels,1:13); %take out the two constant columns
XX = XdataTrain(testPixels,1); %take out the two constant columns
YY = categorical(YdataTrain(testPixels)-2);

bb = mnrfit(XX,YY);

testPixels2 = find(YdataTest>1);
XX2 = XdataTest(testPixels2,1);
YY2 = categorical(YdataTest(testPixels2)-2);
%%
YHAT = mnrval(bb,XX2);


YHAT1 = YHAT(:,1);
YHAT2 = YHAT(:,2);

[rocx3,rocy3,rocThr3,rocAuc3] = perfcurve(YY2,YHAT2,1);
[probDet3,falseAlarm2,thr3,auc3] = perfcurve(YY2,YHAT2,1,'XCrit','accu','YCrit','fpr');

Yexp = YdataTrain(testPixels)-2;
ff2 = fit(XX,Yexp,'exp1');

[rocx2,rocy2,rocThr2,rocAuc2] = perfcurve(YY2,ff2(XX2),1);

figure
hold on
plot(rocx3,rocy3,'r-');
plot(rocx,rocy,'g-');
plot(0:0.05:1,0:0.05:1,'b--');
legend('Logistic Regression ROC Curve','Baseline ROC');
xlabel('False positive rate')
ylabel('True positive rate')
hold off
%%

figure
    
subplot(1,2,1);
hold on
title('ROC curves');
plot(rocx3,rocy3,'r-');
plot(0:0.05:1,0:0.05:1,'b--');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
legend('Logistic Regression ROC curve','Baseline ROC');
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
plot(XX2,ff2(XX2),'g.')
plot(XX2,double(YY2)-1,'b.');
hold off
