function [ x_pred ] = getPredLabelsRand( b_i,sizr,sizc,testPixels)
%GETPREDLABELS Summary of this function goes here
%   Detailed explanation goes here

[~,x_predInit] = max(b_i,[],1);
for kk = 1:length(testPixels)
   ind = testPixels(kk); 
   if(rand>b_i(2,ind))
      x_predInit(ind)=3;
  else
      x_predInit(ind)=2;
  end
end

%{
for i = 1:length(x_predInit)
   if(x_predInit(i)>1)
      if(rand>b_i(2,i))
          x_predInit(i)=3;
      else
          x_predInit(i)=2;
      end
   end
end
%}


%[~,x_pred] = max(bi2,[],1);
x_pred = reshape(x_predInit,sizr,sizc);

end

