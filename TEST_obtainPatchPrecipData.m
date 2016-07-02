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
numRandInds = 30;

%load('highestPrecipInds1209');
%trialInds2 = highestPrecipInds(1:numRandInds);
%trialInds2 = sort(unique(floor(rand(1,numRandInds)*totalN2)));
load('ROCvars_sep2012_3edgeFeats_cliqueLoss_testInds_new3.mat','trialInds2');
%trialInds2 = [524;583;587;601;1181]; %TEMP code

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

%DATA TO SEE IF THERE'S PATCH/PRECIP RELATIONSHIP
sizePatch = zeros(1,NN2);
totalPrecipPatch = zeros(1,NN2); %total precip in patch
avgPrecipPatch = zeros(1,NN2); %avg per pixel precip
totalNumPrecipPatch = zeros(1,NN2); %total number of precip pixels
percentagePrecipPatch = zeros(1,NN2); %percentage of pixels as precip


%TEST PARAMS FOR NO PRE-FILTER PATCHES
filtSize = 1;
minNumPixels = 1000; %min size to be considered patch

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
    ytarget(ytarget<0)=0;
    for cloudNum = 1:length(components.PixelIdxList)
        
        patchPixels = components.PixelIdxList{cloudNum};
        
        sizePatch(patchInd) = numel(patchPixels);
        
        precipInPatch = ytarget(patchPixels);
        
        totalPrecipPatch(patchInd) = sum(precipInPatch);
        avgPrecipPatch(patchInd) = totalPrecipPatch(patchInd)/sizePatch(patchInd); 
        totalNumPrecipPatch(patchInd) = sum(precipInPatch(:)>1); 
        percentagePrecipPatch(patchInd) = totalNumPrecipPatch(patchInd)/sizePatch(patchInd); 
        
        patchInd = patchInd+1;
    end

    %{
    figure
    subplot(1,2,1)
    CURRENT_drawRegionPatches(seg,cornerR,cornerC,sizR,sizC);
    title('Cloud Patch Labels');
    subplot(1,2,2)
    CURRENT_drawRegionPatches(ytarget,cornerR,cornerC,sizR,sizC);
    title('Target Precipitation Amounts');
    pause(1);
    drawnow;
    %}
    
end

lastInd = patchInd-1;
sizePatch = sizePatch(1:lastInd);
totalPrecipPatch = totalPrecipPatch(1:lastInd);
avgPrecipPatch = avgPrecipPatch(1:lastInd);
totalNumPrecipPatch = totalNumPrecipPatch(1:lastInd);
percentagePrecipPatch = percentagePrecipPatch(1:lastInd);

save('PrecipPatchData_sep2012.mat',...
    'sizePatch','totalPrecipPatch','avgPrecipPatch',...
    'totalNumPrecipPatch','percentagePrecipPatch');

%%

figure; 
plot(sizePatch,totalPrecipPatch,'r.')
title('Size vs Total Precipitation');
xlabel('Number of Pixels in Patch');
ylabel('Total Precipitation');

figure; 
plot(sizePatch,avgPrecipPatch,'r.')
title('Size vs Average Precipitation');
xlabel('Number of Pixels in Patch');
ylabel('Average Precipitation Per Pixel');

figure; 
plot(sizePatch,totalNumPrecipPatch,'r.')
title('Size vs Total Number of Precip Pixels');
xlabel('Number of Pixels in Patch');
ylabel('Number of Precip Pixels');

figure; 
plot(sizePatch,percentagePrecipPatch,'r.')
title('Size vs Percentage of Precip Pixels');
xlabel('Number of Pixels in Patch');
ylabel('Percentage of Precip Pixels');

%%

focusInds = find(sizePatch<5000);
figure
plot(sizePatch(focusInds),totalNumPrecipPatch(focusInds),'b.');

figure
plot(sizePatch(focusInds),totalPrecipPatch(focusInds),'r.');



