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

%em with back TRW
%load('domkeCRFrun_3edgeFeats_emTRW','p');
%load('domkeCRFrun_3edgeFeats_emMNF','p');

totalN2 = length(xFiles12);
%trialInds = 1:totalN;
numRandInds = 10;

%load('highestPrecipInds1209');
%trialInds2 = highestPrecipInds(1:numRandInds);
%trialInds2 = sort(unique(floor(rand(1,numRandInds)*totalN2)));
%load('ROCvars_sep2012_3edgeFeats_cliqueLoss_testInds_new2.mat','trialInds2');

load('domkeCRFrun_3edgeFeats_cliqueLoss_new3.mat','trainingInds');
trialInds2 = trainingInds;

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

patchCoordsTrain = cell(1,N);

for n = 1:N
    fprintf(strcat('Loading data for time ',num2str(n),' of ',num2str(N),'\n'));
    fileI = trialInds2(n);
    load(strcat('projectData/',xFiles11(fileI).name))
    load(strcat('projectData/',yFiles11(fileI).name))
    load(strcat('projectData/',segFiles11(fileI).name));
    load(strcat('projectData/',ccsFiles11(fileI).name))
    load(strcat('projectData/',xOneFiles11(fileI).name))
    
    %blurs the image, then finds the nonzero pixels
    %this way nearby cloud patches blur together
    blurredSeg = conv2(double(seg),ones(filtSize,filtSize),'same');
    components = bwconncomp(blurredSeg>0);
    
    cornerR = [];
    cornerC = [];
    sizR = [];
    sizC = [];
    
    innerPatchInd = 0;
    patchCoordsTrain{n} = cell(1,length(components.PixelIdxList));
    
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
            patchCoordsTrain{n}{innerPatchInd} = [minR maxR minC maxC];
            

            x{patchInd} = xdata(minR:maxR,minC:maxC,:);
            y{patchInd} = ytarget(minR:maxR,minC:maxC);
            noCloudIndices{patchInd} = find(x{patchInd}(:,:,1)<=0);
            ccsY{patchInd} = ccspred(minR:maxR,minC:maxC);
            x{patchInd}(:,:,1)=xone(minR:maxR,minC:maxC);

            patchInd = patchInd+1;
        end
    end
    
    patchCoordsTrain{n} = patchCoordsTrain{n}(1:innerPatchInd);
    
    %{
    figure
    subplot(1,2,1)
    CURRENT_drawRegionPatches(seg,cornerR,cornerC,sizR,sizC);
    subplot(1,2,2)
    CURRENT_drawRegionPatches(ytarget,cornerR,cornerC,sizR,sizC);
    pause(1);
    drawnow;
    %}
    
end

save('ROCvars_sep2011_patchPred_new3_trainingInds_patchData.mat',...
    'patchCoordsTrain','trainingInds');



