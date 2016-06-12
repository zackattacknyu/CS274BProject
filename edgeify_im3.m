function [feats] = edgeify_im3(im,pairs)

% F = edgeify_im(im,{{'patches',2},{'hog',32}});
% take a ly x lx image and return a lz x npairs image of features
%
% pairtypes (which must be last) takes all the previously existing
% features, and multiplies them by an indicator function for each possible
% pairtype (must be provided as third input).  This is useful, for example,
% to have separate parameters for vertical and horizontal links.

nthresh = 10;

[ly lx] = size(im);

nfeat = 0;

npairs = size(pairs,1);
feats = zeros(npairs,nfeat);

feats(:,1) = ones(1,npairs);

feats(:,2) = im(pairs(:,1));
feats(:,3) = im(pairs(:,2));