function [LR1,LR2,LR3,HR1,HR2,HR3,v1,v2] = Ternary_Tree( LR,HR,num,v )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Hadamard matrix 
H_16=hadamard(16);
H_16(:,1)=[];
pattern = LR*H_16;

[val,index] = sort(pattern(:,num));
LR_ = LR(index,:);
HR_ = HR(index,:);
pattern = pattern(index,:);

sz = size(pattern,1);
v1 = pattern(ceil(sz*(1-v)/2),num);
v2 = pattern(floor(sz*(1+v)/2),num);


% LR1 = LR_( 1 : ceil(sz*(1-v)/2), : );
% HR1 = HR_( 1 : ceil(sz*(1-v)/2), : );
% 
% LR2 = LR_( ceil(sz*(1-v)/2) + 1 : floor(sz*(1+v)/2), : );
% HR2 = HR_( ceil(sz*(1-v)/2) + 1 : floor(sz*(1+v)/2), : );
% 
% LR3 = LR_( floor(sz*(1+v)/2) + 1 : end, : );
% HR3 = HR_( floor(sz*(1+v)/2) + 1 : end, : );

sig = pattern(:,num)<v1;
LR1 = LR_(sig,:);
HR1 = HR_(sig,:);

LR_=LR_(~sig,:);
HR_=HR_(~sig,:);
pattern=pattern(~sig,num);

sig = pattern>v2;
LR3 = LR_(sig,:);
HR3 = HR_(sig,:);

LR2=LR_(~sig,:);
HR2=HR_(~sig,:);

sz = [size(LR1,1) size(LR2,1) size(LR3,1)];
len = min(sz);

if( len < 256 )
    LR1 = LR_;
    LR2 = [];
    LR3 = [];
    
    HR1 = HR_;
    HR2 = [];
    HR3 = [];
end

end

