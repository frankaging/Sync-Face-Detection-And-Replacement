function morphed_im = morph_tps(im_source, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, ctr_pts, sz)

rows = sz(1);
cols = sz(2);
[srows, scols, temp] = size(im_source);

im_pad = padarray(im_source, [rows-srows, cols-scols], 'replicate', 'post');

source_indices = [zeros(2, rows * cols); ones(1, rows * cols)];

size_ctr_pts = size(ctr_pts, 1);

dest_im_indices = [repmat(1:cols, 1, rows); reshape(repmat(1:rows, cols, 1), [1 rows*cols]);];

%Target image initilization
morphed_im = zeros(rows, cols, 3);

% Compute TPS coeffs and model
mat_diff   = @(vector, ctrl_pts_col) bsxfun(@minus, ctrl_pts_col, repmat(vector, size_ctr_pts, 1));
r = mat_diff(dest_im_indices(1,:), ctr_pts(:,1)).^2 + mat_diff(dest_im_indices(2,:), ctr_pts(:,2)).^2 + eps;
U = -r.* log(r);
source_indices(1:2, :)= bsxfun(@plus, [a1_x ;a1_y], [ax_x, ay_x; ax_y, ay_y] * dest_im_indices + [w_x'; w_y'] * U);
source_indices = round(bsxfun(@rdivide, source_indices, source_indices(end, :)));
source_indices = bsxfun(@min, bsxfun(@max, source_indices, [1 1 1]'), [cols, rows, 1]');

for i = 1 : rows*cols
    
    %Iterate through each pixel
    morphed_im(dest_im_indices(2, i), dest_im_indices(1, i), :) = im_pad(source_indices(2, i), source_indices(1, i), :);
    
end

end