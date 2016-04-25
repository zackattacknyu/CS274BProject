function [  ] = viz( b_i )
%VIZ Summary of this function goes here
%   Detailed explanation goes here

N = size(b_i,1);
siz = 50;
% here, b_i is a cell array of size nvals X nvars
for n=1:N
    subplot(1,N,n    ); imshow(reshape(b_i{n}(2,:),siz,siz));
    %subplot(3,N,n+  N); imshow(reshape(feats{n}(:,1),siz,siz));
    %subplot(3,N,n+2*N); imshow(reshape(labels{n}-1,siz,siz));

end
xlabel('top: marginals  middle: input  bottom: labels')
drawnow

end

