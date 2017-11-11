%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  4x4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
close all;

scale = 4 ;

min_num = 128*2;
v = 0.7; 

startt = tic;

folder1 =['Images1\Train_' num2str(scale) 'L'];
folder2 =['Images1\Train_' num2str(scale) 'H'];
filepaths = dir(fullfile(folder1,'*.bmp'));

% Counting the number of block2
numfile = length(filepaths);
numdigit = numel(num2str(numfile));

numblock = 0;
for i=1:numfile
    sname = num2str(i,['%0',num2str(numdigit),'.0f']);
    imageL = imread(fullfile(folder1,['L',num2str(scale),sname,'.bmp']));
    sz = size(imageL);
    numblock = numblock + (sz(1)-3)*(sz(2)-3);     
end

%Initialisation matrices, including rotating 90, 180, 270 degrees
LR = zeros(numblock, 16); % low resolution data
HR = zeros(numblock, scale*scale); % high resolution data

%Assign matrices
offset = floor(scale/2);
pointer = 1;
for i = 1:numfile
    sname = num2str(i,['%0',num2str(numdigit),'.0f']);
    imageL = imread(fullfile(folder1,['L',num2str(scale),sname,'.bmp']));
    imageL = im2double(imageL);
    imageH = imread(fullfile(folder2,['H',num2str(scale),sname,'.bmp']));
    imageH = im2double(imageH);
    sz = size(imageL);
    imagepadding = zeros(sz(1)+2,sz(2)+2);    
    imagepadding(2:end-1,2:end-1) = imageL;

    for ii = 2:sz(1)-2 
        for jj = 2:sz(2)-2 
            LRblock = imagepadding( ii : ii + 3, jj : jj + 3 );
            HRblock = imageH( ( ii - 1 ) * scale + offset + 1 : ii* scale + offset,...
                ( jj - 1 )*scale+offset+1 : jj*scale+offset);
            
            LR(pointer,:)=reshape(LRblock,[1,16]);
            HR(pointer,:)=reshape(HRblock,[1,scale*scale]);

            pointer = pointer+1;
            
        end
    end 
    display(['file ' num2str(i)]);
end


lr{1,1} = LR;
hr{1,1} = HR;

% H_15 = [8 2 10 3 12 1 4 6 9 11 14 15 13 7 5];
H_15 = [8 2 3 12 10 1 4 11 14 6 9 15 13 7 5];

i=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n0 = ceil(size(LR,1)/32); %   ??????????????
dt = zeros(5*n0,6); %Initialize memory space
lr1 = cell(n0,1); %store low resolution data
hr1 = cell(n0,1); %store high resolution data

ptr0 = 1; % the current line number of the parameter matrix 
ptr1 = 1; % the current line number of the decision tree 
ptr2 = 1; % the front line number of the decision tree 
sz = size(lr,1); % the size of the current level of the tree

while(i<=15)
    
    j = 1;
    while(j<=sz)
       if(size(lr{j,1},1)>=3*min_num)
           [lr{3*(j-1)+1+sz,1},lr{3*(j-1)+2+sz,1},lr{3*(j-1)+3+sz,1},...
           hr{3*(j-1)+1+sz,1},hr{3*(j-1)+2+sz,1},hr{3*(j-1)+3+sz,1},v1,v2]...
           = Ternary_Tree( lr{j,1},hr{j,1},H_15(i),v);            
           if(size(lr{3*(j-1)+2+sz,1},1)==0)
               lr{3*(j-1)+1+sz,1} =[];
               hr{3*(j-1)+1+sz,1} =[];
              % Leaf node
               dt(ptr1,1) = 0;
               dt(ptr1,2) = ptr0;
               lr1{ptr0} = lr{j,1};
               hr1{ptr0} = hr{j,1};
               ptr0 = ptr0 + 1;
               ptr1 = ptr1 + 1;
               %ptr2 = ptr2 + 1;
           else
               dt(ptr1,1) = i;
               dt(ptr1,2) = ptr2+1;
               dt(ptr1,3) = ptr2+2;
               dt(ptr1,4) = ptr2+3;
               dt(ptr1,5) = v1;
               dt(ptr1,6) = v2;
               ptr1 = ptr1 + 1;
               ptr2 = ptr2 + 3;
           end    
       else
           % Leaf node
           dt(ptr1,1) = 0;
           dt(ptr1,2) = ptr0;
           lr1{ptr0} = lr{j,1};
           hr1{ptr0} = hr{j,1};
           ptr0 = ptr0 + 1;
           ptr1 = ptr1 + 1;

       end
       j = j+1;
    end
   lr = lr(sz+1:end,1);
   hr = hr(sz+1:end,1);
   
   lr(cellfun(@isempty,lr)) = [];
   hr(cellfun(@isempty,hr)) = [];
   
   sz = size(lr,1);
   
   display(['The ' num2str(i) 'th segmentation !']);
   i = i+1;
end
j=1;
while(j<=sz)
   % Leaf node
   dt(ptr1,1) = 0;
   dt(ptr1,2) = ptr0;
   lr1{ptr0} = lr{j,1};
   hr1{ptr0} = hr{j,1};
   ptr0 = ptr0 + 1;
   ptr1 = ptr1 + 1;
   j=j+1;
end
   lr1(cellfun(@isempty,lr1)) = [];
   hr1(cellfun(@isempty,hr1)) = [];
dt = dt(1:ptr2,:);


% initialise as bicubic parameters
ptr0 = ptr0-1;
para = bicubicparameter(scale);
parameters = repmat(zeros(scale*scale,16), [1 1 ptr0]);
pointer = 0;
lambda = 0;
er_our = 0;
er_bic = 0;

for i = 1:ptr0 

        LRD = lr1{ i, 1 };   %  HRD/LRD
        HRD = hr1{ i, 1 };
        
%         close to bicubic 
        M = lambda * eye( 16 );
        M = M + LRD' * LRD ;
        M = [ M ones( 16, 1 ); ones( 1, 16 ), 0 ];
        B = LRD' * HRD;
        B = [ B; ones( 1, scale * scale ) ];
        para1 = M \ B;
        para1 = para1( 1 : 16, : );               
        parameters(:,:,i)=para1';   
        
          
end

toc(startt);


save(['parameters1\parameter_' num2str(scale)],'parameters');
save(['parameters1\dt_' num2str(scale)],'dt');