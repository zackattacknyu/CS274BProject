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
numRandInds = 160;
trialInds = sort(unique(floor(rand(1,numRandInds)*totalN)));

%load('highestPrecipInds1109');
%trialInds = highestPrecipInds(1:numRandInds);


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

%%
%feats{n}  = featurize_im(ims{n},feat_params);
[feats,efeats,labels,models,precipImages] = obtainDataFromFiles(trialInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11);

fprintf('training the model (this is slow!)...\n')
p = train_crf(feats,efeats,labels,models,loss_spec,crf_type,options)
%p = train_crf(feats,[],labels,models,loss_spec,crf_type,options)

save('domkeCRFrun18.mat','p');

%%
load('domkeCRFrun19','p');
%load('domkeCRFrun_emLoss_250times','p');
%load('domkeCRFrun_constEdges','p');
%load('domkeCRFrun_constEdges_withPairs','p');
%load('currentDomkeResults19_mini'); %DISTRIBUTION IS NOT VERY BIMODAL
%load('currentDomkeResults19_mini_precipBound'); %DIST IS QUITE BIMODAL THIS WAY
%load('currentDomkeResults19_mini_precipBoundRand');
%load('currentDomkeResults17.mat','p'); %DO NOT USE ATM

totalN2 = length(xFiles12);
%trialInds = 1:totalN;
numRandInds = 3;

%load('highestPrecipInds1209');
%trialInds2 = highestPrecipInds(6:numRandInds);

%trialInds2 = sort(unique(floor(rand(1,numRandInds)*totalN2)));
%in order of perceived goodness of pred
%trialInds2 = [325 1114 1152 204 284 1196 1199];
%trialInds2 = [1196]
trialInds2 = [698] ; %for Sep 2011 training

