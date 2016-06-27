%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% matlab code for feature extraction of the segmented cloud 
% Usage: 
%   %F = get_cloud_ir_feature(ir, l, e, g,THD);
%   ir cloud image; l: labeledcloud region; e: edge map; g: interested #region; 
%   rr: corresponding ground rianfall map 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function F = ccs_getFeature(ir, l253, g,NUM_FEATURE, SIZE, row, col);


%calculate the THD 253 level feature; 
[XX,YY]=find( l253==g ); I=(YY-1)*row + XX;Count = length(I); IR=ir(I);
F=zeros(1,NUM_FEATURE);
%% radiance, physical features
Tmin=min(IR);
Tstd253 = std(IR);
Tmean253=mean(IR);
%%%%%%%%%%%%%geometric features%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Area253 = length(I);% Perimeter = length(EX);


if (Count<=50)
    F(1)=Tmin;F(2) = Tmean253; F(3) = Tmean253; F(4) = Area253; F(8) = Tstd253; F(12) =20;
    return;
end

%coldest top center   
cdij=find(IR==Tmin); cdx=XX(cdij(1)); cdy=YY(cdij(1));
 [N, I, J, k]=getwindow_array(row, col, cdx, cdy,SIZE);
 if (k>0) TGsd=std(ir(N)); else TGsd=0; end

STD=zeros(1,Count);

%Texture features: STDmean, STDstd%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for i= 1: 1: Count
      [N,I,J,k]=getwindow_array(row, col, XX(i), YY(i),SIZE);
      if (k>0) STD(i) = std(ir(N)); else STD(i)=0; end
  end
  STDmean253 = mean (STD) ; STDstd253 = std(STD);

%calculate the 235 level
n=find(IR<=235); XX=XX(n);YY=YY(n); I=(YY-1)*row + XX; LG=length(I); IR=IR(n);
if LG<=0 Area235=0; ShID235=20; Tstd235=0; Tmean220=Tmean253;
 F(1)=Tmin;
 F(2) = Tmean253;
 F(3) = Tmean253;
 F(4) = Area253; 
 F(5) = 0;
 F(6) = 0;
 F(7) = 0;
 F(8) = Tstd253;
 F(9) = 0;
 F(10) = STDmean253;
 F(11) = STDstd253;
 F(12) =20;
 return;
    
else
    Area235=LG;
    Tstd235=std(IR);
    Tmean235=mean(IR);
    
    %% Shape Index: value range=[1 ?); the closer to 1, the closer to circle;0 indicates non physical meaning
     % shape paramters %%%%%%% geometric center of cloud patch:  ctx,cty.
    if LG>20
        ctx=ceil( sum(XX)/Area235 ); cty=ceil( sum(YY)/Area235 );
        SI=sum( (XX-ctx).^2 + (YY - cty).^2 ); R = floor( sqrt( (Area235/pi) ) ); R2=R^2;
        SI0=0;
        for xi = ctx-R: ctx+R;
            for yi = cty-R: cty+R
                I0= (xi-ctx)^2 + (yi-cty)^2 ;
                if( I0  <= R2 )   SI0 = SI0 + I0; end
            end
        end
        SI235=SI/SI0;
    else
        SI235=20;
    end
    
end

%for 220 level
n=find(IR<=220);XX=XX(n);YY=YY(n); I=I(n); IR=IR(n);LG=length(I);
if LG<=0 Area220=0; Tmean220=Tmean235;
else
    Area220=LG;
    Tmean220=mean(IR);
end

%%assign the feature to a F array;
 F(1)=Tmin;
%%%%physical features
 F(2) = Tmean253;
 F(3) = Tmean220;
%%%%%geometric features: size
 F(4) = Area253; 
 F(5) = Area235;
 F(6) = Area220;
%%%%Texture features
 F(7) = TGsd;
 F(8) = Tstd253;
 F(9) = Tstd235;
 F(10) = STDmean253;
 F(11) = STDstd253;
%%%%%geometric features: shape
 F(12) =SI235;
