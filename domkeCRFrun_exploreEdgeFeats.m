%NOTE: MUST UNZIP JGMT4.zip TO HERE BEFORE RUNNING THE CODE
%   THE FOLDER MUST THEN BE ADDED TO THE PATH


sizr = 500;
sizc = 750;
rho = 0.5;
nvals = 2;

addpath(genpath('JustinsGraphicalModelsToolboxPublic'))

yFiles = dir('projectData/ytarget1209*');
xOneFiles = dir('projectData/xone1209*');

yFiles12 = dir('projectData/ytarget1209*');
xFiles12 = dir('projectData/xdata1209*');
ccsFiles12 = dir('projectData/ccspred1209*');
xOneFiles12 = dir('projectData/xone1209*');

%load('highestPrecipInds1109');
%trialInds = highestPrecipInds(1:numRandInds);


%loss_spec = 'trunc_cl_trwpll_5';
loss_spec = 'em_mnf_1e5';
%loss_spec = 'trunc_uquad_trwpll_5';

crf_type  = 'linear_linear';
%options.viz         = @viz;
options.print_times = 0; % since this is so slow, print stuff to screen
options.gradual     = 1; % use gradual fitting
options.maxiter     = 1000;
options.rho         = rho;
options.reg         = 1e-4;
options.opt_display = 0;


trialInds2 = [325 1114 1152 204 284 1196 1199];

N = length(trialInds2);
tempData = cell(1,N);
y = cell(1,N);

for n = 1:N
    fprintf(strcat('Loading data for time ',num2str(n),' of ',num2str(N),'\n'));
    fileI = trialInds2(n);
    
    load(strcat('projectData/',xOneFiles(fileI).name))
    tempData{n}=reshape(xone,sizr,sizc);
end

[feats_test,efeats_test,labels_test,models_test,precipImages_test,ccsLabels,ccsYvalues] = ...
    obtainDataFromFiles(trialInds2,...
    xFiles12,yFiles12,ccsFiles12,xOneFiles12);
%%
for n = 1:N
   figure
   subplot(1,3,1)
   imagesc(labels_test{n})
   title('Target Labels');
   drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
   colorbar;
   
   curTemps = tempData{n};
   curHorizDiff = diff(curTemps,[],2);
   curVertDiff = diff(curTemps);
   
   curHmap = abs(curHorizDiff);
   curHmap(curHmap>10)=0;
   curVmap = abs(curVertDiff);
   curVmap(curVmap>10)=0;
   
   subplot(1,3,2)
   imagesc(abs(curHmap));
   title('Horizontal Edge Differences');
   drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
   colorbar;
   
   subplot(1,3,3)
   imagesc(abs(curVmap));
   title('Vertical Edge Differences');
   drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
   colorbar;
   
   %subplot(1,4,4)
   %imagesc(curTemps)
   %colorbar;
end


