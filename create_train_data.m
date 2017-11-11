clear;
close all;

%settings
scale = 4;


folder = 'Source1';   % 91 images
mkdir(['Images1\Train_' num2str(scale) 'H']);   % The path for HR training images
mkdir(['Images1\Train_' num2str(scale) 'L']);   % The path for LR training images
savepath1 = ['Images1\Train_' num2str(scale) 'H'];
savepath2 = ['Images1\Train_' num2str(scale) 'L'];

filepaths = dir(fullfile(folder,'*.bmp'));  % *.bmp
numfile = length(filepaths);
numdigit = numel(num2str(numfile));

for i=1:numfile
    image = imread(fullfile(folder,filepaths(i).name));
    image = rgb2ycbcr(image);
    image = im2double(image(:, :, 1));
    
    %crop image
    sz = size(image);
    sz = sz - mod(sz, scale);
    imageH = image(1:sz(1), 1:sz(2));
    
    imageL = imresize(imageH,1/scale,'bicubic');
    
    sname = num2str(i,['%0',num2str(numdigit),'.0f']);
    
    imwrite(imageH, fullfile(savepath1,['H' num2str(scale) sname '.bmp']));
    imwrite(imageL, fullfile(savepath2,['L' num2str(scale) sname '.bmp']));
    %display(['image ' num2str(i)]);
end
