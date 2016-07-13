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


%load('domkeCRFrun_3edgeFeats_cliqueLoss_new3','p','validationInds');
load('ROCvars_sep2012_3edgeFeats_cliqueLoss_testInds_new3','trialInds2');

trialInds2 = trialInds2(1:4);

[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles3(trialInds2,...
    xFiles12,yFiles12,ccsFiles12,xOneFiles12);

XdataTest = [];
YdataTest = [];

for i = 1:length(feats_test)
    i
    XdataTest = [XdataTest;feats_test{i}];
    YdataTest = [YdataTest;floor(labels_test{i}(:))];
end

testPixels2 = find(YdataTest>1);

f3arrays = cell(1,13);
f2arrays = cell(1,13);
xi3arrays = cell(1,13);
xi2arrays = cell(1,13);

YY2 = YdataTest(testPixels2)-2;
precipInds = find(YY2>0.9);
noPrecipInds = find(YY2<0.1);

XXtemp = XdataTest(testPixels2,1);
tempValsPrecip = XXtemp(precipInds);
tempValsNoPrecip = XXtemp(noPrecipInds);

numPts = 32;
allTemps = [tempValsPrecip; tempValsNoPrecip];
minTemp = min(allTemps); maxTemp = max(allTemps);

precipDensNorm = cell(1,13);
noPrecipDensNorm = cell(1,13);

precipDensUnNorm = cell(1,13);
noPrecipDensUnNorm = cell(1,13);

for feat = 1:13
    XX2 = XdataTest(testPixels2,feat);
    featValsPrecip = XX2(precipInds);
    featValsNoPrecip = XX2(noPrecipInds);
    
    allFeats = [featValsPrecip; featValsNoPrecip];
    minFeat = min(allFeats); maxFeat = max(allFeats);
    
    matrixPrecip = [tempValsPrecip featValsPrecip];
    matrixNoPrecip = [tempValsNoPrecip featValsNoPrecip];
    
    [~,dens1] = kde2d(matrixPrecip,numPts,[minTemp,minFeat],[maxTemp,maxFeat]);
    [~,dens2] = kde2d(matrixNoPrecip,numPts,[minTemp,minFeat],[maxTemp,maxFeat]);
    
    precipDensNorm{feat} = dens1./sum(dens1(:));
    noPrecipDensNorm{feat} = dens2./sum(dens2(:));
    
    precipDensUnNorm{feat} = dens1;
    noPrecipDensUnNorm{feat} = dens2;

end
%%
save('KSdensity2dVars_sep2012_new3inds.mat','precipDensNorm',...
    'noPrecipDensNorm','precipDensUnNorm','noPrecipDensUnNorm');

%load('KSdensityVars_sep2012_new3inds')
%%
for feat = 1:13
   figure
   subplot(1,2,1)
   imagesc(precipDensNorm{feat}); 
   colormap jet;
   colorbar;
   
   subplot(1,2,2)
   imagesc(noPrecipDensNorm{feat});
   colormap jet;
   colorbar;
end
%%
for feat = 2:13
    displayData = [precipDensUnNorm{feat} noPrecipDensUnNorm{feat}];
    allDispData = displayData(:);
    clims = [min(allDispData) max(allDispData)];
    
   figure
   subplot(2,1,1)
   imagesc(precipDensUnNorm{feat},clims); 
   colormap jet;
   colorbar;
   axis off
   
   subplot(2,1,2)
   imagesc(noPrecipDensUnNorm{feat},clims);
   colormap jet;
   colorbar;
   axis off
end
