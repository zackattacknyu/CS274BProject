%NOTE: MUST UNZIP JGMT4.zip TO HERE BEFORE RUNNING THE CODE
%   THE FOLDER MUST THEN BE ADDED TO THE PATH


sizr = 500;
sizc = 750;
rho = 0.5;
nvals = 2;

%addpath(genpath('JustinsGraphicalModelsToolboxPublic'))

yFiles11 = dir('projectData/ytarget1109*');
xFiles11 = dir('projectData/xdata1109*');
ccsFiles11 = dir('projectData/ccspred1109*');
xOneFiles11 = dir('projectData/xone1109*');

yFiles12 = dir('projectData/ytarget1209*');
xFiles12 = dir('projectData/xdata1209*');
ccsFiles12 = dir('projectData/ccspred1209*');
xOneFiles12 = dir('projectData/xone1209*');

loss_spec = 'trunc_cl_trwpll_5';
%loss_spec = 'trunc_uquad_trwpll_5';

crf_type  = 'linear_linear';
%options.viz         = @viz;
options.print_times = 0; % since this is so slow, print stuff to screen
options.gradual     = 1; % use gradual fitting
options.maxiter     = 1000;
options.rho         = rho;
options.reg         = 1e-4;
options.opt_display = 0;

%
load('domkeCRFrun19','p');
%load('currentDomkeResults19_mini'); %DISTRIBUTION IS NOT VERY BIMODAL
%load('currentDomkeResults19_mini_precipBound'); %DIST IS QUITE BIMODAL THIS WAY
%load('currentDomkeResults19_mini_precipBoundRand');
%load('currentDomkeResults17.mat','p'); %DO NOT USE ATM

totalN2 = length(xFiles12);
%trialInds = 1:totalN;
numRandInds = 150;

%load('highestPrecipInds1209');
%trialInds2 = highestPrecipInds(1:numRandInds);
trialInds2 = sort(unique(floor(rand(1,numRandInds)*totalN2)));

[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels] = ...
    obtainDataFromFiles(trialInds2,...
    xFiles12,yFiles12,ccsFiles12,xOneFiles12);

cutoff = 0.85;
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
    
    biArrays{n} = b_i;
    
    
end


%TODO: MORE PROBABILISTIC TESTS HERE
aucInfo = zeros(1,length(feats_test));
allLabels = [];
allScores = [];
for numToSee = 1:length(feats_test);
    biCur = biArrays{numToSee};
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
    probOfData = 0;
    probOfLabelSets = zeros(1,3);
    probOfTargetLabel = zeros(1,3);
    for i = 1:3
        curInds = find(realLabels==i);
        for j = 1:length(curInds)
            currentIndex = curInds(j);
           mm = labelsTest(currentIndex);

           curElementProb = biCur(mm,currentIndex);
           curTargetProb = biCur(i,currentIndex);
           
           biCurMod = biCur(2:3,currentIndex)./(sum(biCur(2:3,currentIndex)));
           currentExpValue = sum(biCurMod.*[2;3]);
           %expectedValues(i) = expectedValues(i) + currentExpValue;

           probOfData = probOfData + curElementProb;
           probOfLabelSets(i) = probOfLabelSets(i) + curElementProb; %does not really tell us much
           probOfTargetLabel(i) = probOfTargetLabel(i) + curTargetProb; %REPORT THIS*****
        end
        probOfLabelSets(i) = probOfLabelSets(i)/numel(curInds);
        probOfTargetLabel(i) = probOfTargetLabel(i)/numel(curInds);
    end
    avgProb = probOfData/size(biCur,2);

    impPixels = find(realLabels>1);
    [rocx,rocy,rocThr,rocAuc] = perfcurve(realLabels(impPixels),biCur(3,impPixels),3);
    fprintf(strcat('ROC AUC = ',num2str(rocAuc),'\n\n'));
    aucInfo(numToSee)=rocAuc;

    allLabels = [allLabels realLabels(impPixels)'];
    allScores = [allScores biCur(3,impPixels)];
end

[rocx,rocy,rocThr,rocAuc] = perfcurve(allLabels,allScores,3);

save('rocInfo_multipleMaps','rocx','rocy','rocThr','rocAuc');
%%
figure
hold on
%title(strcat('ROC curve for ',num2str(numToSee)));
title('ROC curve');
plot(rocx,rocy,'r-');
plot(0:0.05:1,0:0.05:1,'b--');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
hold off
pause(1);
drawnow
%%
figure
hold on
%title(strcat('True Positive Rate versus Threshold ',num2str(numToSee)));
title('Threshold versus True/False Positive Rate');
plot(rocThr,rocy,'r-');
plot(rocThr,rocx,'b-');
legend('True Positive','False Positive');
xlabel('Score Threshold for Class 3');
ylabel('Rate');
hold off
pause(1);
drawnow