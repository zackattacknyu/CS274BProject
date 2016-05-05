%NOTE: MUST UNZIP JGMT4.zip TO HERE BEFORE RUNNING THE CODE
%   THE FOLDER MUST THEN BE ADDED TO THE PATH


sizr = 500;
sizc = 750;
rho = 0.5;
nvals = 2;

yFiles = dir('projectData/ytarget1109*');
xFiles = dir('projectData/xdata1109*');
ccsFiles = dir('projectData/ccspred1109*');

%yFiles = dir('projectData/ytarget1209*');
%xFiles = dir('projectData/xdata1209*');
%ccsFiles = dir('projectData/ccspred1209*');

totalN = length(xFiles);
%trialInds = 1:totalN;
numRandInds = 200;
trialInds = sort(unique(floor(rand(1,numRandInds)*totalN)));

%load('highestPrecipInds1109');
%trialInds = highestPrecipInds(1:numRandInds);

N = length(trialInds);
%feats{n}  = featurize_im(ims{n},feat_params);

%addpath(genpath('JustinsGraphicalModelsToolboxPublic'))


x = cell(1,N);
y = cell(1,N);

ccsY = cell(1,N);
curSum = zeros(1,N);

for n = 1:N
    fprintf(strcat('Loading data for time ',num2str(n),' of ',num2str(N),'\n'));
    fileI = trialInds(n);
    load(strcat('projectData/',xFiles(fileI).name))
    x{n} = xdata;
    load(strcat('projectData/',yFiles(fileI).name))
    y{n} = ytarget;
    %{
    yBin = ytarget;
    yBin(ytarget<1)=0;
    yBin(ytarget>=1)=1;
    curSum(n) = sum(yBin(:));
    %}
    load(strcat('projectData/',ccsFiles(fileI).name))
    ccsY{n} = ccspred;
end


%[highestAmounts,highestPrecipInds] = sort(curSum,'descend');


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
    models{n} = gridmodel(sizr,sizc,3);
    
    fprintf(strcat('Making data for time ',num2str(n),' of ',num2str(N),'\n'));
end

edge_params = {{'const'},{'diffthresh'},{'pairtypes'}};
%edge_params = {{'const'},{'pairtypes'}};
fprintf('computing edge features...\n')
efeats = cell(N,1);
for n=1:N
    %efeats{n} = edgeify_im(precipImages{n},edge_params,models{n}.pairs,models{n}.pairtype);
    
    %with attempt 15
    %efeats{n} = edgeify_im(double(~(x{n}(:,:,1)>1)),edge_params,models{n}.pairs,models{n}.pairtype);
    
    %with attempt 16
    tempMap = x{n}(:,:,1);
    tempMap(tempMap<1) = min(tempMap(tempMap>0));
    efeats{n} = edgeify_im(tempMap,edge_params,models{n}.pairs,models{n}.pairtype);
end

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
fprintf('training the model (this is slow!)...\n')
p = train_crf(feats,efeats,labels,models,loss_spec,crf_type,options)
%p = train_crf(feats,[],labels,models,loss_spec,crf_type,options)

save('currentDomkeResults16_largeTrain','p')

%%



%{
feats_test=feats;
efeats_test=efeats;
models_test=models;
labels_test=labels;
precipImages_test=precipImages;

load('currentDomkeResults16','p');
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
    
    %bi2 = (p.F)*feats_test{n}';
    
    [~,x_predInit] = max(b_i,[],1);
    
    for i = 1:length(x_predInit)
       if(x_predInit(i)>1)
          if(b_i(2,i)<0.83)
              x_predInit(i)=3;
          else
              x_predInit(i)=2;
          end
       end
    end
    
    %[~,x_pred] = max(bi2,[],1);
    x_pred = reshape(x_predInit,sizr,sizc);

    % upsample predicted images to full resolution
    curTargetLabels = labels_test{n};
    %testPixels = find(curTargetLabels>1);
    testPixels = find(feats{n}(:,1)>0);
    ccsResults = ccsLabels{n}(testPixels);
    xpredResults = x_pred(testPixels);
    comparisonLabels = labels_test{n}(testPixels);
    CCS(n) = sum( ccsResults~=comparisonLabels);
    E(n) = sum( xpredResults~=comparisonLabels);
    Base(n) = sum( ones(size(comparisonLabels)).*2~=comparisonLabels);
    T(n) = numel(testPixels);
    
    fprintf('Stats for Time %f\n',n);
    fprintf('Current pixelwise error: %f \n',E(n)/T(n));
    fprintf('Baseline error (predict all 0): %f \n',Base(n)/T(n));
    fprintf('CCS Pred Error: %f \n\n',CCS(n)/T(n));

    
    x_predDisp = x_pred; 
    %x_predDisp(curTargetLabels<=1)=-1;
    x_predDisp(x_pred<=2)=0;
    x_predDisp(x_pred>=3)=2;
    
    labelsDisp = curTargetLabels;
    %labelsDisp(curTargetLabels<=1)=-1;
    labelsDisp(curTargetLabels<=2)=0;
    labelsDisp(labels_test{n}>=3)=2;
    
    
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

%%


v2=find(curTargetLabels==2);
v3=find(curTargetLabels==3);
b2v2 = b_i(2,v2);
b2v3 = b_i(2,v3);

figure
hold on
plot(linspace(0,1,length(b2v2)),sort(b2v2))
plot(linspace(0,1,length(b2v3)),sort(b2v3))
legend('v2','v3')
hold off