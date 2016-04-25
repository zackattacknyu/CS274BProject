
load('domkeTest1.mat');
addpath(genpath('JustinsGraphicalModelsToolboxPublic'))
p = train_crf(feats,efeats,labels,model,loss_spec,crf_type,options);



save('domkeTest1_results.mat');
