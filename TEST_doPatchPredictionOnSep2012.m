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
segFiles11 = dir('projectData/seg1109*');

yFiles12 = dir('projectData/ytarget1209*');
xFiles12 = dir('projectData/xdata1209*');
ccsFiles12 = dir('projectData/ccspred1209*');
xOneFiles12 = dir('projectData/xone1209*');
segFiles12 = dir('projectData/seg1209*');

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

%original clique loss
%load('domkeCRFrun_3edgeFeats','p');
load('domkeCRFrun_3edgeFeats_cliqueLoss_new','p');

%em with back TRW
%load('domkeCRFrun_3edgeFeats_emTRW','p');
%load('domkeCRFrun_3edgeFeats_emMNF','p');

totalN2 = length(xFiles12);
%trialInds = 1:totalN;
numRandInds = 5;

%load('highestPrecipInds1209');
%trialInds2 = highestPrecipInds(1:numRandInds);
trialInds2 = sort(unique(floor(rand(1,numRandInds)*totalN2)));

%[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
%    obtainDataFromFiles3(trialInds2,...
%    xFiles12,yFiles12,ccsFiles12,xOneFiles12);

N = length(trialInds2);
NN2 = N*40;
x = cell(1,NN2);
y = cell(1,NN2);
ccsY = cell(1,NN2);
noCloudIndices = cell(1,NN2);
segNums = cell(1,NN2);
patchInd = 1;

for n = 1:N
    fprintf(strcat('Loading data for time ',num2str(n),' of ',num2str(N),'\n'));
    fileI = trialInds2(n);
    load(strcat('projectData/',xFiles12(fileI).name))
    load(strcat('projectData/',yFiles12(fileI).name))
    load(strcat('projectData/',segFiles12(fileI).name));
    load(strcat('projectData/',ccsFiles12(fileI).name))
    load(strcat('projectData/',xOneFiles12(fileI).name))
    
    for cloudNum = 1:max(seg(:))
        isCloud = double(seg==cloudNum);
        vertCols = sum(isCloud,1);
        horzCols = sum(isCloud,2);
        minR = find(horzCols>0, 1 ,'first');
        maxR = find(horzCols>0, 1, 'last');
        minC = find(vertCols>0, 1, 'first');
        maxC = find(vertCols>0, 1, 'last');
        
        x{patchInd} = xdata(minR:maxR,minC:maxC,:);
        y{patchInd} = ytarget(minR:maxR,minC:maxC);
        noCloudIndices{patchInd} = find(x{patchInd}(:,:,1)<=0);
        ccsY{patchInd} = ccspred(minR:maxR,minC:maxC);
        x{patchInd}(:,:,1)=xone(minR:maxR,minC:maxC);
        
        patchInd = patchInd+1;
    end
    
    
    %x{n} = xdata;
    %y{n} = ytarget;
    %segNums{n} = seg;
    %noCloudIndices{n} = find(x{n}(:,:,1)<=0);
    %ccsY{n} = ccspred;
    %x{n}(:,:,1)=xone;
    
end

lastInd = patchInd-1;
x = x(1:lastInd);
y = y(1:lastInd);
noCloudIndices = noCloudIndices(1:lastInd);
ccsY = ccsY(1:lastInd);
%%



%[highestAmounts,highestPrecipInds] = sort(curSum,'descend');


feats = cell(lastInd,1);
labels = cell(lastInd,1);
models = cell(lastInd,1);
precipImages = cell(lastInd,1);
ccsLabels = cell(lastInd,1);

for n = 1:lastInd
    fprintf(strcat('Making data for patch ',num2str(n),' of ',num2str(lastInd),'\n'));
    
    [sizr,sizc] = size(y{n});
    feats{n} = reshape(x{n},sizr*sizc,13);
    
    tempCol = zeros(sizr*sizc,1);
    tempCol(noCloudIndices{n})=1;
    feats{n} = [feats{n} ones(sizr*sizc,1) tempCol];
    
    imageY = y{n};
    
    noRainfallReadInds = find(imageY<0);
    noLabelInds = union(noRainfallReadInds,noCloudIndices{n});
    
    imageY(imageY<0)=0;
    precipImages{n} = imageY;
    
    ccsLabels{n} = getLabelsFromY(ccsY{n},noLabelInds);
    labels{n} = getLabelsFromY(y{n},noLabelInds);
    models{n} = gridmodel(sizr,sizc,3);
    
    
end

fprintf('computing edge features...\n')
efeats = cell(lastInd,1);
for n=1:lastInd
    efeats{n} = edgeify_im3(x{n}(:,:,1),models{n}.pairs);
end

%%
seg = segNums{2};
%imagesc(seg); colorbar;

cloud1 = double(seg==1);
imagesc(cloud1);
vertCols = sum(cloud1,1);
horzCols = sum(cloud1,2);
minR = find(horzCols>0, 1 ,'first');
maxR = find(horzCols>0, 1, 'last');
minC = find(vertCols>0, 1, 'first');
maxC = find(vertCols>0, 1, 'last');

imagesc(cloud1(minR:maxR,minC:maxC));
%%
fprintf('get the marginals for test images...\n');
close all
E = zeros(1,length(feats));
T = zeros(1,length(feats));
Base = zeros(1,length(feats));
CCS = zeros(1,length(feats));
biArrays = cell(1,length(feats));
for n=1:length(feats)
    [b_i b_ij] = eval_crf(p,feats{n},efeats{n},models{n},loss_spec,crf_type,rho);

    
    biArrays{n} = b_i;
    
    
end



allCloudLabels = [];
allCloudScores = [];

for n = 1:length(trialInds2)
    curTargetLabels = labels{n};
    cloudPixels = find(curTargetLabels>1);
    allCloudLabels = [allCloudLabels curTargetLabels(cloudPixels)'];

    biCur = biArrays{n};
    allCloudScores = [allCloudScores biCur(3,cloudPixels)];

end
[rocx,rocy,rocThr,rocAuc] = perfcurve(allCloudLabels,allCloudScores,3);
[probDet,falseAlarm,thr,auc] = perfcurve(allCloudLabels,allCloudScores,3,'XCrit','accu','YCrit','fpr');
%%
save('ROCvars_sep2012_3edgeFeats_cliqueLoss_randInds_newP.mat',...
    'rocx','rocy','rocThr','rocAuc',...
    'probDet','falseAlarm','thr','auc','trialInds2');
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



