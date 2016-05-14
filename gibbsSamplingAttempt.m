
curModelNum = 6;
curModel = models_test{curModelNum};
curModelPairs = curModel.pairs;

curNeighborsAsI = curModel.N1;
curNeighborsAsJ = curModel.N2;

nodeNum = 1;

pairsAsI = curNeighborsAsI(nodeNum,:);
pairsAsI = pairsAsI(pairsAsI>0);
pairsAsJ = curNeighborsAsJ(nodeNum,:);
pairsAsJ = pairsAsJ(pairsAsJ>0);

%Forward Neighbors
for i = 1:length(pairsAsI)
    curPair = curModelPairs(pairsAsI(i),:);
    curNeigh = curPair(2);
end

%Backward Neighbors
for j = 1:length(pairsAsJ)
    curPair2 = curModelPairs(pairsAsJ(j),:);
    curNeigh = curPair(1);
end

%%

%EXAMPLE VAR ELIM CODE I WILL NEED TO USE
%FIX THIS CODE
%{
bij1 = reshape(b_ij(:,1),3,3); %IJ MATRIX
bij2 = reshape(b_ij(:,501),3,3); %IK MATRIX

pIafter1 = sum(bij1,2); %eliminate j variable

newIKmatrix = bij2.*(repmat(pIafter1,1,3));

%normalize the columns
newIKmatrix2 = newIKmatrix./repmat(sum(newIKmatrix,1),3,1);
pIafter2 = sum(newIKmatrix2,2); %eliminate k variable
%}

%WORKS, BUT NOT SCALABLE ATM
ijkMatrix = b_ij(:,1)*b_ij(:,501)';
ijMatrix = reshape(sum(ijkMatrix,2),3,3);
iMatrix = sum(ijMatrix,2);
diff = sum(abs(iMatrix-b_i(:,1))); %UNIT TEST OF VAR ELIM
