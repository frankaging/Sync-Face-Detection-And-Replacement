
%% Function for Hist-equalization Blending Effect For Images
function img_proc = histeq_rgb(img_src, img_dest, mask_src, mask_dest)
% img_src : blending-to image
% img_dest : blending-from iamge
% mask_src/mask_dest : the face region for doing hist_equalization


img_proc = img_src;
for i = 1 : 3
    tmp_src = img_src(:,:,i);
    tmp_src = tmp_src(mask_src);
    tmp_dest = img_dest(:,:,i);
    tmp_dest = tmp_dest(mask_dest);
    t = histeq(tmp_src,imhist(tmp_dest));
    tmp_proc = img_proc(:,:,i);
    tmp_proc(mask_src) = t;
    img_proc(:,:,i) = tmp_proc;
end