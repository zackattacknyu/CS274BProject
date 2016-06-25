function [ randPatches, randPatchesCornerCoord, patchSum ] = ...
    getSampledPatches( curImage, patchSize, minDist, maxNumPatches, maxTries )
%GETSAMPLEDPATCHES gets patches
%   This samples patches from an image
%
%   curImage - image being sampled
%   patchSize - N by N patches are sampled with N being specified by this
%   minDist - the patch centers are all at least this far apart
%   maxNumPatches - most number of patches sampled
%   maxTries - most sampling attempts done

%ensures no nonzero elements
curImage(curImage<0)=0;

%octree is made to ensure distance is preserved
slotDist=minDist/2;
slots = zeros(floor(size(curImage)/slotDist)+1);


maxTotalPatches = numel(slots);
patchSum = zeros(1,maxTotalPatches);
randPatches = cell(1,maxTotalPatches);
randPatchesCornerCoord = cell(1,maxTotalPatches);

%gets indices using precip map as PDF
imageValues = curImage(:);

%makes the CDF so we can sample from the precip map
cdfX = cumsum(imageValues./sum(imageValues));

imgIndex=1;


for k = 1:maxTries %try to obtain the sample patches
    
    %finish is number of patches is up
   if(imgIndex>maxNumPatches)
      break; 
   end

    %sample a random location with pdf being the precip map
    curSample = find(rand<cdfX, 1 );
   [randStartRow,randStartCol] = ind2sub(size(curImage),curSample);
   
   %ensures entire patch will be in picture
   if(randStartRow-patchSize/2 < 1 || randStartRow+patchSize/2 > size(curImage,1))
      continue; 
   end
   if(randStartCol-patchSize/2 < 1 || randStartCol+patchSize/2 > size(curImage,2))
      continue; 
   end
  
   %{
   If location is in the same square as another sampled patch, then don't
      use this sample
   %}
   slotX = floor(randStartRow/slotDist)+1;
   slotY = floor(randStartCol/slotDist)+1;
   if(slots(slotX,slotY) > 0)
      continue; 
   end
   
   %{
   If the location test passes, there could still be nearby sampled
    patches, so this is done as a double check
   %}
   curLocation = [randStartRow randStartCol];
    isBad=false;
    for j=1:(imgIndex-1)
        iLoc = randPatchesCornerCoord{j};
        if(norm(curLocation-iLoc)<minDist)
           isBad=true;
           break;
        end
    end
    if(isBad)
       continue; 
    end
    
    %the square is now occupied
   slots(slotX,slotY)=1;

   %obtains the patch
   randPatch = curImage(...
       (randStartRow-patchSize/2):(randStartRow+patchSize/2-1),...
       (randStartCol-patchSize/2):(randStartCol+patchSize/2-1));

   %add the patch as long as there is some precip in it
   curPatchSum = sum(randPatch(:));
   if(curPatchSum > 0)
        patchSum(imgIndex) = curPatchSum;
        randPatches{imgIndex} = randPatch;
        randPatchesCornerCoord{imgIndex} = curLocation;
        imgIndex = imgIndex+1;
   end


end

%readjust the arrays
patchSum = patchSum(1:(imgIndex-1));
randPatches = randPatches(1:(imgIndex-1));
randPatchesCornerCoord = randPatchesCornerCoord(1:(imgIndex-1));

end

