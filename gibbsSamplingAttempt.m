
curModelNum = 3;
curModel = models_test{curModelNum};
curModelPairs = curModel.pairs;

cliqueIndAsI = curModel.N1;
cliqueIndAsJ = curModel.N2;

%nodeNum = 12500;
nodeNum = 271001; %greatest class 3 prob
%nodeNum = 77123; %greatest class 2 prob

curIcliques = cliqueIndAsI(nodeNum,:);
curIcliques = curIcliques(curIcliques>0);
curJcliques = cliqueIndAsJ(nodeNum,:);
curJcliques = curJcliques(curJcliques>0);

currentBi = ones(1,3);
jValues = [1 2];
iValues = [3 3];

%Backward Neighbors
for j = 1:length(curJcliques)
       
    curClique = curJcliques(j);
    %curPair2 = curModelPairs(curJcliques(j),:)
    %curNeigh = curPair(1);
    
    curI = iValues(j);
    currentBij = reshape(b_ij(:,curClique),3,3);
    currentBijGivenI = currentBij./repmat(sum(currentBij,2),1,3);
    currentBi = currentBi.*currentBijGivenI(curI,:);
end
currentBi = currentBi';

%Forward Neighbors
for i = 1:length(curIcliques)
    curClique = curIcliques(i);
    %curPair = curModelPairs(curIcliques(i),:)
    %curNeigh = curPair(2);
    
    curJ = jValues(i);
    currentBij = reshape(b_ij(:,curClique),3,3);
    currentBijGivenJ = currentBij./repmat(sum(currentBij,1),3,1);
    currentBi = currentBi.*currentBijGivenJ(:,curJ);
end

newProbXi = currentBi./sum(currentBi);

%sample from the conditional distribution
randSample = rand;
randLabel = find(randSample<cumsum(newProbXi),1,'first')

