
sizr = 500; sizc = 750;
curModel = gridmodel(sizr,sizc,3);
curModelPairs = curModel.pairs;

cliqueIndAsI = curModel.N1;
cliqueIndAsJ = curModel.N2;



numPixels = sizr*sizc;
allNode1Edges = cell(1,numPixels);
allNode2Edges = cell(1,numPixels);
for testNode = 1:numPixels
    allNode1Edges{testNode} = find(curModelPairs(:,1)==testNode);
    allNode2Edges{testNode} = find(curModelPairs(:,2)==testNode);
    if(mod(testNode,1000)==0)
       fprintf('%d Nodes Have Pairs Found\n',testNode); 
    end
end