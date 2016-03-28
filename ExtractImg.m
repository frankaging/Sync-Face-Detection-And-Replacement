source='Proj4_Test/easy/easy1.mp4';
vidobj=VideoReader(source);
frames=vidobj.Numberofframes;
for f=1:frames-1
  thisframe=read(vidobj,f);
  figure(1);imagesc(thisframe);
  thisfile=sprintf('Test_img/easy_test/image%d.jpg',f);
  imwrite(thisframe,thisfile);
end