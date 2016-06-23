function [  ] = CURRENT_drawRegionPatches( curImage , cornerR, cornerC, sizR, sizC )
%DRAWMAPWITHPATCHES 
%   Draws the US Precip Map with the Patches added
%   NOTE: NEEDS A FIGURE HANDLE FIRST

imagesc(curImage)
colormap([1 1 1;0.8 0.8 0.8;jet(20)])
caxis([-1 20]) 
drwvect([-135 25 -65 50],[625 1750],'us_states_outl_ug.tmp','k');
colorbar('vertical')
hold on
for i = 1:length(cornerR)
   rectangle('Position',[cornerC(i) cornerR(i) sizC(i) sizR(i)],'EdgeColor','r');
end
hold off

end

