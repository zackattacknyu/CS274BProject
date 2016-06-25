function [  ] = drawMapWithPatches( curImage ,randPatchesCornerCoord, patchSize )
%DRAWMAPWITHPATCHES 
%   Draws the US Precip Map with the Patches added
%   NOTE: NEEDS A FIGURE HANDLE FIRST

imagesc(curImage)
colormap([1 1 1;0.8 0.8 0.8;jet(20)])
caxis([-1 20]) 
drwvect([-135 25 -65 50],[625 1750],'us_states_outl_ug.tmp','k');
colorbar('vertical')
hold on
for i = 1:length(randPatchesCornerCoord)
   centerLoc = randPatchesCornerCoord{i};
   centerLoc = centerLoc - [patchSize/2 patchSize/2];
   rectangle('Position',[centerLoc(2) centerLoc(1) patchSize patchSize]);
end
hold off

end

