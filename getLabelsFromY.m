function [ curLabelsUse ] = getLabelsFromY( curY,noLabelInds )
%GETLABELSFROMY Summary of this function goes here
%   Detailed explanation goes here

[sizr,sizc] = size(curY);
curLabelsUse = ones(sizr,sizc);

% 1 WILL MEAN NO PREDICTION
% AND 2 WILL MEAN NO RAIN
%   AND 3 WILL MEAN RAIN

curLabelsUse(curY<1)=2;
curLabelsUse(curY>=1)=3;
curLabelsUse(noLabelInds)=1;

end

