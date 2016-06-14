
%timeUse = 1234;
%currentTimeStr = datestr(clock,'yyyymmddHHMMSS');
%currentFileStr = ['gibbsSample_time' num2str(timeUse) ...
%    '_runAt' currentTimeStr '.mat'];
%save(currentFileStr,'sizr');

%%
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

%load('domkeCRFrun19','p');
load('domkeCRFrun_3edgeFeats','p');
totalN2 = length(xFiles12);

trialInds2 = [timeUse];

[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels] = ...
    obtainDataFromFiles3(trialInds2,...
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

targetLabels = labels_test{curModelNum};

curFeats = feats_test{1};
curFeatsEdges = efeats_test{1};

nodeLogPotentials = curFeats*p.F';
edgeLogPotentials = curFeatsEdges*p.G';

currentLogPotential = zeros(1,3);

load('model_500_750_edgeIndex.mat');

numIter=3000;
numSeq=1;
currentTimeStr = datestr(clock,'yyyymmddHHMMSS');
currentFileStr = ['gibbsSample_time' num2str(timeUse) ...
    '_runAt' currentTimeStr '.mat'];

%avg of 0.3 seconds per iteration
iterationMaps = cell(numSeq,numIter);

for seqNum = 1:numSeq
    currentY = ones(size(targetLabels));
    for iter = 1:numIter

        %fprintf('Now doing iteration %d\n',iter);
        for testNode = 1:numel(targetLabels)

            %if(mod(testNode,5000)==0)
            %   fprintf('%d Nodes Processed\n',testNode); 
            %end

            if(targetLabels(testNode)==1)
                currentY(testNode)=1;
               continue; 
            end



            currentLogPotential = nodeLogPotentials(testNode,:);

            node1Edges = allNode1Edges{testNode};
            node2Edges = allNode2Edges{testNode};

            for edgeI = 1:length(node1Edges)
                edge = node1Edges(edgeI);
                logPotMatrix = reshape(edgeLogPotentials(edge,:),3,3);

                node2 = curModelPairs(edge,2);
                node2value = previousY(node2);
                currentLogPotential = currentLogPotential + logPotMatrix(:,node2value)';

            end

            for edgeI = 1:length(node2Edges)
                edge = node2Edges(edgeI);
                logPotMatrix = reshape(edgeLogPotentials(edge,:),3,3);

                node1 = curModelPairs(edge,1);
                node1value = currentY(node1);
                currentLogPotential = currentLogPotential + logPotMatrix(node1value,:);

            end

            [maxLogPotential,bestLabel] = max(currentLogPotential);

            if(maxLogPotential>700)
               labelAssign = bestLabel; 
            else
                denom = sum(exp(currentLogPotential));
                probs = exp(currentLogPotential)./denom;
                
                probs2 = probs(2:3)./sum(probs(2:3));

                randSample = rand;
                labelAssign = find(randSample<cumsum(probs2),1,'first')+1;


            end

            currentY(testNode)=labelAssign;
            %currentY(testNode)=randLabel+1;


        end

        previousY = currentY;
        iterationMaps{seqNum,iter} = currentY;

        if(mod(iter,500)==0)
            fprintf('Time: %d ; SeqNum: %d ; %d Iterations Done\n',timeUse,seqNum,iter);
            save(currentFileStr,'iterationMaps','-v7.3');
        end

    end
    
end

