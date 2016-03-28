%% This demo is used to output all frames
clc;clear all;
genpath('.');
% input replacement face
img_replace = 'Gf1.JPG';

% import the video and segment into couple pictures
source='Proj4_Test/easy/easy3.mp4'; % Modify your path here

% segmentations
vidobj=VideoReader(source);
frames=vidobj.Numberofframes;
for f=1:frames-1
  thisframe=read(vidobj,f);
  figure(1);imagesc(thisframe);
  thisfile=sprintf('Test_img/easy_test/image%d.jpg',f);
  imwrite(thisframe,thisfile);
end

% target face in video
fileName =  './Test_img/easy_test/image';
% define the folder to save the output result
saveName = './Results/Results_Final/';

%     ImgName = [fileName,num2str(i),'.jpg'];
%     img1 = strcat(fileName,num2str(j),'.jpg');
%     img2 = strcat(fileName,num2str(i),'.jpg');
%     img3 = strcat(fileName,num2str(k),'.jpg');

%Set the parameters, 
num=frames-1;% num is the number of frames in a videoc
len_dest_faces =frames-1; % num is the max number of faces in a video
% create a matrix to save error info
wrong=zeros(num,1);

%% Get landmark of replacement face

% API access serive of Face++
API_KEY = 'b350dd171464dd033ee52bdab2873124';
API_SECRET = 'eq8tFwSfx70I06ZSztDUCvM0VjjM4RF0';

api = facepp(API_KEY, API_SECRET);

% getLandmark function which will read as Java script and then turn it in
% to matlab matrix
[facerec_src,landmark_src, len_src_faces, pt] = getLandmark(api,img_replace,1);

%% Get landmark of target faces
% The goal here is to first generate a code-book for all the landmark for
% each frame. Because in this way, we can then eliminating the shaking by
% adding motion compensation into it.

% generate a cell to save the landmark info
landmark_info=cell(num,1);

for m=1:num;
    
    imga = strcat(fileName,num2str(m),'.jpg');
    % Get landmark info for target face of previous frame in the video
    try
        [facerec_dest,landmark_dest, len_dest_faces, pt] = getLandmark(api,imga,m);
        landmark_info{m,1}=landmark_dest;
        
    catch
        disp(['Failed for get landmark, frame :', num2str(m)]);
        landmark_info{m,1} = landmark_info{m-1,1};% if failed, assign the landmark of previous frame to this value
        
        %return
    end
    close all
end
save landmark_info

% need to reinstate this variable
len_dest_faces =2; % num is the max number of faces in a video

for i=1:num; %loop for every frame 
    img2 = strcat(fileName,num2str(i),'.jpg');
    if i==1 || i==2;j=1;k=1;l=1;m=1;% if it is the first frame, then consider its previous landmark as the same as the current one to morph
    else if i==num || i==num-1;j=i;k=i;l=i;m=i;% if it is the last frame, then consider its following landmark as the same as the current one to morph
        else j=i-1; k=i+1; l=i-2; m=i+2;% if it is not the first frame, then use the medium landmark between the previous,current and following frames to morph
        end;
    end
    % load landmark_info
    landmark_dest_prepre=landmark_info{l,1};
    landmark_dest_pre=landmark_info{j,1};
    landmark_dest_current=landmark_info{i,1};
    landmark_dest_follow=landmark_info{k,1};
    landmark_dest_followfollow=landmark_info{m,1};
    % check to see if the dimension agree
    if size(landmark_dest_pre,1) == size(landmark_dest_current,1) && size(landmark_dest_current,1) == size(landmark_dest_follow,1) && size(landmark_dest_prepre,1) == size(landmark_dest_pre,1) && size(landmark_dest_follow,1) == size(landmark_dest_followfollow,1)
        
        % making sure the order of the landmark in those three matrixs are
        % the same
        [landmark_dest_prer,landmark_dest_currentr,landmark_dest_followr,landmark_dest_preprer, landmark_dest_followfollowr]  = checkOrder(landmark_dest_pre,landmark_dest_current,landmark_dest_follow,landmark_dest_prepre,landmark_dest_followfollow);
        
        % smooth out the landmarks
        landmark= 0.25*landmark_dest_preprer + 0.25*landmark_dest_prer+0*landmark_dest_currentr+0.25*landmark_dest_followr + 0.25*landmark_dest_followfollowr;
        
    else
        landmark= landmark_dest_current;
    end
    
    % define the landmark as the medium position between the previous,current and
    % following frames
    len_dest_faces = 1;
    try
    [img_result] = face_replacement( img_replace,img2,landmark,landmark_src,len_dest_faces,facerec_dest,facerec_src);
    catch
        disp(['Failed for morph and blending, frame :', num2str(i)]);
    end
    % output the image
    imwrite(img_result, strcat(saveName,num2str(i),'.jpg'))
    
    close all;
end

save wrong

%% Output video
num=frames-1;
genpath('.');
myObj = VideoWriter('result_video.avi');
writerObj.FrameRate = 30;
open(myObj);
for t=1:num; 
    fname=strcat(saveName,num2str(t),'.jpg');
    frame = imread(fname);
    writeVideo(myObj,frame);
end 
close(myObj);

