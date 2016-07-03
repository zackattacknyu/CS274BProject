function [  ] = displayTargetPredProb( x_pred, curTargetLabels,curProb3wholeMap )
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
subplot(1,3,1)
imagesc(labelsDisp);
title('Target Precipitation Image');
%caxis([-1 20]) 
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
%colorbar('vertical')

subplot(1,3,2);
imagesc(curProb3wholeMap); 
title('Probability of Precipitation');
colorbar; 
colormap jet;
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
colorbar('vertical')

subplot(1,3,3)
imagesc(x_predDisp);
title('Predicted Precipitation Image');
%caxis([-1 20]) 
drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
%colorbar('vertical')

drawnow
end

