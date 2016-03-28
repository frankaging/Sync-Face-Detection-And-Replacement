function [mask,landmark_dest] = obtain_mask(img_replace, img)
%% FACE_REPLACEMENT_WRAPPER
% This function takes in the two images: the replacement face and target
% face in the current frames, and outputs the mask region as long as landmark information of target face in
% the current frame.

% img_replace: replacement face
% img: current frame with the target face 
% mask: mask region around the target face in the current frame
% landmark_dest: landmark index of target face in the current frame

API_KEY = 'b350dd171464dd033ee52bdab2873124';
API_SECRET = 'eq8tFwSfx70I06ZSztDUCvM0VjjM4RF0';

api = facepp(API_KEY, API_SECRET);

% Get landmark info for input replacement face
[facerec_src,landmark_src, len_src_faces, pt] = getLandmark(api,img_replace,1);

% Get landmark info for target face in the video
try
    [facerec_dest,landmark_dest, len_dest_faces, pt] = getLandmark(api,img,1);
catch
    warning('Could not detect face(s)')
    img_result = imread(img);
    return
end

img_replace = im2double(imread(img_replace));
img = im2double(imread(img));
imwrite(img, 'trial.jpg');

%Since we need to replace only 3 faces
if len_dest_faces > 5
    len_dest_faces = 5;
end

for iter = 1:len_dest_faces
    %Get landmarks for each face
    landmark_dest2 = landmark_dest(1+((iter-1)*83):iter*83,:);
    %% Apply TPS Morphing
    img = im2double(imread('trial.jpg'));
    warp_frac=1;% value 1 denoting: control points all comes from img2, the target face in the video
    dissolve_frac=0.5; % value 0 denoting: 100% percent from replacement face;
    img_morphed = morph_tps_wrapper(img_replace*255, img*255, landmark_src(1:83,:), landmark_dest2, 1, 0);

    [img_proc,mask] = defineRegion(img,landmark_dest2);%,facerec_dest)
    img_morphed = img_morphed(1:size(img,1),1:size(img,2),:);    
    img_morphed = im2double(img_morphed);
    
    
    % Refine the mask of face in the video
    img_morphed_proc = histeq_rgb(img_morphed, img, mask, mask);
    sigma = round(1/15 * (facerec_dest(3)-facerec_src(1)));
    sigma = max(sigma,5);
    se = strel('square',sigma);
    mask = imerode(mask,se);
    
    w = fspecial('gaussian',[50 50],sigma);
    mask = imfilter(double(mask),w);
%     figure(5),imshow(maskvideo);
     
%     img_result = bsxfun(@times,double(img_morphed_proc),double(mask)) + bsxfun(@times,double(img2),double(1-mask));
%     figure(6),imshow(img_result);
%     img2 = uint8(img_result*255);
%     imwrite(img2, strcat('./easy3result/',num2str(i),'.jpg'));
%     clear img_morphed img_proc mask img_morphed_proc sigma se mask w mask

%%
% if isa(img_result, 'double')
%    img_result = uint8(img_result*255);
% end

%% Updated_With_Poisson_Laplace_Editing
% load img_morphed.mat
% load maskvideo.mat    % mask obtained from target face in video

% img1 = im2double(imread(img1));
% img2 = im2double(imread(img2));

% SourceIm    = im2uint8(img_morphed);  % morphed replacement face,convert to uint8
% TargIm      = im2uint8(img2); % target face in video,convert to uint8
% SourceMask  = uint8(mask); % convert to uint8
% % SourceMask  = rgb2gray(imread('R.jpg'));
% mask_thresh = graythresh(SourceMask);% Using Otsu's threshold segmentation to weed out Jpeg artifacts
% SourceMask  = SourceMask > mask_thresh*max(SourceMask(:)); % convert to logic

%% Show Source image where we are cutting from
% [SrcBoundry, ~] = bwboundaries(SourceMask, 4);
% % figure, imshow(SourceIm), axis image
% hold on
% for k = 1:length(SrcBoundry)
%     boundary = SrcBoundry{k};
%     plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
% end
% title('Source image - for cutting from');


%% calculate shifts required between two faces 
% shift_in_target_image = [0, 0];
% % %calc bb of mask
% [TargImRows, TargImCols, ~] = size(TargIm);
% MaskTarg = calc_mask_in_targ_image(SourceMask, TargImRows, TargImCols, shift_in_target_image);
% MaskTarg = mask;
% TargBoundry = bwboundaries(MaskTarg, 4);

%% Show where we are going to paste
% figure, imshow(TargIm), axis image
% hold on
% for k = 1:length(TargBoundry)
%     boundary = TargBoundry{k};
%      plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
% end
% title('Target Image with intended place for pasting Source');

%% paste Laplacian of source into Target image
% load SourceIm
% load TargIm
% load maskvideo
% SourceIm = im2uint8(SourceIm);
% TargIm = im2uint8(TargIm);
% SourceMask= logical(mask);
% shift_in_target_image=[0,0];
% [MaskTarg, TargImPaste] = paste_source_into_targ(SourceIm, TargIm, SourceMask, shift_in_target_image);
% figure, imagesc(uint8(TargImPaste)), axis image, title('Target image with laplacian of source inserted');

%% Solve POisson equations in target image wihtihn masked area
% TargFilled = PoissonColorImEditor(TargImPaste, MaskTarg);

%% Show end results
% figure;
% subplot(1, 2, 1)
% imshow(SourceIm), axis image
% hold on
% for k = 1:length(SrcBoundry)
%     boundary = SrcBoundry{k};
%     plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
% end
% title('Source Image with intended place for cutting from');
% subplot(2, 2, 2)
% imshow(TargIm), axis image
% hold on
% for k = 1:length(TargBoundry)
%     boundary = TargBoundry{k};
%     plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
% end
% title('Target Image with intended place for pasting Source');
% subplot(2, 2, 4)
% imshow(uint8(TargFilled));
% axis image
% title('Final result')

%% save the result
% img_result=uint8(TargFilled);
% imwrite(img_result, strcat('./easy1result/',num2str(i),'.jpg'))
end
end