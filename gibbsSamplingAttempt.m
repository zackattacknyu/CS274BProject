%NOTE: MUST UNZIP JGMT4.zip TO HERE BEFORE RUNNING THE CODE
%   THE FOLDER MUST THEN BE ADDED TO THE PATH


sizr = 500;
sizc = 750;
rho = 0.5;
nvals = 2;

addpath(genpath('JustinsGraphicalModelsToolboxPublic'))

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

load('domkeCRFrun19','p');
%load('currentDomkeResults19_mini'); %DISTRIBUTION IS NOT VERY BIMODAL
%load('currentDomkeResults19_mini_precipBound'); %DIST IS QUITE BIMODAL THIS WAY
%load('currentDomkeResults19_mini_precipBoundRand');
%load('currentDomkeResults17.mat','p'); %DO NOT USE ATM

totalN2 = length(xFiles12);
%trialInds = 1:totalN;
numRandInds = 5;

%load('highestPrecipInds1209');
%trialInds2 = highestPrecipInds(1:numRandInds);
%trialInds2 = sort(unique(floor(rand(1,numRandInds)*totalN2)));
trialInds2 = [1196];

[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels] = ...
    obtainDataFromFiles(trialInds2,...
    xFiles12,yFiles12,ccsFiles12,xOneFiles12);

fprintf('get the marginals for test images...\n');
close all
E = zeros(1,length(feats_test));
T = zeros(1,length(feats_test));
Base = zeros(1,length(feats_test));
CCS = zeros(1,length(feats_test));
biArrays = cell(1,length(feats_test));
for n=1:length(feats_test)
    [b_i b_ij] = eval_crf(p,feats_test{n},efeats_test{n},models_test{n},loss_spec,crf_type,rho);
    
    biArrays{n} = b_i;
end

%%

curModelNum = 1;
curModel = models_test{curModelNum};
curModelPairs = curModel.pairs;

cliqueIndAsI = curModel.N1;
cliqueIndAsJ = curModel.N2;

sizr = 500; sizc = 750;
%previousY = x_pred;
previousY = ceil(rand(sizr,sizc)*2)+1;
%previousY = ones(sizr,sizc).*3;
%imagesc(previousY);colorbar;

targetLabels = labels_test{curModelNum};

curFeats = feats_test{1};
curFeatsEdges = efeats_test{1};

nodeLogPotentials = curFeats*p.F';
edgeLogPotentials = curFeatsEdges*p.G';

currentLogPotential = zeros(1,3);


allNode1Edges = cell(1,numel(targetLabels));
allNode2Edges = cell(1,numel(targetLabels));
for testNode = 1:numel(targetLabels)
    allNode1Edges{testNode} = find(curModelPairs(:,1)==testNode);
    allNode2Edges{testNode} = find(curModelPairs(:,2)==testNode);
    if(mod(testNode,1000)==0)
       fprintf('%d Nodes Have Pairs Found\n',testNode); 
    end
end


numIter=5000;

iterationMaps = cell(1,numIter);
currentY = ones(size(targetLabels));
for iter = 1:numIter
    tic
    fprintf('Now doing iteration %d\n',iter);
    for testNode = 1:numel(targetLabels)

        if(mod(testNode,5000)==0)
           fprintf('%d Nodes Processed\n',testNode); 
        end

        if(targetLabels(testNode)==1)
            currentY(testNode)=1;
           continue; 
        end



        currentLogPotential = zeros(1,3);
        for testNodeValue = 1:3
           currentNodePotential = ...
               nodeLogPotentials(testNode,testNodeValue);
           currentLogPotential(testNodeValue) = currentLogPotential(testNodeValue)...
               + currentNodePotential;
        end

        %node1Edges = find(curModelPairs(:,1)==testNode);
        node1Edges = allNode1Edges{testNode};
        node2Edges = allNode2Edges{testNode};
        %node2Edges = find(curModelPairs(:,2)==testNode);

        for edgeI = 1:length(node1Edges)
            edge = node1Edges(edgeI);
            logPotMatrix = reshape(edgeLogPotentials(edge,:),3,3);

            node2 = curModelPairs(edge,2);
            for testNodeValue = 1:3
                node2value = previousY(node2);
                curEdgePot = logPotMatrix(testNodeValue,node2value);
                currentLogPotential(testNodeValue) = ...
                   currentLogPotential(testNodeValue) + curEdgePot;
            end

        end

        for edgeI = 1:length(node2Edges)
            edge = node2Edges(edgeI);
            logPotMatrix = reshape(edgeLogPotentials(edge,:),3,3);

            node1 = curModelPairs(edge,1);
            for testNodeValue = 1:3
                %node1value = previousY(node1);
                node1value = currentY(node1);
                curEdgePot = logPotMatrix(node1value,testNodeValue);
                currentLogPotential(testNodeValue) = ...
                   currentLogPotential(testNodeValue) + curEdgePot;
            end

        end

        [maxLogPotential,bestLabel] = max(currentLogPotential);

        if(maxLogPotential>700)
           labelAssign = bestLabel; 
        else
            denom = sum(exp(currentLogPotential));
            probs = exp(currentLogPotential)./denom;

            randSample = rand;
            labelAssign = find(randSample<cumsum(probs),1,'first');


        end

        currentY(testNode)=labelAssign;
        %currentY(testNode)=randLabel+1;


    end
    
    previousY = currentY;
    toc
    if(mod(iter,200)==0)
        iterationMaps{iter} = currentY;
        save('currentIterMaps.mat','iterationMaps');
    end
