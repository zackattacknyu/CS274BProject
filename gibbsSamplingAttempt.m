
curModelNum = 1;
curModel = models_test{curModelNum};
curModelPairs = curModel.pairs;

cliqueIndAsI = curModel.N1;
cliqueIndAsJ = curModel.N2;

sizr = 500; sizc = 750;
previousY = x_pred;
%previousY = ceil(rand(sizr,sizc)*2)+1;
%previousY = ones(sizr,sizc).*3;
%imagesc(previousY);colorbar;

targetLabels = labels_test{curModelNum};

curFeats = feats_test{1};
curFeatsEdges = efeats_test{1};

nodeLogPotentials = curFeats*p.F';
edgeLogPotentials = curFeatsEdges*p.G';
%%

currentLogPotential = zeros(1,3);
testNode = 129672;

for testNodeValue = 1:3
   currentNodePotential = ...
       nodeLogPotentials(testNode,testNodeValue);
   currentLogPotential(testNodeValue) = currentLogPotential(testNodeValue)...
       + currentNodePotential;
end


for edge = 1:size(edgeLogPotentials,1)
   node1 = curModelPairs(edge,1);
   node2 = curModelPairs(edge,2);
   logPotMatrix = reshape(edgePotentials(edge,:),3,3);
   
   for testNodeValue = 1:3
        if(node1==testNode)
          node2value = previousY(node2);
          curEdgePot = logPotMatrix(testNodeValue,node2value);
          currentLogPotential(testNodeValue) = ...
              currentLogPotential(testNodeValue) + curEdgePot;

       end

       if(node2==testNode)
          node1value = previousY(node1);
          curEdgePot = logPotMatrix(node1value,testNodeValue);
          currentLogPotential(testNodeValue) = ...
              currentLogPotential(testNodeValue) + curEdgePot;

       end
   end
   
   
end

denom = sum(exp(currentLogPotential));
probs = exp(currentLogPotential)./denom;

%%
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
%%
numIterShow=30;
ind=1;
figure
for i = 5:5:numIterShow
   subplot(2,3,ind);
   ind = ind+1
   imagesc(sampledImages{i});
   colorbar;
end


