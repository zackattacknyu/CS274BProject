function [feats,efeats,labels,models,precipImages,ccsLabels,ccsY] =...
    obtainDataFromFiles3_add2col(trialInds,xFiles,yFiles,ccsFiles,xOneFiles,segFiles)
%OBTAINDATAFROMFILE Summary of this function goes here
%   Detailed explanation goes here
N = length(trialInds);
x = cell(1,N);
y = cell(1,N);
segInfo = cell(1,N);

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
    
    load(strcat('projectData/',segFiles(fileI).name));
    segInfo{n} = seg;
end

[sizr,sizc] = size(ytarget);

%[highestAmounts,highestPrecipInds] = sort(curSum,'descend');


feats = cell(N,1);
labels = cell(N,1);
models = cell(N,1);
precipImages = cell(N,1);
ccsLabels = cell(N,1);
minNumPixels = 2000;

for n = 1:N
    fprintf(strcat('Making data for time ',num2str(n),' of ',num2str(N),'\n'));
    
    feats{n} = reshape(x{n},sizr*sizc,13);
    
    curSeg = segInfo{n};
    components = bwconncomp(curSeg>0);
    patchSizeFeat = zeros(size(curSeg));
    isLargePatchFeat = zeros(size(curSeg));
    
    patchSizeFeat2 = zeros(size(curSeg));
    isLargeBoxPatchFeat = zeros(size(curSeg));
    
    for cloudNum = 1:length(components.PixelIdxList)
        curSize = numel(components.PixelIdxList{cloudNum});
        patchSizeFeat(components.PixelIdxList{cloudNum}) = curSize;
        
        isCloud = zeros(size(curSeg));
        isCloud(components.PixelIdxList{cloudNum})=1;
        
        if(curSize > minNumPixels)
            isLargePatchFeat(components.PixelIdxList{cloudNum}) = 1;
            
            vertCols = sum(isCloud,1);
            horzCols = sum(isCloud,2);
            minR = find(horzCols>0, 1 ,'first');
            maxR = find(horzCols>0, 1, 'last');
            minC = find(vertCols>0, 1, 'first');
            maxC = find(vertCols>0, 1, 'last');
            
            patchSizeFeat2(minR:maxR,minC:maxC) = curSize;
            isLargeBoxPatchFeat(minR:maxR,minC:maxC) = 1;
        end
    end
    
    tempCol = zeros(sizr*sizc,1);
    tempCol(noCloudIndices{n})=1;
    feats{n} = [feats{n} ones(sizr*sizc,1) tempCol ...
        patchSizeFeat(:) isLargePatchFeat(:) ...
        patchSizeFeat2(:) isLargeBoxPatchFeat(:)];
    
    imageY = y{n};
    
    
    
    noRainfallReadInds = find(imageY<0);
    noLabelInds = union(noRainfallReadInds,noCloudIndices{n});
    
    imageY(imageY<0)=0;
    precipImages{n} = imageY;
    
    ccsLabels{n} = getLabelsFromY(ccsY{n},noLabelInds);
    labels{n} = getLabelsFromY(y{n},noLabelInds);
    models{n} = gridmodel(sizr,sizc,3);
    
    
end

fprintf('computing edge features...\n')
efeats = cell(N,1);
for n=1:N
    efeats{n} = edgeify_im3(x{n}(:,:,1),models{n}.pairs);
end

end