end


%%


%{
numIter=30;
sampledImages = cell(1,numIter);
currentY = zeros(sizr,sizc);
for iterNum=1:numIter
    
    fprintf('Now processing iteration %d of %d\n',iterNum,numIter);
    for nodeNum = 1:numel(previousY)

        if(mod(nodeNum,10000)==0) 
           fprintf('%d of %d nodes have been processed\n',nodeNum,numel(previousY)); 
        end
        
        %if node is automatically supposed to be 1 from test info
        %if(targetLabels(nodeNum)<2)
        %    currentY(nodeNum)=1;
        %    continue;
        %end
        
        

        curIcliques = cliqueIndAsI(nodeNum,:);
        curIcliques = curIcliques(curIcliques>0);
        curJcliques = cliqueIndAsJ(nodeNum,:);
        curJcliques = curJcliques(curJcliques>0);

        currentBi = ones(1,3);
        %jValues = [1 2];
        %iValues = [3 3];

        %Backward Neighbors, use current values
        for j = 1:length(curJcliques)

            curClique = curJcliques(j);
            curPair2 = curModelPairs(curJcliques(j),:);
            curNeighIndex = curPair2(1);

            %curI = iValues(j);
            if(targetLabels(curNeighIndex)<2)
                curI=1;
            else
                curI = currentY(curNeighIndex);
            end
            

            currentBij = reshape(b_ij(:,curClique),3,3);
            currentBijGivenI = currentBij./repmat(sum(currentBij,2),1,3);
            currentBi = currentBi.*currentBijGivenI(curI,:);
        end
        currentBi = currentBi';
        currentBi = currentBi./sum(currentBi);

        %Forward Neighbors, use previous values
        for i = 1:length(curIcliques)
            curClique = curIcliques(i);
            curPair = curModelPairs(curIcliques(i),:);
            curNeighIndex = curPair(2);

            %curJ = jValues(i);
            if(targetLabels(curNeighIndex)<2)
                curJ=1;
            else
                curJ = previousY(curNeighIndex);
            end
            

            currentBij = reshape(b_ij(:,curClique),3,3);
            currentBijGivenJ = currentBij./repmat(sum(currentBij,1),3,1);
            currentBi = currentBi.*currentBijGivenJ(:,curJ);
        end

        newProbXi = currentBi./sum(currentBi);
        
        %incorporate fact that Xi~=1
        newProbXi = newProbXi(2:3);
        newProbXi = newProbXi./sum(newProbXi);

        %attach bad prior
        newProbXi = newProbXi.*[0.2;0.8];
        newProbXi = newProbXi./sum(newProbXi);
        
        %sample from the conditional distribution
        randSample = rand;
        randLabel = find(randSample<cumsum(newProbXi),1,'first');

        %currentY(nodeNum)=randLabel;
        currentY(nodeNum)=randLabel+1;
    end
    
    if(mod(iterNum,5)==0)
        sampledImages{iterNum} = currentY;
    end
    
    previousY = currentY;
end

numIterShow=30;
ind=1;
figure
for i = 5:5:numIterShow
   subplot(2,3,ind);
   ind = ind+1
   imagesc(sampledImages{i});
   colorbar;
end
%}
%%

for ii = 1:length(iterationMaps)
   curIter = iterationMaps{ii};
   if(~isempty(curIter))
      fprintf('Iteration Map %d \n',ii);
      figure
      imagesc(curIter);
      colorbar;
   end
end
