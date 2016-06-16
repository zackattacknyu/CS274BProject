%NOTE: MUST UNZIP JGMT4.zip TO HERE BEFORE RUNNING THE CODE
%   THE FOLDER MUST THEN BE ADDED TO THE PATH
% The file can be downloaded from this webpage:
%       http://users.cecs.anu.edu.au/~jdomke/JGMT/


sizr = 500;
sizc = 750;
rho = 0.5;
nvals = 2;

yFiles11 = dir('projectData/ytarget1109*');
xFiles11 = dir('projectData/xdata1109*');
ccsFiles11 = dir('projectData/ccspred1109*');
xOneFiles11 = dir('projectData/xone1109*');

yFiles12 = dir('projectData/ytarget1209*');
xFiles12 = dir('projectData/xdata1209*');
ccsFiles12 = dir('projectData/ccspred1209*');
xOneFiles12 = dir('projectData/xone1209*');

totalN = length(xFiles11);
totalN2 = length(xFiles12);
numRandInds = 160;
trialInds = sort(unique(floor(rand(1,numRandInds)*totalN)));
trialInds2 = sort(unique(floor(rand(1,numRandInds)*totalN2)));

loss_spec = 'trunc_cl_trwpll_5';
crf_type  = 'linear_linear';
options.print_times = 0; % since this is so slow, print stuff to screen
options.gradual     = 1; % use gradual fitting
options.maxiter     = 1000;
options.rho         = rho;
options.reg         = 1e-4;
options.opt_display = 0;


load('domkeCRFrun_3edgeFeats','p');
%REST OF CODE IS TESTS DONE AFTER PARAMETERS FOUND

%UNCOMMENT THIS BLOCK IF USING SEP 2011 MAPS
[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles3(trialInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11);

domkeCRFrun_avgProbsScript
save('avgProbs_sep2011');

%UNCOMMENT THIS BLOCK IF USING SEP 2012 MAPS
[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles3(trialInds2,...
    xFiles12,yFiles12,ccsFiles12,xOneFiles12);

domkeCRFrun_avgProbsScript
save('avgProbs_sep2012');