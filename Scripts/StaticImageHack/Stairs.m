clear

across = 80;
down = 80;

% -----------------   Load the image and turn to grayscale ------------------------------

LennaIm = imread('/home/ashley/Electronics/HoughTransform/Scripts/StaticImageHack/Stairs.jpg'); % Load
LennaGray = mean(LennaIm,3);
LennaSmall = imresize(LennaGray,0.2);
LennaDone = round(LennaSmall);
imshow(LennaDone, [0 256])

filename = '/home/ashley/Electronics/HoughTransform/Verification/Simulation/Stairs.dat';
fid = fopen (filename, "w");

for i=1:across
   for j=1:down
      fprintf(fid,'%d\n',LennaDone(i,j));
   end
end

 fclose (fid);

