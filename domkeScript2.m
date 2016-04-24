N = 5; 
siz = 50;
rho = 0.5;
nvals = 2;
ss
model = gridmodel(siz,siz,nvals);

filt = fspecial('gaussian',50,7);
x = cell(1,N);
y = cell(1,N);
noiselevel = 1.25;
for n = 1:N
   randIm = rand(siz);
   filteredIm = imfilter(randIm,filt,'same','symmetric');
   x{n} = round(filteredIm);
   t = rand(size(x{n}));
   y{n} = x{n}.*(1-t.^noiselevel) + (1-x{n}).*t.^noiselevel;
end
%%

%results as shown in his webpage
figure
for i = 1:N
   subplot(2,5,i);
   imshow(x{i});
   
   subplot(2,5,i+5);
   imshow(y{i});
end

%%

feats = cell(1,N);
labels = cell(1,N);

for n = 1:N
   feats{n} = [y{n}(:) 1+0*x{n}(:)];
   labels{n} = x{n}+1;
end

efeats = [];

loss_spec = 'trunc_cl_trw_5';

crf_type = 'linear_linear';
options.derivative_check = 'off';
options.viz = @viz;
options.rho = rho;
options.print_times = 1;
options.nvals = nvals;

figure
p = train_crf(feats,efeats,labels,model,loss_spec,crf_type,options);

%%

x = round(imfilter(rand(siz),fspecial('gaussian',50,7),'same','symmetric'));
t = rand(size(x));
y = x.*(1-t.^noiselevel) + (1-x).*t.^noiselevel;
feats  = [y(:) 1+0*x(:)];
labels = x+1;

[b_i, b_ij] = eval_crf(p,feats,efeats,model,loss_spec,crf_type,rho);
b_i = reshape(b_i',[siz siz nvals]);
[~,label_pred] = max(b_i,[],3);
error = mean(label_pred(:)~=labels(:))


