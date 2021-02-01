clear all
close all
%%%%%%%%%%%%%%%%%%%%%  user parameters
     pausetime=0.1; % pause time to see how th program works
     r0=8;        % distance between tracking poit: at least 3-5 times bigger than the filament diameter
     smfactor=0.6; % smothing factor 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
currentFolder = pwd;
[file,Folder] = uigetfile('*.tif'); % select a tif image or a stack
       fullFileName = [Folder,file];
      InfoImage=imfinfo(fullFileName);
      NumberImages=length(InfoImage);
      im0(:,:,1) = imread(fullFileName,'Index',1);
 for j=1:NumberImages
          im0(:,:,j) = imread(fullFileName,'Index',j);
 end
       [~,sx0,~]=size(im0); 
       imxy0=im0*(220/mean(mean(sum(im0,3)))); % adjust intensity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% rotata image 
       imshow(uint8(sum(imxy0,3)),'InitialMagnification',600);
       title('Frist click on the tip of the filament, then at the end point of it','color','red','FontSize',8);
       [xg,yg]=ginput(2);
        q=abs(atan((yg(2)-yg(1))/(xg(2)-xg(1))));
        close all
        x(1)=round(xg(1)); y(1)=round(yg(1));
        xend(1)=round(xg(2)); yend(1)=round(yg(2));
        if q>=pi/4
            imxy0=imrotate(imxy0,90);
           x(1)=round(yg(1)); y(1)=round(sx0-xg(1));
           xend(1)=round(yg(2)); yend(1)=round(sx0-xg(2));
        end
        imyz0=permute(imxy0,[1 3 2]);
   [sy0,sx0,sz0]=size(imxy0); 
   Axy0=mean(imxy0,3);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% add black side to the image
        bl=2*r0+1;   % black pixel number will be added on the edges
        x=x+bl;y=y+bl;xend=xend+bl;yend=yend+bl;
        black1(1:bl,1:sx0,1:sz0)=0;
        by=[black1;imxy0; black1];
        [sy,sx]=size(by(:,:,1));
        black2(1:sy,1:bl,1:sz0)=0;
        Bxy=[black2 by black2];
        imyz1=permute(Bxy,[1 3 2]);
        imzx1=permute(Bxy,[3 2 1]);
        Axy1=mean(Bxy,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  track filament in xy plane 
     hA=figure; set(hA,'Position',[100 200 1000 300]); 
     ax1=subplot(1,3,1);
     imshow(uint8(sum(imxy0,3)))
       xlabel('x ','FontSize',10,'FontWeight','bold','Color','black');
       ylabel('y ','FontSize',10,'FontWeight','bold','Color','black');
   title('z-projected image');
   hold on
   plot(ax1,x-bl,y-bl,'.blue','MarkerSize',10)
   hold on
   plot(ax1,xend-bl,yend-bl,'.blue','MarkerSize',10)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% track z  
          Ayz1= sum(imyz1(:,:,round(x(1))-1:round(x(1))+1),3);
          [sy,sz,st]=size(Ayz1);
          black3(1:sy,1:bl)=0;
          bAyz1=[black3 Ayz1 black3];
         zl=1:1:sz+(2*bl);yl1(1:length(zl))=round(y(1)-r0);yl2(1:length(zl))=round(y(1)+r0);
      for k=1:length(zl)-1
          intn(k)= mean(mean(bAyz1(yl1(k):yl2(k),zl(k):zl(k)+1)));
      end
         z(1)=mean(zl(intn==max(intn)));
         ax2=subplot(1,3,2);
         Ayz1=Ayz1*(100/max(intn)); % adjust intensity
         imshow(uint8(Ayz1));
             xlabel('z ','FontSize',10,'FontWeight','bold','Color','black');
             ylabel('y ','FontSize',10,'FontWeight','bold','Color','black');
            hold on 
            p2=plot(z(1)-bl,y(1),'*r');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% track the filament
    theta=linspace(0,2*pi);
     xt=x(1);
     yt=y(1);
   j=0;
   stop=0;
while stop==0
        j=j+1;
%%%%%%%%%%%%%%%%%%%%%%%%% break condition     
if xt+r0/2>sx0+bl || yt+r0/2>sy0+bl  || xt-r0/2<bl || yt-r0/2<bl || abs(xend-xt)<r0 
    disp('break')
    stop=1;
    break
end     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
      xcr=xt+r0*cos(theta);
      ycr=yt+r0*sin(theta);
  [~,sxx]=size(xcr);
  int=ones;
  for k=1:sxx
  alin = [xt xcr(k)];
  blin = [yt ycr(k)];
  in=improfile(Axy1,alin,blin);
  int(k)=mean(in);
  end
  x(j+1)=mean(xcr(int==max(int)));
  y(j+1)=mean(ycr(int==max(int)));
  for k=1:sxx
    if xcr(k)>= xt && ycr(k)>= yt
      Axy1(round(yt):round(ycr(k)),round(xt):round(xcr(k)))=0;
    elseif xcr(k)>= xt && ycr(k)<= yt
      Axy1(round(ycr(k)):round(yt),round(xt):round(xcr(k)))=0;
    elseif xcr(k)<= xt && ycr(k)<= yt
      Axy1(round(ycr(k)):round(yt),round(xcr(k):xt))=0;
    else xcr(k)<= xt && ycr(k)>= yt;
      Axy1(round(yt):round(ycr(k)),round(xcr(k)):round(xt))=0;
    end
  end
   xt=x(j+1); yt=y(j+1);
   plot(ax1,x-bl,y-bl,'-.blue')
%%%%%%%%%%%% track z  %%%%%%%%%%%%%%%%%%%%%%%%
 clear zl intn
             Ayz1= sum(imyz1(:,:,round(xt)-1:round(xt)+1),3);
             [sy,sz,st]=size(Ayz1);
             black3(1:sy,1:bl)=0;
             bAyz1=[black3 Ayz1 black3];
             yl1=round(y(j+1)-r0);yl2=round(y(j+1)+r0);
             zl=round(z(j)-r0):1:round(z(j)+r0);
%              imshow(bAyz1(yl1:yl2,:));  
           for k=1:length(zl)
                  intn(k)= mean(mean(bAyz1(yl1:yl2,zl(k):zl(k)+1)));
           end
         z(j+1)=mean(zl(intn==max(intn)));
         ax2=subplot(1,3,2);
         Ayz1=Ayz1*(100/max(intn)); % adjust intensity
         imshow(uint8(Ayz1));
             xlabel('z ','FontSize',10,'FontWeight','bold','Color','black');
             ylabel('y ','FontSize',10,'FontWeight','bold','Color','black');
          delete(p2)
          hold on 
          p2=plot(z(j+1)-bl,y(j+1),'*r');
          pause(pausetime) 
end
x=x-bl;
y=y-bl;
z=smooth(z,1)'-bl;
xn=x';
zn = smooth(y,z,smfactor,'loess');
yn= smooth(x,y,smfactor,'loess');
       ax1=subplot(1,3,1);
       imshow(uint8(sum(imxy0,3)))
       xlabel('x ','FontSize',10,'FontWeight','bold','Color','black');
       ylabel('y ','FontSize',10,'FontWeight','bold','Color','black');
   title('z-projected image');
   hold on
   plot(ax1,xn,yn,'.-blue','MarkerSize',5)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3D plot
       subplot(1,3,3)
       plot3(xn,zn,yn,'.-','MarkerSize',15)
       set(gca,'ZDir','reverse');
       grid on
       view(11,13)
       xlabel('x position','FontSize',10,'Color','black');
       ylabel('z position','FontSize',10,'Color','black');
       zlabel('y position','FontSize',10,'Color','black');
       xlim([0 sx0])
       ylim([0 sz0])
       zlim([0 sy0])
       set(get(gca,'ylabel'),'rotation',50)    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% save images and data       
    cd(Folder)
    Namef=[file(1:end-4) '_track'];       
    print('-dpng',Namef)
%%%%%%%%%%%
column_names = {'x', 'y', 'z'};
Res=[xn';yn';zn'];
fname = sprintf([file(1:end-4) '_position.txt']);
fileID = fopen(fname,'w');
fprintf(fileID, '%6s ', column_names{:});
fprintf(fileID,'\n %6.2f %6.2f %6.2f',Res);
fclose(fileID);
cd(currentFolder)

    