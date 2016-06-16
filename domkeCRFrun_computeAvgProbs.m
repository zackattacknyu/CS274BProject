%NOTE: MUST UNZIP JGMT4.zip TO HERE BEFORE RUNNING THE CODE
%   THE FOLDER MUST THEN BE ADDED TO THE PATH
% The file can be downloaded from this webpage:
%       http://users.cecs.anu.edu.au/~jdomke/JGMT/


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

totalN = length(xFiles11);
numRandInds = 350;
trialInds = sort(unique(floor(rand(1,numRandInds)*totalN)));

loss_spec = 'trunc_cl_trwpll_5';
crf_type  = 'linear_linear';
options.print_times = 0; % since this is so slow, print stuff to screen
options.gradual     = 1; % use gradual fitting
options.maxiter     = 1000;
options.rho         = rho;
options.reg         = 1e-4;
options.opt_display = 0;


%%
[feats,efeats,labels,models,precipImages] = obtainDataFromFiles(trialInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11);

%TRAINING WAS KICKED OFF HERE
fprintf('training the model (this is slow!)...\n')
p = train_crf(feats,efeats,labels,models,loss_spec,crf_type,options)
%%

load('domkeCRFrun_3edgeFeats','p');
%REST OF CODE IS TESTS DONE AFTER PARAMETERS FOUND

%UNCOMMENT THIS BLOCK IF USING SEP 2011 MAPS
%{
trialInds = [698] ; 
[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles(trialInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11);
%}

%UNCOMMENT THIS BLOCK IF USING SEP 2012 MAPS
trialInds2 = [1114 1152 1196]; %for Sep 2012 map
[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles3(trialInds2,...
    xFiles12,yFiles12,ccsFiles12,xOneFiles12);

%PIXELWISE ERROR RATES COMPUTED HERE
fprintf('get the marginals for test images...\n');
close all
allProbsAmongRain = [];
allProbsAmongNoRain = [];
for n=1:length(feats_test)
    n
    [b_i b_ij] = eval_crf(p,feats_test{n},efeats_test{n},models_test{n},loss_spec,crf_type,rho);
    
    bi3re=reshape(b_i(3,:),sizr,sizc);
    curTargetLabels = labels_test{n};

    rainfallPixels = find(curTargetLabels==2);
    noRainPixels = find(curTargetLabels==3);
    
    probsAmongNoRain = bi3re(noRainPixels);
    probsAmongRain = bi3re(rainfallPixels);
    
    allProbsAmongRain = [allProbsAmongRain;probsAmongRain];
    allProbsAmongNoRain = [allProbsAmongNoRain;probsAmongNoRain];
    
end

avgProbAmongRainPixels = mean(allProbsAmongRain);
avgProbAmongNoRainPixels = mean(allProbsAmongNoRain);