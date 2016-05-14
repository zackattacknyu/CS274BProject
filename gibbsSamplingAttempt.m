
curModelNum = 6;
curModel = models_test{curModelNum};
curModelPairs = curModel.pairs;

cliqueIndAsI = curModel.N1;
cliqueIndAsJ = curModel.N2;

nodeNum = 1250;

curIcliques = cliqueIndAsI(nodeNum,:);
curIcliques = curIcliques(curIcliques>0);
curJcliques = cliqueIndAsJ(nodeNum,:);
curJcliques = curJcliques(curJcliques>0);

currentBi = ones(1,3);
jValues = [2 3];
iValues = [3 3];

%Backward Neighbors
for j = 1:length(curJcliques)
       
    curClique = curJcliques(i);
    %curPair2 = curModelPairs(curJcliques(j),:)
    %curNeigh = curPair(1);
    
    curI = iValues(i);
    currentBij = reshape(b_ij(:,curClique),3,3);
    currentBijGivenI = currentBij./repmat(sum(currentBij,2),1,3);
    currentBi = currentBi.*currentBijGivenI(curI,:);
end
currentBi = currentBi';

%Forward Neighbors
for i = 1:length(curIcliques)
    curClique = curIcliques(i);
    %curPair = curModelPairs(curIcliques(i),:)
    curNeigh = curPair(2);
    
    curJ = jValues(i);
    currentBij = reshape(b_ij(:,curClique),3,3);
    currentBijGivenJ = currentBij./repmat(sum(currentBij,1),3,1);
    currentBi = currentBi.*currentBijGivenJ(:,curJ);
end

