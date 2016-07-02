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
%load('domkeCRFrun_3edgeFeats_cliqueLoss_new2','p');
load('domkeCRFrun_3edgeFeats_cliqueLoss_new3_patchTrain','p');

%em with back TRW
%load('domkeCRFrun_3edgeFeats_emTRW','p');
%load('domkeCRFrun_3edgeFeats_emMNF','p');

totalN2 = length(xFiles12);
%trialInds = 1:totalN;
numRandInds = 3;

%load('highestPrecipInds1209');
%trialInds2 = highestPrecipInds(1:numRandInds);
%trialInds2 = sort(unique(floor(rand(1,numRandInds)*totalN2)));
load('ROCvars_sep2012_3edgeFeats_cliqueLoss_testInds_new3.mat','trialInds2');
trialInds2 = [524;583;587;601;1181]; %TEMP code

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
filtSize = 5;
minNumPixels = 2000; %min size to be considered patch

patchCoords = cell(1,N);

for n = 1:N
    fprintf(strcat('Loading data for time ',num2str(n),' of ',num2str(N),'\n'));
    fileI = trialInds2(n);
    load(strcat('projectData/',xFiles12(fileI).name))
    load(strcat('projectData/',yFiles12(fileI).name))
    load(strcat('projectData/',segFiles12(fileI).name));
    load(strcat('projectData/',ccsFiles12(fileI).name))
    load(strcat('projectData/',xOneFiles12(fileI).name))
    
    %blurs the image, then finds the nonzero pixels
    %this way nearby cloud patches blur together
    blurredSeg = conv2(double(seg),ones(filtSize,filtSize),'same');
    components = bwconncomp(blurredSeg>0);
    
    cornerR = [];
    cornerC = [];
    sizR = [];
    sizC = [];
    
    innerPatchInd = 0;
    patchCoords{n} = cell(1,length(components.PixelIdxList));
    
    for cloudNum = 1:length(components.PixelIdxList)
        isCloud = zeros(size(seg));
        isCloud(components.PixelIdxList{cloudNum})=1;
        
        if(sum(isCloud(:)) > minNumPixels)
            vertCols = sum(isCloud,1);
            horzCols = sum(isCloud,2);
            minR = find(horzCols>0, 1 ,'first');
            maxR = find(horzCols>0, 1, 'last');
            minC = find(vertCols>0, 1, 'first');
            maxC = find(vertCols>0, 1, 'last');
            
            cornerR = [cornerR;minR];
            cornerC = [cornerC;minC];
            sizR = [sizR;(maxR-minR)];
            sizC = [sizC;(maxC-minC)];
            
            innerPatchInd = innerPatchInd+1;
            patchCoords{n}{innerPatchInd} = [minR maxR minC maxC];
            
            x{patchInd} = xdata(minR:maxR,minC:maxC,:);
            y{patchInd} = ytarget(minR:maxR,minC:maxC);
            noCloudIndices{patchInd} = find(x{patchInd}(:,:,1)<=0);
            ccsY{patchInd} = ccspred(minR:maxR,minC:maxC);
            x{patchInd}(:,:,1)=xone(minR:maxR,minC:maxC);

            patchInd = patchInd+1;
        end
    end
    patchCoords{n} = patchCoords{n}(1:innerPatchInd);
    
    figure
    subplot(1,2,1)
    CURRENT_drawRegionPatches(seg,cornerR,cornerC,sizR,sizC);
    title('Cloud Patch Labels');
    subplot(1,2,2)
    CURRENT_drawRegionPatches(ytarget,cornerR,cornerC,sizR,sizC);
    title('Target Precipitation Amounts');
    pause(1);
    drawnow;
    
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
    %{
    if(rand<0.3)
       figure;
       imagesc(labels{n}); 
       colormap(jet)
       colorbar;
    end
    %}
end

fprintf('computing edge features...\n')
efeats = cell(lastInd,1);
for n=1:lastInd
    efeats{n} = edgeify_im3(x{n}(:,:,1),models{n}.pairs);
end

%%
fprintf('get the marginals for test images...\n');
close all
E = zeros(1,length(feats));
T = zeros(1,length(feats));
Base = zeros(1,length(feats));
CCS = zeros(1,length(feats));
biArrays = cell(1,length(feats));
for n=1:length(feats)
    n
    [b_i b_ij] = eval_crf(p,feats{n},efeats{n},models{n},loss_spec,crf_type,rho);
    biArrays{n} = b_i;
end
%%

curPatchInd = 1;
for n = 1:N
   curProb3wholeMap = zeros(sizr,sizc);
   for nn = 1:length(patchCoords{n})
      coords = patchCoords{n}{nn};
      minR = coords(1); maxR = coords(2); 
      minC = coords(3); maxC = coords(4);
      
      curSizeR = maxR - minR + 1;
      curSizeC = maxC - minC + 1;
      
      biCur = biArrays{curPatchInd};
      curProb3wholeMap(minR:maxR,minC:maxC) = ...
          reshape(biCur(3,:),curSizeR,curSizeC);
      curPatchInd = curPatchInd+1;
   end
   figure
   imagesc(curProb3wholeMap); colorbar;
   
end


%%
allCloudLabels = [];
allCloudScores = [];

for nn = 1:length(labels)
    nn
    curTargetLabels = labels{nn};
    cloudPixels = find(curTargetLabels>1);
    allCloudLabels = [allCloudLabels curTargetLabels(cloudPixels)'];

    biCur = biArrays{nn};
    allCloudScores = [allCloudScores biCur(3,cloudPixels)];

end
[rocx,rocy,rocThr,rocAuc] = perfcurve(allCloudLabels,allCloudScores,3);
[probDet,falseAlarm,thr,auc] = perfcurve(allCloudLabels,allCloudScores,3,'XCrit','accu','YCrit','fpr');
%%
save('ROCvars_sep2012_new3PatchTrainP_testInds.mat',...
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



