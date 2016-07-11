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

loss_spec = 'trunc_cl_trwpll_5';
crf_type  = 'linear_linear';
options.print_times = 0; % since this is so slow, print stuff to screen
options.gradual     = 1; % use gradual fitting
options.maxiter     = 1000;
options.rho         = rho;
options.reg         = 1e-4;
options.opt_display = 0;


%load('domkeCRFrun_3edgeFeats_cliqueLoss_new3','p','validationInds');
load('ROCvars_sep2012_3edgeFeats_cliqueLoss_testInds_new3','trialInds2');
trialInds2 = trialInds2(1:4);

[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles3(trialInds2,...
    xFiles12,yFiles12,ccsFiles12,xOneFiles12);

XdataTest = [];
YdataTest = [];

for i = 1:length(feats_test)
    i
    XdataTest = [XdataTest;feats_test{i}];
    YdataTest = [YdataTest;floor(labels_test{i}(:))];
end

testPixels2 = find(YdataTest>1);

f3arrays = cell(1,13);
f2arrays = cell(1,13);
xi3arrays = cell(1,13);
xi2arrays = cell(1,13);

for feat = 1:13
    XX2 = XdataTest(testPixels2,feat);
    YY2 = YdataTest(testPixels2)-2;

    precipInds = find(YY2>0.9);
    noPrecipInds = find(YY2<0.1);

    tempValsPrecip = XX2(precipInds);
    tempValsNoPrecip = XX2(noPrecipInds);

    [f3,xi3] = ksdensity(tempValsPrecip);
    [f2,xi2] = ksdensity(tempValsNoPrecip);

    f3arrays{feat} = f3;
    f2arrays{feat} = f2;
    xi3arrays{feat} = xi3;
    xi2arrays{feat} = xi2;

end

%save('KSdensityVars_sep2012_new3inds.mat','f3arrays','f2arrays','xi3arrays','xi2arrays');

%load('KSdensityVars_sep2012_new3inds')

for feat=1:13
    figure
    hold on
    plot(xi2arrays{feat},f2arrays{feat},'g-');
    plot(xi3arrays{feat},f3arrays{feat},'r-');
    legend('No Precip Inds','Precip Inds');
    hold off 
end
