clc;
clear;
close all;

scale = 2 ;
load(['parameters1\parameter_' num2str(scale)]);
load(['parameters1\dt_' num2str(scale)]);
 
image=im2double(imread('Test\Set14\zebra.bmp'));
% image=im2double(imread('Test\Set14\ppt3.bmp'));
% image=im2double(imread('Test\Set14\pepper.bmp'));
% image=im2double(imread('Test\Set14\monarch.bmp'));
% image=im2double(imread('Test\Set14\man.bmp'));
% image=im2double(imread('Test\Set14\lenna.bmp'));
% image=im2double(imread('Test\Set14\foreman.bmp'));
% image=im2double(imread('Test\Set14\flowers.bmp'));
% image=im2double(imread('Test\Set14\face.bmp'));
% image=im2double(imread('Test\Set14\comic.bmp'));
% image=im2double(imread('Test\Set14\coastguard.bmp'));
% image=im2double(imread('Test\Set14\bridge.bmp'));
% image=im2double(imread('Test\Set14\barbara.bmp'));
% image=im2double(imread('Test\Set14\baboon.bmp'));
 
% image=im2double(imread('Test\Set5\baby_GT.bmp'));
% image=im2double(imread('Test\Set5\bird_GT.bmp'));
% image=im2double(imread('Test\Set5\butterfly_GT.bmp'));
% image=im2double(imread('Test\Set5\head_GT.bmp'));
% image=im2double(imread('Test\Set5\woman_GT.bmp'));

% image=im2double(imread('Images1\Train_2H\H207.bmp'));

% H_15 = [8 2 10 3 12 1 4 6 9 11 14 15 13 7 5];
H_15 = [8 2 3 12 10 1 4 11 14 6 9 15 13 7 5];

sz = size(image);
if(size(sz,2)==2)
        
else
    image = rgb2ycbcr(image);
end
    
image = im2double(image(:, :, 1));
image = modcrop(image,scale);

imageL = imresize(image,1/scale,'bicubic');
imageB = imresize(imageL,scale,'bicubic');
% figure('NumberTitle', 'off', 'Name', 'Low');
% imshow(imageL,'Border','tight');

imageH=zeros(scale*size(imageL));

H_16=hadamard( 16 );
  
H_16(:,1) =[]; 

    sz = size(imageL);
    imagepadding = zeros(sz(1)+2,sz(2)+2);
    imagepadding(2:end-1,2:end-1) = imageL;

    offset = floor( scale / 2 );
    
    startt = tic;
    
    for ii = 2 : sz( 1 ) - 2
        for jj = 2 : sz( 2 ) - 2
            LRblock = imagepadding( ii : ii + 3, jj : jj + 3 );          
            LRB=reshape( LRblock, [ 1, 16 ] );
             
            pattern = LRB * H_16; 
            
            %L = judge;
            
            ptr =1;
            m = dt(ptr,1);
            while(m~=0)
               val = pattern(1,H_15(1,m));
               if val<dt(ptr,5)
                   ptr = dt(ptr,2);
               elseif val>dt(ptr,6)
                   ptr = dt(ptr,4);
               else
                   ptr = dt(ptr,3);
               end
               m=dt(ptr,1);              
            end
            n = dt(ptr,2);
            
            HRB = parameters(:,:,n)*LRB';
            HRB = min(max(HRB,0),1);
            
            
            imageH( ( ii - 1 ) * scale + offset + 1 : ii * scale + offset,...
                ( jj - 1 ) * scale + offset + 1 : jj * scale + offset )...
                    = reshape( HRB, [ scale, scale ] );

        end
    end

toc(startt);

    
  if(mod(scale,2) == 0)
      imageB = imageB( offset + scale + 2 + 3 : end - ( offset + scale + 1  + 3 ),...
          offset + scale + 2  + 3 : end - ( offset + scale + 1  + 3 ) );
      imageH = imageH( offset + scale + 2  + 3 : end - ( offset + scale + 1  + 3 ),...
          offset + scale + 2  + 3 : end - ( offset + scale + 1  + 3 ));
      image  = image(offset + scale + 2  + 3 : end - ( offset + scale + 1  + 3 ),...
          offset + scale + 2  + 3 : end - ( offset + scale + 1  + 3 ));
      p1 = compute_psnr(image,imageB); % Bicubic
      p2 = compute_psnr(image,imageH); % Our
      s1 = ssim(image,imageB); % Bicubic
      s2 = ssim(image,imageH); % Our

  else
      imageB = imageB( offset + scale + 2  + 5 : end - ( offset + scale + 2  + 5 ),...
          offset + scale + 2  + 5 : end - ( offset + scale + 2  + 5 ) );
      imageH = imageH( offset + scale + 2  + 5 : end - ( offset + scale + 2  + 5 ),...
          offset + scale + 2  + 5 : end - ( offset + scale + 2  + 5 ) );
      image  = image( offset + scale + 2  + 5 : end - ( offset + scale + 2  + 5 ),...
          offset + scale + 2  + 5 : end - ( offset + scale + 2  + 5 ) );
      p1 = compute_psnr(image,imageB); % Bicubic
      p2 = compute_psnr(image,imageH); % Our
      s1 = ssim(image,imageB); % Bicubic
      s2 = ssim(image,imageH); % Our
  end


% figure('NumberTitle', 'off', 'Name', 'Bicubic');
% imshow(imageB,'Border','tight');
% figure('NumberTitle', 'off', 'Name', 'Our Propose Method');
% imshow(imageH,'Border','tight');
%kk
% display(['Bicubic PSNR ' num2str(p1)]);
display(['Our     PSNR ' num2str(p2)]);
% display(['Bicubic SSIM ' num2str(s1)]);
% display(['Our     SSIM ' num2str(s2)]);

%end

% imwrite(image,'results\butterfly_GT_ori.bmp');
% imwrite(imageH,'results\butterfly_GT_our.bmp');