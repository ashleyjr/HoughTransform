clear

across = 80;
down = 80;

filename = '/home/ashley/Electronics/HoughTransform/Verification/Simulation/OutputImage.dat';
fid = fopen (filename, "r");
for i=1:across
   for j=1:down
      Image(i,j) = str2double(fgetl(fid));
   end
end
imshow(Image, [0 256])
fclose (fid);

