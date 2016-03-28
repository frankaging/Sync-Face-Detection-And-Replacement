

function [finalMaskRef] = maskRefFun(img,oldmask)
% Mask 2 Making

I=img;
R=I(:,:,1);
G=I(:,:,2);
B=I(:,:,3);

% Transfer to color face region detection space
Y = double((0.257*R + 0.504*G + 0.098*B) +16);
Cb = double((0.148*R - 0.291*G + 0.439*B)+128);
Cr = double((0.439*R - 0.368*G - 0.071*B)+128);

mask = zeros(size(I,1),size(I,2));
for i = 1:size(I,1)
    for j = 1:size(I,2)
        
        if 128<Cb(i,j)&&Cb(i,j)<128.2&&128.05<Cr(i,j)&&Cr(i,j)<128.1
            mask(i,j) = 1;
        end
        
    end
end



L = bwlabeln(mask);
values = unique(L);
instances = histc(L(:),values);
[value, idx] = max(instances(2:end));
idx = idx + 1;
groupNum = values(idx);

secondMask = zeros(size(I,1),size(I,2));

for i = 1:size(I,1)
    for j = 1:size(I,2)
        if L(i,j) == groupNum
            secondMask(i,j) = 1;
        end 
    end
end


maskoutput2 = imfill(secondMask,'holes');
% Combining

% Checking the upper boundary
for i = 1:size(I,1)
    
    numOf1 = sum(oldmask(i,:) == 1);
    if numOf1 > 0
        upperBound = i;
        break;
    end
    
end



% Checking the lower boundary
for i = size(I,1):-1:1
       numOf1 = sum(oldmask(i,:) == 1);
    if numOf1 > 0
        lowerBound = i;
        break;
    end 
    
end


finalMask = zeros(size(I,1),size(I,2));

for i = upperBound:lowerBound
    finalMask(i,:) = oldmask(i,:);
end

for i = 1 :upperBound+30
    finalMask(i,:) = maskoutput2(i,:);
end


imshow(finalMask)

% Regrouping and refining


Lfinal = bwlabeln(finalMask);
values = unique(Lfinal);
instances = histc(Lfinal(:),values);
[value, idx] = max(instances(2:end));
idx = idx + 1;
groupNum = values(idx);

finalMaskRef = zeros(size(I,1),size(I,2));

for i = 1:size(I,1)
    for j = 1:size(I,2)
        if Lfinal(i,j) == groupNum
            finalMaskRef(i,j) = 1;
        end 
    end
end


finalMaskRef = imfill(finalMaskRef,'holes');

end










