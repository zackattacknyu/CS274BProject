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

totalN = length(xFiles11);
%trialInds = 1:totalN;
numRandInds = 160;
trialInds = sort(unique(floor(rand(1,numRandInds)*totalN)));

%load('highestPrecipInds1109');
%trialInds = highestPrecipInds(1:numRandInds);


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

%%
%feats{n}  = featurize_im(ims{n},feat_params);
[feats,efeats,labels,models,precipImages] = obtainDataFromFiles(trialInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11);

fprintf('training the model (this is slow!)...\n')
p = train_crf(feats,efeats,labels,models,loss_spec,crf_type,options)
%p = train_crf(feats,[],labels,models,loss_spec,crf_type,options)

save('domkeCRFrun18.mat','p');
%%
%
load('domkeCRFrun18','p');
%load('currentDomkeResults19_mini'); %DISTRIBUTION IS NOT VERY BIMODAL
%load('currentDomkeResults19_mini_precipBound'); %DIST IS QUITE BIMODAL THIS WAY
%load('currentDomkeResults19_mini_precipBoundRand');
%load('currentDomkeResults17.mat','p'); %DO NOT USE ATM

totalN2 = length(xFiles12);
%trialInds = 1:totalN;
numRandInds = 10;

load('highestPrecipInds1209');
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
        
        %x_pred = getPredLabels(b_i,cutoff,sizr,sizc);
        
        %samples from the distribution
        x_pred = getPredLabelsRand(b_i,sizr,sizc,testPixels);

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
numToSee = 2;
biCur = biArrays{numToSee};
realLabels = labels_test{numToSee};

labelsCur = realLabels(:);
[~,labelsTest] = max(biCur,[],1);

Cpixels = find(realLabels==1);
Epixels = find(realLabels==2);
Fpixels = find(realLabels==3);

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
       
       
       probOfData = probOfData + curElementProb;
       probOfLabelSets(i) = probOfLabelSets(i) + curElementProb;
       probOfTargetLabel(i) = probOfTargetLabel(i) + curTargetProb;
    end
    probOfLabelSets(i) = probOfLabelSets(i)/numel(curInds);
    probOfTargetLabel(i) = probOfTargetLabel(i)/numel(curInds);
end
avgProb = probOfData/size(biCur,2);




impPixels = find(realLabels>1);
[rocx,rocy] = perfcurve(realLabels(impPixels),biCur(3,impPixels),3);
figure
plot(rocx,rocy);

bi1re=reshape(biCur(1,:),sizr,sizc);
bi2re=reshape(biCur(2,:),sizr,sizc);
bi3re=reshape(biCur(3,:),sizr,sizc);
figure
imagesc(bi1re); colorbar;
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')

figure
imagesc(bi2re); colorbar;
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')

figure
imagesc(bi3re); colorbar;
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