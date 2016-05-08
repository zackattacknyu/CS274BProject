function [feats,efeats,labels,models,precipImages,ccsLabels] =...
    obtainDataFromFiles(trialInds,xFiles,yFiles,ccsFiles,xOneFiles)
%OBTAINDATAFROMFILE Summary of this function goes here
%   Detailed explanation goes here
N = length(trialInds);
x = cell(1,N);
y = cell(1,N);

ccsY = cell(1,N);
noCloudIndices = cell(1,N);

for n = 1:N
    fprintf(strcat('Loading data for time ',num2str(n),' of ',num2str(N),'\n'));
    fileI = trialInds(n);
    load(strcat('projectData/',xFiles(fileI).name))
    x{n} = xdata;
    load(strcat('projectData/',yFiles(fileI).name))
    y{n} = ytarget;
    
    noCloudIndices{n} = find(x{n}(:,:,1)<=0);

    load(strcat('projectData/',ccsFiles(fileI).name))
    ccsY{n} = ccspred;
    load(strcat('projectData/',xOneFiles(fileI).name))
    x{n}(:,:,1)=xone;
end

[sizr,sizc] = size(ytarget);

%[highestAmounts,highestPrecipInds] = sort(curSum,'descend');


feats = cell(N,1);
labels = cell(N,1);
models = cell(N,1);
precipImages = cell(N,1);
ccsLabels = cell(N,1);

for n = 1:N
    fprintf(strcat('Making data for time ',num2str(n),' of ',num2str(N),'\n'));
    
    feats{n} = reshape(x{n},sizr*sizc,13);
    
    tempCol = zeros(sizr*sizc,1);
    tempCol(noCloudIndices{n})=1;
    feats{n} = [feats{n} ones(sizr*sizc,1) tempCol];
    
    imageY = y{n};
    
    noRainfallReadInds = find(imageY<0);
    noLabelInds = union(noRainfallReadInds,noCloudIndices{n});
    
    imageY(imageY<0)=0;
    precipImages{n} = imageY;
    
    ccsLabels{n} = getLabelsFromY(ccsY{n},noLabelInds);
    labels{n} = getLabelsFromY(y{n},noLabelInds);
    models{n} = gridmodel(sizr,sizc,3);
    
    
end

%edge_params = {{'const'},{'diffthresh'},{'pairtypes'}};
edge_params = {{'const'},{'diffthresh'}};
%edge_params = {{'const'},{'diffthresh'}};

fprintf('computing edge features...\n')
efeats = cell(N,1);
for n=1:N
    efeats{n} = edgeify_im(x{n}(:,:,1),edge_params,models{n}.pairs,models{n}.pairtype);
end

end

