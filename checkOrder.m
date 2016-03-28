function [pre,current,follow,prepre,followfollow]  = checkOrder(La,Lb,Lc,Ld,Le)

% passing in three arguments cooresponding to three landmark matrixs
faceNum = size(La,1)/83;

for i = 1:faceNum
    LaMean(i) = mean(La(1+((i-1)*83):i*83,1));
    LbMean(i) = mean(Lb(1+((i-1)*83):i*83,1));
    LcMean(i) = mean(Lc(1+((i-1)*83):i*83,1));
    LdMean(i) = mean(Ld(1+((i-1)*83):i*83,1));
    LeMean(i) = mean(Le(1+((i-1)*83):i*83,1));
end

% getting the sorted array with its idx
[~,id1] = sort(LaMean);
[~,id2] = sort(LbMean);
[~,id3] = sort(LcMean);
[~,id4] = sort(LdMean);
[~,id5] = sort(LeMean);

% sort the landmarks with grouping


landmark_dest_prex = [];
landmark_dest_currentx = [];
landmark_dest_followx = [];
landmark_dest_preprex = [];
landmark_dest_followfollowx = [];


landmark_dest_prey = [];
landmark_dest_currenty = [];
landmark_dest_followy = [];
landmark_dest_preprey = [];
landmark_dest_followfollowy = [];

for i = 1:faceNum
    landmark_dest_prex = [landmark_dest_prex;[La(1+((id1(i)-1)*83):id1(i)*83,1)]];
    landmark_dest_prey = [landmark_dest_prey;[La(1+((id1(i)-1)*83):id1(i)*83,2)]];
    landmark_dest_currentx = [landmark_dest_currentx;[Lb(1+((id2(i)-1)*83):id2(i)*83,1)]];
    landmark_dest_currenty = [landmark_dest_currenty;[Lb(1+((id2(i)-1)*83):id2(i)*83,2)]];
    landmark_dest_followx = [landmark_dest_followx;[Lc(1+((id3(i)-1)*83):id3(i)*83,1)]];
    landmark_dest_followy = [landmark_dest_followy;[Lc(1+((id3(i)-1)*83):id3(i)*83,2)]];
    landmark_dest_preprex = [landmark_dest_preprex;[Ld(1+((id4(i)-1)*83):id4(i)*83,1)]];
    landmark_dest_followfollowx = [landmark_dest_followfollowx;[Le(1+((id5(i)-1)*83):id5(i)*83,1)]];
    landmark_dest_preprey = [landmark_dest_preprey;[Ld(1+((id4(i)-1)*83):id4(i)*83,2)]];
    landmark_dest_followfollowy = [landmark_dest_followfollowy;[Le(1+((id5(i)-1)*83):id5(i)*83,2)]];

end

pre(:,1) = landmark_dest_prex;
current(:,1) = landmark_dest_currentx;
follow(:,1) = landmark_dest_followx;
prepre(:,1) = landmark_dest_preprex;
followfollow(:,1) = landmark_dest_followfollowx;

pre(:,2) = landmark_dest_prey;
current(:,2) = landmark_dest_currenty;
follow(:,2) = landmark_dest_followy;
prepre(:,2) = landmark_dest_preprey;
followfollow(:,2) = landmark_dest_followfollowy;

end