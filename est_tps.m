%% TPS Morphing function Directly Adopted From Proj. 2.

function  [a1, ax, ay, w] = est_tps(ctr_pts, target_value)
% This function returns the TPS coeffcients

size_ctr_pts = size(ctr_pts, 1);

%Functions

U = @(r) -r.* log(r);
mat_diff = @(vector) repmat(vector, 1, size_ctr_pts) - transpose(repmat(vector, 1, size_ctr_pts));


% TPS parameter matrices

K = U(mat_diff(ctr_pts(:,1)).^2 + mat_diff(ctr_pts(:,2)).^2);
K(isnan(K)) = 0;
v = [target_value; zeros(3,1)];
P = [ones(size_ctr_pts, 1), ctr_pts];
A = [K P; P', zeros(3)];


% Compute coefficients

tps_coefficients = (A + eps * eye(size_ctr_pts + 3))\v;

ax   = tps_coefficients(size_ctr_pts+2);
ay   = tps_coefficients(size_ctr_pts+3);
a1   = tps_coefficients(size_ctr_pts+1);
w    = tps_coefficients(1:size_ctr_pts);

end