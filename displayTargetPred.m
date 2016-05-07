function [  ] = displayTargetPred( x_pred, curTargetLabels )
%DISPLAYTARGETPRED Summary of this function goes here
%   Detailed explanation goes here

x_predDisp = x_pred; 
%x_predDisp(curTargetLabels<=1)=-1;
x_predDisp(x_pred<=2)=0;
x_predDisp(x_pred>=3)=2;

labelsDisp = curTargetLabels;
%labelsDisp(curTargetLabels<=1)=-1;
labelsDisp(curTargetLabels<=2)=0;
labelsDisp(curTargetLabels>=3)=2;


figure
subplot(1,2,1)
imagesc(labelsDisp);
title('Target Precipitation Image');
colormap([1 1 1;0.8 0.8 0.8;jet(20)])
caxis([-1 20]) 
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
colorbar('vertical')

subplot(1,2,2)
imagesc(x_predDisp);
title('Predicted Precipitation Image');
colormap([1 1 1;0.8 0.8 0.8;jet(20)])
caxis([-1 20]) 
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
colorbar('vertical')
drawnow
end

