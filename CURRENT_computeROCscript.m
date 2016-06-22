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
numRandInds = 100;
%load('highestPrecipInds1109');
%trialInds = highestPrecipInds(1:numRandInds);

loss_spec = 'trunc_cl_trwpll_5';
%loss_spec = 'em_mnf_1e5';
%loss_spec = 'trunc_uquad_trwpll_5';

crf_type  = 'linear_linear';
%options.viz         = @viz;
options.print_times = 0; % since this is so slow, print stuff to screen
options.gradual     = 1; % use gradual fitting
options.maxiter     = 1000;
options.rho         = rho;
options.reg         = 1e-4;
options.opt_display = 0;


%load('domkeCRFrun_3edgeFeats_emTRW','p');
%load('domkeCRFrun_3edgeFeats_cliqueLoss_new.mat')
load('domkeCRFrun_3edgeFeats_cliqueLoss_new2.mat')

[ rocx,rocy,rocThr,rocAuc,probDet,falseAlarm,thr,auc ] =...
    CURRENT_computeROCstats(p, trainingInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11,loss_spec,crf_type,rho );

save('ROCvars_sep2011_3edgeFeats_cliqueLoss_trainingInds_new2.mat',...
    'rocx','rocy','rocThr','rocAuc',...
    'probDet','falseAlarm','thr','auc');

[ rocx,rocy,rocThr,rocAuc,probDet,falseAlarm,thr,auc ] =...
    CURRENT_computeROCstats(p, validationInds,...
    xFiles11,yFiles11,ccsFiles11,xOneFiles11,loss_spec,crf_type,rho );

save('ROCvars_sep2011_3edgeFeats_cliqueLoss_validationInds_new2.mat',...
    'rocx','rocy','rocThr','rocAuc',...
    'probDet','falseAlarm','thr','auc');

totalN2 = length(xFiles12);
numRandInds = 100;
trialInds2 = sort(unique(floor(rand(1,numRandInds)*totalN2)));

[ rocx,rocy,rocThr,rocAuc,probDet,falseAlarm,thr,auc ] =...
    CURRENT_computeROCstats(p, trialInds2,...
    xFiles12,yFiles12,ccsFiles12,xOneFiles12,loss_spec,crf_type,rho );

save('ROCvars_sep2012_3edgeFeats_cliqueLoss_testInds_new2.mat',...
    'rocx','rocy','rocThr','rocAuc',...
    'probDet','falseAlarm','thr','auc','trialInds2');

%%
figure
hold on
plot(rocx,rocy);
plot(0:0.05:1,0:0.05:1,'b--');
legend('ROC Curve','Baseline ROC');
xlabel('False positive rate')
ylabel('True positive rate')
hold off

figure
hold on
title('Threshold versus Error Rates for CRF model');
plot(rocThr,rocy,'r-');
plot(rocThr,rocx,'b-');
plot(thr,probDet,'k-');
legend('True Positive','False Positive','Accuracy');
xlabel('Score Threshold for Class 3');
ylabel('Rate');
hold off



