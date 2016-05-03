%NOTE: MUST UNZIP JGMT4.zip TO HERE BEFORE RUNNING THE CODE
%   THE FOLDER MUST THEN BE ADDED TO THE PATH


sizr = 500;
sizc = 750;
rho = 0.5;
nvals = 2;

%yFiles = dir('projectData/ytarget1109*');
%xFiles = dir('projectData/xdata1109*');
%ccsFiles = dir('projectData/ccspred1109*');

yFiles = dir('projectData/ytarget1209*');
xFiles = dir('projectData/xdata1209*');
ccsFiles = dir('projectData/ccspred1209*');

totalN = length(xFiles);
%trialInds = 1:totalN;
numRandInds = 4;
trialInds = sort(unique(floor(rand(1,numRandInds)*totalN)));
N = length(trialInds);
%feats{n}  = featurize_im(ims{n},feat_params);

%addpath(genpath('JustinsGraphicalModelsToolboxPublic'))


x = cell(1,N);
y = cell(1,N);

ccsY = cell(1,N);

for n = 1:N
    fprintf(strcat('Loading data for time ',num2str(n),' of ',num2str(N),'\n'));
    fileI = trialInds(n);
    load(strcat('projectData/',xFiles(fileI).name))
    x{n} = xdata;
    load(strcat('projectData/',yFiles(fileI).name))
    y{n} = ytarget;
    load(strcat('projectData/',ccsFiles(fileI).name))
    ccsY{n} = ccspred;
end


feats = cell(N,1);
labels = cell(N,1);
models = cell(N,1);
precipImages = cell(N,1);
ccsLabels = cell(N,1);

for n = 1:N
    curFeats = x{n};
    feats{n} = reshape(x{n},sizr*sizc,13);
    
    %TEST FEATURES
    tempFeat = feats{n}(:,1); 
    tempCol = zeros(sizr*sizc,1);
    tempCol(tempFeat<1)=1;
    feats{n} = [feats{n} ones(sizr*sizc,1) tempCol];
    
    imageY = y{n};
    imageY(imageY<0)=0;
    precipImages{n} = imageY;
    
    ccsLabels{n} = getLabelsFromY(ccsY{n},curFeats(:,:,1));
    labels{n} = getLabelsFromY(y{n},curFeats(:,:,1));
    models{n} = gridmodel(sizr,sizc,2);
    
    fprintf(strcat('Making data for time ',num2str(n),' of ',num2str(N),'\n'));
end

edge_params = {{'const'},{'diffthresh'},{'pairtypes'}};
%edge_params = {{'const'},{'pairtypes'}};
fprintf('computing edge features...\n')
efeats = cell(N,1);
for n=1:N
    %efeats{n} = edgeify_im(precipImages{n},edge_params,models{n}.pairs,models{n}.pairtype);
    efeats{n} = edgeify_im(x{n}(:,:,1),edge_params,models{n}.pairs,models{n}.pairtype);
end

loss_spec = 'trunc_cl_trwpll_5';

crf_type  = 'linear_linear';
%options.viz         = @viz;
options.print_times = 0; % since this is so slow, print stuff to screen
options.gradual     = 1; % use gradual fitting
options.maxiter     = 1000;
options.rho         = rho;
options.reg         = 1e-4;
options.opt_display = 0;
%%
fprintf('training the model (this is slow!)...\n')
p = train_crf(feats,efeats,labels,models,loss_spec,crf_type,options)
%p = train_crf(feats,[],labels,models,loss_spec,crf_type,options)

save('currentDomkeResults6','p')
%%


feats_test=feats;
efeats_test=efeats;
models_test=models;
labels_test=labels;
precipImages_test=precipImages;

load('currentDomkeResults6','p');
%load('domkeResults2','p');


fprintf('get the marginals for test images...\n');
close all
E = zeros(1,length(feats_test));
T = zeros(1,length(feats_test));
Base = zeros(1,length(feats_test));
CCS = zeros(1,length(feats_test));
for n=1:length(feats_test)
    [b_i b_ij] = eval_crf(p,feats_test{n},efeats_test{n},models_test{n},loss_spec,crf_type,rho);
    %[b_i b_ij] = eval_crf(p,feats_test{n},[],models_test{n},loss_spec,crf_type,rho);
    
    [~,x_pred] = max(b_i,[],1);
    x_pred = reshape(x_pred,sizr,sizc);

    % upsample predicted images to full resolution
    curTargetLabels = labels_test{n};
    %testPixels = find(curTargetLabels>1);
    testPixels = find(feats{n}(:,1)>0);
    ccsResults = ccsLabels{n}(testPixels);
    x_pred2 = x_pred';
    xpredResults = x_pred2(testPixels);
    comparisonLabels = labels_test{n}(testPixels);
    CCS(n) = sum( ccsResults~=comparisonLabels);
    E(n) = sum( xpredResults~=comparisonLabels);
    Base(n) = sum( ones(size(comparisonLabels))~=comparisonLabels);
    T(n) = numel(testPixels);
    
    fprintf('Stats for Time %f\n',n);
    fprintf('Current pixelwise error: %f \n',E(n)/T(n));
    fprintf('Baseline error (predict all 0): %f \n',Base(n)/T(n));
    fprintf('CCS Pred Error: %f \n\n',CCS(n)/T(n));

    
    x_predDisp = x_pred; 
    x_predDisp(x_pred<=1)=0;
    x_predDisp(x_pred>=2)=5;
    
    labelsDisp = curTargetLabels;
    labelsDisp(curTargetLabels<=1)=0;
    labelsDisp(labels_test{n}>=2)=5;
    
    figure
    subplot(1,2,1)
    imagesc(labelsDisp);
    title('Target Precipitation Image');
    colormap([1 1 1;0.8 0.8 0.8;jet(20)])
    caxis([-1 20]) 
    drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
    colorbar('vertical')
    
    subplot(1,2,2)
    imagesc(x_predDisp);
    title('Predicted Precipitation Image');
    colormap([1 1 1;0.8 0.8 0.8;jet(20)])
    caxis([-1 20]) 
    drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
    colorbar('vertical')
    drawnow
    
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
%}