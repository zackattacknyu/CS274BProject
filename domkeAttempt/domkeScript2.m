%NOTE: MUST UNZIP JGMT4.zip TO HERE BEFORE RUNNING THE CODE
%   THE FOLDER MUST THEN BE ADDED TO THE PATH


sizr = 500;
sizc = 750;
rho = 0.5;
nvals = 2;

yFiles = dir('projectData/ytarget1109*');
xFiles = dir('projectData/xdata1109*');

totalN = length(xFiles);
trialInds = 1:totalN;
N = length(trialInds);

addpath(genpath('JustinsGraphicalModelsToolboxPublic'))

model = gridmodel(sizr,sizc,nvals);

x = cell(1,N);
y = cell(1,N);

for n = 1:N
    fileI = trialInds(n);
    load(strcat('projectData/',xFiles(fileI).name))
    x{n} = xdata;
    load(strcat('projectData/',yFiles(fileI).name))
    y{n} = ytarget;
end


feats = cell(1,N);
labels = cell(1,N);

for n = 1:N
    curFeats = x{n};
    curFeatsUse = zeros(500*750,13);
    for ff = 1:13
        curF = curFeats(:,:,ff);
        curFeatsUse(:,ff) = curF(:);
    end
    feats{n} = curFeatsUse;
    
    curLabels = y{n};
    curLabelsUse = (curLabels(:)<1);
    labels{n} = curLabelsUse;
end

efeats = [];

loss_spec = 'trunc_cl_trw_5';

crf_type = 'linear_linear';
options.derivative_check = 'off';
%options.viz = @viz2;
options.rho = rho;
options.print_times = 1;
options.nvals = nvals;

save('domkeTest2.mat','feats','efeats','labels','model','loss_spec','crf_type','options');
%%
figure
p = train_crf(feats,efeats,labels,model,loss_spec,crf_type,options);
%%
load('domkeTest1_results.mat');
testYFiles = dir('projectData/ytarget1209*');
testXFiles = dir('projectData/xdata1209*');
testLFiles = dir('projectData/seg1209*');

totalN = length(testXFiles);
testTrialInds = 1:400:totalN;
N2 = length(testTrialInds);

%addpath(genpath('JustinsGraphicalModelsToolboxPublic'))

testX = cell(1,N2);
testY = cell(1,N2);
testL = cell(1,N2);

for n = 1:N2
    fileI = trialInds(n);
    load(strcat('projectData/',testXFiles(fileI).name))
    testX{n} = xdata;
    load(strcat('projectData/',testYFiles(fileI).name))
    testY{n} = ytarget;
    load(strcat('projectData/',testLFiles(fileI).name))
    testL{n} = seg;
end

testlabels = cell(1,N2);

errors = zeros(1,N2);
labelPredResults = cell(1,N2);

sizer = 500;
sizec = 750;

for n = 1:N2
    curFeats = testX{n};
    curFeatsUse = zeros(500*750,13);
    for ff = 1:13
        curF = curFeats(:,:,ff);
        curFeatsUse(:,ff) = curF(:);
    end
    
    curLabels = testY{n};
    curLabelsUse = (curLabels(:)<1);
    
    curL = testL{n};
    curTemps = curFeats(:,:,1);
    indsUse = find(curL>0 & curTemps>0);
    
    [b_i, b_ij] = eval_crf(p,curFeatsUse,efeats,model,loss_spec,crf_type,rho);
    b_i = reshape(b_i',[sizr sizc nvals]);
    [~,label_pred] = max(b_i,[],3);
    labelPredResults{n} = label_pred;
    
    errors(n) = mean(label_pred(indsUse)~=curLabelsUse(indsUse))
    
    fig = figure;
    imagesc(reshape(label_pred,500,750))
    colormap([1 1 1;0.8 0.8 0.8;jet(20)])
    caxis([-1 20]) 
    drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
    colorbar('vertical')
    %fileNm = ['sepOct2012PngFiles/NEWSINGLE_J' num2str(JVALUE) 'rf5_time' num2str(i) '_Iter' num2str(jj) 'Map.png'];
    %print(fig,fileNm,'-dpng');
    
    fig2 = figure;
    imagesc(reshape(testY{n},500,750))
    colormap([1 1 1;0.8 0.8 0.8;jet(20)])
    caxis([-1 20]) 
    drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
    colorbar('vertical')
    %fileNm = ['sepOct2012PngFiles/NEWSINGLE_J' num2str(JVALUE) 'rf5_time' num2str(i) '_Iter' num2str(jj) 'Map.png'];
    %print(fig,fileNm,'-dpng');
    
    pause(2);
    close(fig);
    close(fig2);
end


