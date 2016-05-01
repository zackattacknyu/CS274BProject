%NOTE: MUST UNZIP JGMT4.zip TO HERE BEFORE RUNNING THE CODE
%   THE FOLDER MUST THEN BE ADDED TO THE PATH


sizr = 500;
sizc = 750;
rho = 0.5;
nvals = 2;

%yFiles = dir('projectData/ytarget1109*');
%xFiles = dir('projectData/xdata1109*');

yFiles = dir('projectData/ytarget1209*');
xFiles = dir('projectData/xdata1209*');

totalN = length(xFiles);
%trialInds = 1:totalN;
numRandInds = 10;
trialInds = sort(unique(floor(rand(1,numRandInds)*totalN)));
N = length(trialInds);
%feats{n}  = featurize_im(ims{n},feat_params);

%addpath(genpath('JustinsGraphicalModelsToolboxPublic'))


x = cell(1,N);
y = cell(1,N);

for n = 1:N
    fileI = trialInds(n);
    load(strcat('projectData/',xFiles(fileI).name))
    x{n} = xdata;
    load(strcat('projectData/',yFiles(fileI).name))
    y{n} = ytarget;
    fprintf(strcat('Loading data for time ',num2str(n),' of ',num2str(N),'\n'));
end


feats = cell(N,1);
labels = cell(N,1);
models = cell(N,1);
precipImages = cell(N,1);

for n = 1:N
    curFeats = x{n};
    feats{n} = reshape(x{n},sizr*sizc,13);
    
    curY = y{n};
    curLabelsUse = zeros(sizr,sizc);
    %NOTE: IN JGMT, 0 MEANS UNLABELLED. 
    % THUS 1 WILL MEAN NO RAIN
    % AND 2 WILL MEAN RAIN
    curLabelsUse(curY<1)=1;
    curLabelsUse(curY<0)=0;
    curLabelsUse(curY>=1)=2;
    curLabelsUse(curFeats(:,:,1)<=0)=0;
    
    imageY = curY;
    imageY(curY<0)=0;
    precipImages{n} = imageY;
    
    labels{n} = curLabelsUse;
    models{n} = gridmodel(sizr,sizc,2);
    
    fprintf(strcat('Making data for time ',num2str(n),' of ',num2str(N),'\n'));
end

edge_params = {{'const'},{'diffthresh'},{'pairtypes'}};
fprintf('computing edge features...\n')
efeats = cell(N,1);
for n=1:N
    efeats{n} = edgeify_im(precipImages{n},edge_params,models{n}.pairs,models{n}.pairtype);
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

save('currentDomkeResults2')
%%


feats_test=feats;
efeats_test=efeats;
models_test=models;
labels_test=labels;
precipImages_test=precipImages;

%load('currentDomkeResults');
load('domkeResults2','p');

%%
fprintf('get the marginals for test images...\n');
close all
E = zeros(1,length(feats_test));
T = zeros(1,length(feats_test));
Base = zeros(1,length(feats_test));
for n=1:length(feats_test)
    [b_i b_ij] = eval_crf(p,feats_test{n},efeats_test{n},models_test{n},loss_spec,crf_type,rho);

    
    [~,x_pred] = max(b_i,[],1);
    x_pred = reshape(x_pred,sizr,sizc);

    % upsample predicted images to full resolution
    curTargetLabels = labels_test{n};
    testPixels = find(curTargetLabels>0);
    E(n) = sum( x_pred(testPixels)~=labels_test{n}(testPixels));
    Base(n) = length(find(labels_test{n}(testPixels)>1));
    T(n) = numel(testPixels);
    
    fprintf('Current pixelwise error: %f \n',E(n)/T(n));
    fprintf('Baseline error (predict all 0): %f \n',Base(n)/T(n));

    %{
    x_predDisp = x_pred; 
    x_predDisp(curTargetLabels<=0)=0;
    figure
    subplot(1,3,1)
    imagesc(x_predDisp); colorbar;
    subplot(1,3,2)
    imagesc(precipImages_test{n}); colorbar;
    subplot(1,3,3)
    imagesc(labels_test{n}); colorbar;
    drawnow
    %}
end
fprintf('total pixelwise error on test data: %f \n', sum(E)/sum(T))

%{

    fig = figure;
    imagesc(reshape(label_pred,500,750))
    colormap([1 1 1;0.8 0.8 0.8;jet(20)])
    caxis([-1 20]) 
    drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
    colorbar('vertical')
    %fileNm = ['sepOct2012PngFiles/NEWSINGLE_J' num2str(JVALUE) 'rf5_time' num2str(i) '_Iter' num2str(jj) 'Map.png'];
    %print(fig,fileNm,'-dpng');
%}
