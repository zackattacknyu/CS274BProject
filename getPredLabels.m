function [ x_pred ] = getPredLabels( b_i, cutoff,sizr,sizc)
%GETPREDLABELS Summary of this function goes here
%   Detailed explanation goes here

[~,x_predInit] = max(b_i,[],1);
for i = 1:length(x_predInit)
   if(x_predInit(i)>1)
       curBi = b_i(:,i);
       curBi = curBi./sum(curBi(2:3));
      if(curBi(2)<cutoff)
          x_predInit(i)=3;
      else
          x_predInit(i)=2;
      end
   end
end

%[~,x_pred] = max(bi2,[],1);
x_pred = reshape(x_predInit,sizr,sizc);

end

