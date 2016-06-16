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


[feats,efeats,labels,models,precipImages] = obtainDataFromFiles(trialInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11);

%TRAINING WAS KICKED OFF HERE
fprintf('training the model (this is slow!)...\n')
p = train_crf(feats,efeats,labels,models,loss_spec,crf_type,options)


%REST OF CODE IS TESTS DONE AFTER PARAMETERS FOUND

%UNCOMMENT THIS BLOCK IF USING SEP 2011 MAPS
trialInds = [698] ; 
[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles(trialInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11);

%UNCOMMENT THIS BLOCK IF USING SEP 2012 MAPS
%{
trialInds2 = [1196] %for Sep 2012 map
[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles(trialInds2,...
    xFiles12,yFiles12,ccsFiles12,xOneFiles12);
%}

%PIXELWISE ERROR RATES COMPUTED HERE
fprintf('get the marginals for test images...\n');
close all
E = zeros(1,length(feats_test));
T = zeros(1,length(feats_test));
Base = zeros(1,length(feats_test));
biArrays = cell(1,length(feats_test));
for n=1:length(feats_test)
    [b_i b_ij] = eval_crf(p,feats_test{n},efeats_test{n},models_test{n},loss_spec,crf_type,rho);
    biArrays{n} = b_i;
    
    curTargetLabels = labels_test{n};
    testPixels = find(curTargetLabels>1);
    comparisonLabels = labels_test{n}(testPixels);

    fprintf('Stats for Trial Number %d\n',n);

    Base(n) = sum( ones(size(comparisonLabels)).*2~=comparisonLabels);
    T(n) = numel(testPixels);
    fprintf('Baseline error (predict all 0): %f \n\n',Base(n)/T(n));
    
    %{
    Here is where different cutoffs were tried
    The probability of no rain among cloud pixels
        must be higher than this to predict no rain
    Otherwise, pixel is classified as having rain
    %}
    for cutoff = [0.8 0.9]
        
        x_pred = getPredLabels(b_i,cutoff,sizr,sizc);    
        xpredResults = x_pred(testPixels);
        

        E(n) = sum( xpredResults~=comparisonLabels);
        

        fprintf('With Cutoff: %f\n',cutoff);
        fprintf('Pixelwise error: %f \n',E(n)/T(n));
        precipPixels = find(curTargetLabels==3);
        fprintf('Percent Precip Pixels Correct %f\n\n',...
            length(find(x_pred(precipPixels)==3))/numel(precipPixels));
        
    end
    
    fprintf('\n');
    
end
fprintf('Cumulative Stats: \n');
fprintf('total pixelwise error on test data: %f \n', sum(E)/sum(T))
fprintf('total baseline error: %f \n',sum(Base)/sum(T));


numToSee=1;
biCur = biArrays{numToSee};
bi3re=reshape(biCur(3,:),sizr,sizc);

%PROBABILITY OF RAINFALL AND LABEL MAPS PRODUCED HERE
%   FIGURE 1 AND 2 IN THE PAPER
figure
subplot(1,2,1);
imagesc(labels_test{numToSee}); colorbar;
colormap jet;
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
axis off
subplot(1,2,2);
imagesc(bi3re); colorbar;
colormap jet;
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
axis off

%AVERAGE MARGINAL PROBS OF RAINFALL COMPUTED HERE
avgAmongNoRain = mean(bi3re(labels_test{numToSee}==2)) %among no rain pixels
avgAmongRain = mean(bi3re(labels_test{numToSee}==3)) %among rain pixels