[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles(trialInds2,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11);

%edge_params = {{'const'},{'pairtypes'}};
%[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
%    obtainDataFromFiles2(trialInds2,...
%    xFiles12,yFiles12,ccsFiles12,xOneFiles12,edge_params);


cutoff = 0.85;
%%

figure
for i = 1:10
    subplot(2,5,i);
    imagesc(labels_test{i}); colorbar;
end
%%
fprintf('get the marginals for test images...\n');
close all
E = zeros(1,length(feats_test));
T = zeros(1,length(feats_test));
Base = zeros(1,length(feats_test));
CCS = zeros(1,length(feats_test));
biArrays = cell(1,length(feats_test));
for n=1:length(feats_test)
    [b_i b_ij] = eval_crf(p,feats_test{n},efeats_test{n},models_test{n},loss_spec,crf_type,rho);
    %[b_i b_ij] = eval_crf(p,feats_test{n},[],models_test{n},loss_spec,crf_type,rho);
    
    %bi2 = (p.F)*feats_test{n}';
    
    biArrays{n} = b_i;
    
    curTargetLabels = labels_test{n};
    testPixels = find(curTargetLabels>1);
    comparisonLabels = labels_test{n}(testPixels);
    
    cutoffUse = length(find(curTargetLabels(testPixels)==2))/numel(testPixels);
    %cutoffUse
    fprintf('Stats for Time %f\n',n);
    
    ccsResults = ccsLabels{n}(testPixels);
    CCS(n) = sum( ccsResults~=comparisonLabels);
    fprintf('CCS Pred Error: %f \n\n',CCS(n)/T(n));
    
    %SHOW THESE RESULTS. MAKE MULTIPLE SLIDES
    for cutoff = 0.85%0.4:0.05:0.95
        
        x_pred = getPredLabels(b_i,cutoff,sizr,sizc);
        
        %samples from the distribution
        %x_pred = getPredLabelsRand(b_i,sizr,sizc,testPixels);

        xpredResults = x_pred(testPixels);
        

        E(n) = sum( xpredResults~=comparisonLabels);
        Base(n) = sum( ones(size(comparisonLabels)).*2~=comparisonLabels);
        T(n) = numel(testPixels);

        
        fprintf('Current Cutoff: %f\n',cutoff);
        fprintf('Current pixelwise error: %f \n',E(n)/T(n));
        

        precipPixels = find(curTargetLabels==3);
        fprintf('Percent Pred Pixels Correct %f\n\n',...
            length(find(x_pred(precipPixels)==3))/numel(precipPixels));
        fprintf('Baseline error (predict all 0): %f \n',Base(n)/T(n));
        displayTargetPred(x_pred,curTargetLabels);
    end
    
    

    
    %displayTargetPred(x_pred,curTargetLabels);
    
    %{
    subplot(1,3,2)
    imagesc(precipImages_test{n});
    colormap([1 1 1;0.8 0.8 0.8;jet(20)])
    caxis([-1 20]) 
    drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
    colorbar('vertical')
    %}
    
    
end
fprintf('total pixelwise error on test data: %f \n', sum(E)/sum(T))
fprintf('baseline error: %f \n',sum(Base)/sum(T))
fprintf('CCS error: %f \n',sum(CCS)/sum(T))
%%

%TODO: MORE PROBABILISTIC TESTS HERE
%SHOW AVERAGE PROBABILITY OF CLASS 2 AND 3 AMONG THOSE PIXELS
aucInfo = zeros(1,length(feats_test));
%priors = [1;0.02;10];
for numToSee = 1:7
    biCur = biArrays{numToSee};
    
    %multiply by prior, then normalize. 
    %TODO: ***DID NOT WORK, LOOK INTO BETTER WAYS***
    %biCur = biCur./repmat(priors,1,size(biCur,2));
    %biCur = biCur./repmat(sum(biCur,1),3,1);
    
    realLabels = labels_test{numToSee};

    labelsCur = realLabels(:);
    [~,labelsTest] = max(biCur,[],1);

    Cpixels = find(realLabels==1);
    Epixels = find(realLabels==2);
    Fpixels = find(realLabels==3);
    
    fprintf(strcat('Stats for Num ',num2str(numToSee),'\n'));
    fprintf(strcat('|E| = ',num2str(numel(Epixels)),'\n'));
    fprintf(strcat('|F| = ',num2str(numel(Fpixels)),'\n'));
    
    percentagePrecip = numel(Fpixels)/(numel(Fpixels)+numel(Epixels));
    fprintf(strcat('|E|/|EuF| = ',num2str(percentagePrecip),'\n'));

    if(numel(Fpixels)<1)
       continue 
    end
    probOfData = zeros(1,3);
    probOfLabelSets = zeros(1,3);
    probOfTargetLabel = zeros(1,3);
    totalTargetProb = zeros(1,3);
    totalProb2 = zeros(1,3);
    totalProb3 = zeros(1,3);
    numInSet = zeros(1,3);
    expectedValues = zeros(1,3); %expected state value in set
    totalExpValues = zeros(1,3);
    for i = 1:3
        curInds = find(realLabels==i);
        numInSet(i) = numel(curInds);
        for j = 1:length(curInds)
            currentIndex = curInds(j);
           mm = labelsTest(currentIndex);

           curElementProb = biCur(mm,currentIndex);
           curTargetProb = biCur(i,currentIndex);
           
           biCurMod = biCur(2:3,currentIndex)./(sum(biCur(2:3,currentIndex)));
           currentExpValue = sum(biCurMod.*[2;3]);
           
           expectedValues(i) = expectedValues(i) + currentExpValue;
            totalExpValues(i) = totalExpValues(i) + currentExpValue;
           
           probOfData(i) = probOfData(i) + curElementProb;
           probOfLabelSets(i) = probOfLabelSets(i) + curElementProb; %does not really tell us much
           
           probOfTargetLabel(i) = probOfTargetLabel(i) + curTargetProb; %REPORT THIS*****
           totalTargetProb(i) = totalTargetProb(i) + curTargetProb;
           
           totalProb2(i) = totalProb2(i) + biCurMod(1);
           totalProb3(i) = totalProb3(i) + biCurMod(2);
        end
        probOfLabelSets(i) = probOfLabelSets(i)/numel(curInds);
        probOfTargetLabel(i) = probOfTargetLabel(i)/numel(curInds);
        expectedValues(i) = expectedValues(i)/numel(curInds);
    end
    
    avgProb = sum(probOfData)/size(biCur,2);
    avgProb23 = sum(probOfData(2:3))/(numInSet(2)+numInSet(3));
    
    avgTargetProb23 = sum(totalTargetProb(2:3))/(numInSet(2)+numInSet(3));
    
    impPixels = find(realLabels>1);
    sumProbs = sum(biCur(2:3,impPixels));
    
    %GETS TRUE AND FALSE POSITIVE
    scores = biCur(3,impPixels)./sumProbs;
    [rocx,rocy,rocThr,rocAuc] = perfcurve(realLabels(impPixels),scores,3);
    [probDet,falseAlarm,thr,auc] = perfcurve(realLabels(impPixels),scores,3,'XCrit','accu','YCrit','fpr');
    
    %GETS TRUE AND FALSE NEGATIVE
    %scores = biCur(2,impPixels)./sumProbs;
    %[rocx,rocy,rocThr,rocAuc] = perfcurve(realLabels(impPixels),scores,2);
    
    fprintf(strcat('ROC AUC = ',num2str(rocAuc),'\n\n'));
    aucInfo(numToSee)=rocAuc;
    
    ccsResults = ccsLabels{n}(impPixels);
    [ccsROCxx,ccsROCyy] = perfcurve(realLabels(impPixels),ccsResults,3);
    ccsVals = ccsYvalues{n}(impPixels);
    ccsVals(ccsVals<0)=0;
    [ccsROCx,ccsROCy,ccsROCThr] = perfcurve(realLabels(impPixels),ccsVals,3);
    [probDetCCS,falseAlarmCCS,thrCCS,aucCCS] = perfcurve(realLabels(impPixels),ccsVals,3,'XCrit','accu','YCrit','fpr');
    
    
    figure
    
    subplot(1,2,1);
    hold on
    %title(strcat('ROC curve for ',num2str(numToSee)));
    title('ROC curves');
    plot(rocx,rocy,'r-');
    plot(ccsROCx,ccsROCy,'k-');
    plot(ccsROCxx(2),ccsROCyy(2),'kx','LineWidth',2);
    plot(0:0.05:1,0:0.05:1,'b--');
    xlabel('False Positive Rate');
    ylabel('True Positive Rate');
    legend('CRF ROC curve','CCS ROC Curve','CCS ROC if threshold==1','Baseline ROC');
    hold off
    
    subplot(1,2,2);
    hold on
    %title(strcat('True Positive Rate versus Threshold ',num2str(numToSee)));
    title('Threshold versus Error Rates for CRF model');
    plot(rocThr,rocy,'r-');
    plot(rocThr,rocx,'b-');
    plot(thr,probDet,'k-');
    legend('True Positive','False Positive','Accuracy');
    xlabel('Score Threshold for Class 3');
    ylabel('Rate');
    hold off
    %{
    figure
    
    hold on
    %title(strcat('True Positive Rate versus Threshold ',num2str(numToSee)));
    title('Threshold versus Error Rates for CCS model');
    plot(ccsROCThr,ccsROCx,'r-');
    plot(ccsROCThr,ccsROCy,'b-');
    plot(thrCCS,probDetCCS,'k-');
    legend('True Positive','False Positive','Accuracy');
    xlabel('Score Threshold for Class 3');
    ylabel('Rate');
    hold off
    %}
    
    pause(1);
    drawnow
    
    desiredTruePositive = 0.7;
    ind = find(rocy>desiredTruePositive,1,'first');
    thresholdUse = rocThr(ind);
end
%%

%NOTE: NEARLY ALL MAPS HAVE AUC > 0.5, AS SHOWN IN THE PLOT
%   PRESENT THIS RESULT AT NEXT MEETING WITH IHLER
load('domkeRun19_auc.mat')
%plot(aucInfo)
%plot(sort(aucInfo))
aucInfo2 = aucInfo(aucInfo>0);
plot(sort(aucInfo2))
xlabel('Map Number (ordered by AUC)');
ylabel('AUC');
%%

%TODO: SHOW THE FIGURES PRODUCED HERE TO IHLER

numToSee = 1;
biCur = biArrays{numToSee};
normFactors23 = sum(biCur(2:3,:));

%IF DOING UNNORMALIZED BY CLASS 1 PROBS
bi1re=reshape(biCur(1,:),sizr,sizc);
bi2re=reshape(biCur(2,:),sizr,sizc);
bi3re=reshape(biCur(3,:),sizr,sizc);

%IF DOING NORMALIZATION BY CLASS 1 PROBS
%bi1re=reshape(biCur(1,:)./normFactors23,sizr,sizc);
%bi2re=reshape(biCur(2,:)./normFactors23,sizr,sizc);
%bi3re=reshape(biCur(3,:)./normFactors23,sizr,sizc);

figure
subplot(1,2,1);
imagesc(labels_test{numToSee}); colorbar;
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
axis off

subplot(1,2,2);
imagesc(bi3re); colorbar;
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
axis off

figure
imagesc(labels_test{numToSee}); colorbar;
title('Labels');
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')

figure
%subplot(1,3,1);
%imagesc(bi1re); colorbar;
%title('Probability of Label 1');
%drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')

subplot(1,2,1);
imagesc(bi2re); colorbar;
title('Probability of Label 2');
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')

subplot(1,2,2);
imagesc(bi3re); colorbar;
title('Probability of Label 3');
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')

indsGset = find(labels_test{numToSee}==1);
bi1OnlyG = zeros(sizr,sizc);
bi1OnlyG(indsGset)=bi1re(indsGset);
figure
%subplot(1,3,1);
%imagesc(bi1OnlyG); colorbar;
%title('Probability of Label 1 among only those pixels');
%drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')

indsEset = find(labels_test{numToSee}==2);
bi2OnlyE = zeros(sizr,sizc);
bi2OnlyE(indsEset)=bi2re(indsEset);
bi3OnlyE = zeros(sizr,sizc);
bi3OnlyE(indsEset)=bi3re(indsEset);
subplot(1,2,1);
imagesc(bi2OnlyE); colorbar;
%imagesc(bi3OnlyE); colorbar;
title('P(y_i = 2 | y_i \neq 1) for i \in E, 0 otherwise');
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')

indsFset = find(labels_test{numToSee}==3);
bi3OnlyF = zeros(sizr,sizc);
bi3OnlyF(indsFset)=bi3re(indsFset);
bi2OnlyF = zeros(sizr,sizc);
bi2OnlyF(indsFset)=bi2re(indsFset);
subplot(1,2,2);
imagesc(bi2OnlyF); colorbar;
title('P(y_i = 2 | y_i \neq 1) for i \in F, 0 otherwise');
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')



%%

b2v2 = [];
b3v2 = [];
b2v3 = [];
b3v3 = [];

figure
hold on

ii = 1;
legendArray = cell(1,6);
%for numToIncl=[1 3 5 10]
for indToIncl=[1 2 4 6 8 10]
    
    allCloudLabels = [];
    allCloudScores = [];
    %for n = 1:numToIncl
    for n = indToIncl
        curTargetLabels = labels_test{n};
        cloudPixels = find(curTargetLabels>1);
        allCloudLabels = [allCloudLabels curTargetLabels(cloudPixels)'];

        biCur = biArrays{n};
        allCloudScores = [allCloudScores biCur(3,cloudPixels)];
        
        legendArray{ii} = num2str(n);
        ii = ii+1;
    end

    [rocx,rocy] = perfcurve(allCloudLabels,allCloudScores,3);
    plot(rocx,rocy);
    xlabel('False positive rate')
    ylabel('True positive rate')

end
legend(legendArray);
hold off



%{
b2v2 = [];
b3v2 = [];
b2v3 = [];
b3v3 = [];
for n = 1:length(labels_test)
    curTargetLabels = labels_test{n};
    v2=find(curTargetLabels==2);
    v3=find(curTargetLabels==3);
    biCur = biArrays{n};
    b2v2 = [b2v2 biCur(2,v2)];
    b3v2 = [b3v2 biCur(3,v2)];
    b2v3 = [b2v3 biCur(2,v3)];
    b3v3 = [b3v3 biCur(3,v3)];
end


[nb2V2,binPos2v] = hist(b2v2,100);
[nb3V2,binPos2] = hist(b3v2,100);
[nb2V3,binPos3v] = hist(b2v3,100);
[nb3V3,binPos3] = hist(b3v3,100);
figure
hold on
plot(binPos2v,nb2V2./sum(nb2V2),'r--');
plot(binPos2,nb3V2./sum(nb3V2),'r-');
plot(binPos3v,nb2V3./sum(nb2V3),'b--');
plot(binPos3,nb3V3./sum(nb3V3),'b-');
title('Histogram of Probability Values');
xlabel('Probability');
ylabel('Ratio of Elements with Value');
legend('p(y_i=2) for i \in E','p(y_i=3) for i \in E',...
    'p(y_i=2) for i \in F','p(y_i=3) for i \in F');
hold off
%}
%}
%%


xx1 = feats_test{1}(1,:);
xx2 = feats_test{1}(2,:);
xy1 = efeats_test{n}(1,:);

pot1 = exp(p.F*xx1');
pot2 = exp(p.F*xx2');
pot12 = exp(p.G*xy1');

pot12Matrix = reshape(pot12,3,3);

newMatrix = zeros(3,3);
for j = 1:3
   for k = 1:3
      newMatrix(j,k)=pot12Matrix(j,k)*pot1(j)*pot2(k); 
   end
end

newBij = newMatrix(:);
newBij = newBij./sum(newBij);
