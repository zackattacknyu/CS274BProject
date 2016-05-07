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
numRandInds = 5;
%trialInds = sort(unique(floor(rand(1,numRandInds)*totalN)));

load('highestPrecipInds1109');
trialInds = highestPrecipInds(1:numRandInds);


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
%%

load('currentDomkeResults17.mat','p');

totalN2 = length(xFiles12);
%trialInds = 1:totalN;
numRandInds = 25;

load('highestPrecipInds1209');
trialInds2 = highestPrecipInds(1:5:numRandInds);
%trialInds2 = sort(unique(floor(rand(1,numRandInds)*totalN2)));

[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels] = ...
    obtainDataFromFiles(trialInds2,...
    xFiles12,yFiles12,ccsFiles12,xOneFiles12);

cutoff = 0.85;

fprintf('get the marginals for test images...\n');
close all
E = zeros(1,length(feats_test));
T = zeros(1,length(feats_test));
Base = zeros(1,length(feats_test));
CCS = zeros(1,length(feats_test));
for n=1%:length(feats_test)
    [b_i b_ij] = eval_crf(p,feats_test{n},efeats_test{n},models_test{n},loss_spec,crf_type,rho);
    %[b_i b_ij] = eval_crf(p,feats_test{n},[],models_test{n},loss_spec,crf_type,rho);
    
    %bi2 = (p.F)*feats_test{n}';
    
    
    
    curTargetLabels = labels_test{n};
    testPixels = find(curTargetLabels>1);
    comparisonLabels = labels_test{n}(testPixels);
    
    cutoffUse = length(find(curTargetLabels(testPixels)==2))/numel(testPixels);
    %cutoffUse
    fprintf('Stats for Time %f\n',n);
    fprintf('Baseline error (predict all 0): %f \n',Base(n)/T(n));
    ccsResults = ccsLabels{n}(testPixels);
    CCS(n) = sum( ccsResults~=comparisonLabels);
    fprintf('CCS Pred Error: %f \n\n',CCS(n)/T(n));
    
    %SHOW THESE RESULTS. MAKE MULTIPLE SLIDES
    for cutoff = 0.5:0.05:0.95
        
        x_pred = getPredLabels(b_i,cutoff,sizr,sizc);

        xpredResults = x_pred(testPixels);
        

        E(n) = sum( xpredResults~=comparisonLabels);
        Base(n) = sum( ones(size(comparisonLabels)).*2~=comparisonLabels);
        T(n) = numel(testPixels);

        
        fprintf('Current Cutoff: %f\n',cutoff);
        fprintf('Current pixelwise error: %f \n',E(n)/T(n));
        

        precipPixels = find(curTargetLabels==3);
        fprintf('Percent Pred Pixels Correct %f\n\n',...
            length(find(x_pred(precipPixels)==3))/numel(precipPixels));
        
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


v2=find(curTargetLabels==2);
v3=find(curTargetLabels==3);
b2v2 = b_i(2,v2);
b3v2 = b_i(3,v2);
b2v3 = b_i(2,v3);
b3v3 = b_i(3,v3);

[nb2V2,binPos2v] = hist(b2v2,100);
[nb3V2,binPos2] = hist(b3v2,100);
[nb2V3,binPos3v] = hist(b2v3,100);
[nb3V3,binPos3] = hist(b3v3,100);
figure
hold on
plot(binPos2v,nb2V2,'r--');
plot(binPos2,nb3V2,'r-');
plot(binPos3v,nb2V3,'b--');
plot(binPos3,nb3V3,'b-');
legend('Prob Label=2 among Label 2 Nodes','Prob Label=3 among Label 2 Nodes',...
    'Prob Label=2 among Label 3 Nodes','Prob Label=3 among Label 3 Nodes');
hold off

