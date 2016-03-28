function im_morphed = morph_tps_wrapper(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac)

[rows1, cols1, temp] = size(im1);
[rows2, cols2, temp] = size(im2);

rows = max(rows1, rows2); 
cols = max(cols1, cols2);
im1_pad = padarray(im1, [rows-rows1, cols-cols1], 'replicate', 'post');
im2_pad = padarray(im2, [rows-rows2, cols-cols2], 'replicate', 'post');


% Get intermediate shape
imwarp_pts = (1 - warp_frac) * im1_pts + warp_frac * im2_pts;

% Get the TPS model
[a1_x, ax_x, ay_x, w_x] = est_tps(imwarp_pts, im1_pts(:,1));
[a1_y, ax_y, ay_y, w_y] = est_tps(imwarp_pts, im1_pts(:,2));

% Get warped image 1
im1_warp = morph_tps(im1_pad, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, imwarp_pts, [rows, cols]);


[a1_x, ax_x, ay_x, w_x] = est_tps(imwarp_pts, im2_pts(:,1));
[a1_y, ax_y, ay_y, w_y] = est_tps(imwarp_pts, im2_pts(:,2));

% Get warped image 2
im2_warp = morph_tps(im2_pad, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, imwarp_pts, [rows, cols]);

% Cross Dissolve
im_morphed = (1-dissolve_frac) * im1_warp + dissolve_frac * im2_warp;
im_morphed = uint8(im_morphed);

end