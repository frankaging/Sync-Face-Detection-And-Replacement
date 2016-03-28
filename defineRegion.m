function [img_proc,mask] = defineRegion(img, landmark)

sz = size(img);

k =convhull(landmark(:,2),landmark(:,1));

[YY,XX] = meshgrid(1:sz(1),1:sz(2));
in = inpolygon(XX(:),YY(:),landmark(k,1),landmark(k,2));

mask = reshape(in,[sz(2),sz(1)])';

img_proc = bsxfun(@times,im2double(img),double(mask));
