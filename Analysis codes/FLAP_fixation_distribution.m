%
%% Crossland Fixation distribution
% Marcello A. Maniglia, 2017-2019/10/28
%this script analyzes eyetracker data generated by the 'PRL_test.m' script
%and outputs fixation distribution  as graphs and percentages of the
%overall fixations after target presentation. Some changes can be made to
%modify some of the output


if exist('cuebeginningToResp')
dir= ['./FLAPanalysis/' ];
dir= ['./FLAPFixationAnalysis/' ];
dir= ['./fixationpilotdata/' ];


addpath([cd '/Functions']);


addpath('/Users/marcellomaniglia/Documents/GitHub/FLAP/Analysis codes/Oculomotor Analysis/Functions');

addpath('/Users/marcellomaniglia/Documents/GitHub/FLAP/Analysis codes/Oculomotor Analysis/Functions/fixationpilotdata');
subNum=baseName(70:71);
% if mod(iui,2)>0
% name=['Crossland distribution FLAP' subNum 'pre test'];
% elseif mod(iui,2)==0
% name=['Crossland distribution FLAP' subNum 'post test'];
% end
%subNum=['Sub 1' ];


name=['Crossland distribution FLAP ' subNum ' fixation task'];
firsttrial=1;
totaltrial=str2num(TrialNum(6:end))-1;


%define the duration of the fixation in seconds (default: .133s)
durationtocallfixation=.133;
%duration of the fixation in frames (ifi = inter frame interval)
framestocallfixation=round(durationtocallfixation/ifi);
%screen info
Xcenter=wRect(3)/2;
Ycenter=wRect(4)/2;

longfix=.05;

howlongfix=round(longfix/ifi);

fixationbins=.05;
fixationbinsframes=round(fixationbins/ifi);
postTargetWindowTime=.150/ifi;
postTargetWindow=round(postTargetWindowTime);


fixation_counter=[];


xlimit=(wRect(3)/2)/pix_deg;
ylimit=(wRect(4)/2)/pix_deg_vert;

%initialize heatmap
sampleX=(-xlimit:1:xlimit);
sampleY=(-ylimit:1:ylimit);
heatmatrix= zeros(length(sampleX), length(sampleY));


radius = scotomasize(1)/2; %radius of circular mask

      [sx,sy]=meshgrid(-wRect(3)/2:wRect(3)/2,-wRect(4)/2:wRect(4)/2);
      circlePixels=sx.^2 + sy.^2 <= radius.^2;
      d=(circlePixels==1);
      newfig=circlePixels;
      circlePixels=newfig;


%find the first available eye position after stimulus presentation
firstframetarget=[];

BCEA_data=zeros(totaltrial,1);

%initialize graph
figure
poss2 = [-(wRect(3)/2)/pix_deg -(wRect(4)/2)/pix_deg_vert ((wRect(3)/2)*2)/pix_deg ((wRect(4)/2)*2)/pix_deg_vert]; 
              rectangle('Position',poss2,'EdgeColor',[1 1 1],'FaceColor',[1 1 1])
               hold on
               poss2=poss2*1.2
poss = [-scotomadeg/2 -scotomadeg/2 scotomadeg scotomadeg]; 
rectangle('Position',poss,'Curvature',[1 1],'EdgeColor',[.8 .8 .8],'FaceColor',[.8 .8 .8])
hold on
line([-15,15],[0,0],'LineWidth',1,'Color',[.1 .1 .1])
hold on
line([0,0], [-15,15],'LineWidth',1,'Color',[.1 .1 .1])
hold on
viscircles([0 0], 20/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
viscircles([0 0], 30/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
           text(0,-11.5, '10^{\circ} ', 'FontSize', 20)
           text(0,-6.5, '5^{\circ} ', 'FontSize', 20)
           text(0,-16.5, '15^{\circ} ', 'FontSize', 20)


for i=firsttrial:totaltrial
    TrialNum = strcat('Trial',num2str(i));
firstfix=0;
    if exist('EyeSummary.(TrialNum).FixationIndices(end,2)')==0
        EyeSummary.(TrialNum).FixationIndices(end,2)=length(EyeSummary.(TrialNum).EyeData);
     end;
    
     if sum(EyeSummary.(TrialNum).EyeData(:,5)>=EyeSummary.(TrialNum).TimeStamps.StimulusStart)>=1
    % if sum(EyeSummary.(TrialNum).EyeData(:,5)>=EyeSummary.(TrialNum).TimeStamps.Stimulus)>=1
         
        %find the first available eye position after stimulus presentation

    FramesAfterTargetPresentation=find(EyeSummary.(TrialNum).EyeData(:,5)>=EyeSummary.(TrialNum).TimeStamps.StimulusStart);
  %FramesAfterTargetPresentation=find(EyeSummary.(TrialNum).EyeData(:,5)>=EyeSummary.(TrialNum).TimeStamps.Stimulus);
    if length(FramesAfterTargetPresentation)>0 %at least one valid frame after target presentation

                skipp(i)=1;
     firstframetarget=[firstframetarget FramesAfterTargetPresentation(1) ];
     

        Heatmap.(TrialNum).TargetX=EyeSummary.(TrialNum).TargetX*pix_deg;
        Heatmap.(TrialNum).TargetY=EyeSummary.(TrialNum).TargetY*pix_deg;
        
        
        tgt_y=Heatmap.(TrialNum).TargetY;
        tgt_x=Heatmap.(TrialNum).TargetX;
        
        Heatmap.(TrialNum).TargetXRespectToCenter=Xcenter+Heatmap.(TrialNum).TargetX;
        Heatmap.(TrialNum).TargetYRespectToCenter=Ycenter+Heatmap.(TrialNum).TargetY;

             
     newfixation.(TrialNum).fixStart=[];
     newfixation.(TrialNum).fixStop=[];
     
     for fiu=1:length(EyeSummary.(TrialNum).FixationIndices(:,1))
         if EyeSummary.(TrialNum).FixationIndices(fiu,2)-EyeSummary.(TrialNum).FixationIndices(fiu,1)>=framestocallfixation      
             newfixation.(TrialNum).fixStart=[newfixation.(TrialNum).fixStart EyeSummary.(TrialNum).FixationIndices(fiu,1)]
                          newfixation.(TrialNum).fixStop=[newfixation.(TrialNum).fixStop EyeSummary.(TrialNum).FixationIndices(fiu,2) ]
         end
     end
     
     
     % weighted fixations
     for ieu=1:length(newfixation.(TrialNum).fixStart)
         dots(ieu)=round((newfixation.(TrialNum).fixStop(ieu)-newfixation.(TrialNum).fixStart(ieu))/fixationbinsframes)
         
     end
     


     newnewfixation.(TrialNum).fixStart=[];
          newnewfixation.(TrialNum).fixStop=[];
     
          for ieu2=1:length(newfixation.(TrialNum).fixStart)
         for reppe=1:dots(ieu2)
       %  dots(ieu)=round((newfixation.(TrialNum).fixStop(ieu)-newfixation.(TrialNum).fixStart(ieu))/10)
       newnewfixation.(TrialNum).fixStart=[newnewfixation.(TrialNum).fixStart newfixation.(TrialNum).fixStart(ieu2)+fixationbinsframes*(reppe-1)]
              newnewfixation.(TrialNum).fixStop=[newnewfixation.(TrialNum).fixStop newfixation.(TrialNum).fixStop(ieu2)-fixationbinsframes*(reppe-1)]        
         end
          end
               if length(newfixation.(TrialNum).fixStart)>1

             dod=size(newnewfixation.(TrialNum).fixStart)
     resh=dod(1)*dod(2)
    hihg= reshape(newnewfixation.(TrialNum).fixStart,[1 resh])
     hihg(hihg==0)=[]
hihg=sort(hihg,'ascend')
hihg2=hihg+10

newnewfixation.(TrialNum).fixStart=hihg';
newnewfixation.(TrialNum).fixStop=hihg2';
    
            fix=0;
        cntr=0;
                counterr=0;
        clear zestart
                clear zeend

    for w=1:length(newfixation.(TrialNum).fixStart)
        totalfixation(i)=w


                EyeX=EyeSummary.(TrialNum).EyeData(newfixation.(TrialNum).fixStart(w),1);
        EyeY=EyeSummary.(TrialNum).EyeData(newfixation.(TrialNum).fixStart(w),2);
                diffx=EyeX-(wRect(3)/2+tgt_x);
            diffy=EyeY-(wRect(4)/2+tgt_y);

       
                        if newfixation.(TrialNum).fixStart(w)>(FramesAfterTargetPresentation(1)+postTargetWindow) %&& firstfix==0; %sum(newfixation.(TrialNum).fixStart==newnewfixation.(TrialNum).fixStart(w))>.5 %|| firstfix>0) 
            % && round(wRect(3)/2+diffx)<=wRect(3) && round(wRect(4)/2+diffy)<=wRect(4) && round(wRect(3)/2+diffx)> 0 && round(wRect(4)/2+diffy)>0 % && round(wRect(4)/2+(abs(EyeSummary.(TrialNum).EyeData(w,2)-(wRect(4)/2+tgt_y))))<wRect(4) && round(wRect(3)/2+(abs(EyeSummary.(TrialNum).EyeData(w,1)-(wRect(3)/2+tgt_x))))<wRect(3)
counterr=counterr+1;
firstfix=1;

zestart=newfixation.(TrialNum).fixStart(w);

zeend = newfixation.(TrialNum).fixStop(w);
       %     if circlePixels(round(wRect(4)/2+diffy),round(wRect(3)/2+diffx))==0 
            %  cntr=cntr+1;
                      totalfixation_post(i)=counterr;
                  %    if
                          
                     cntr=length(EyeSummary.(TrialNum).EyeData(zestart:zeend,1))
Heatmap.(TrialNum).OneFixationX(1:cntr)=EyeSummary.(TrialNum).EyeData(zestart:zeend,1);%/pix_deg;
      Heatmap.(TrialNum).OneFixationY(1:cntr)=EyeSummary.(TrialNum).EyeData(zestart:zeend,2);%/pix_deg_vert;     
          
      durationTrial(i)=cntr;
      lestart(i)=zestart;
      leend(i) = zeend;
                %  break       
       
           
        end
        

    end
    
  if isfield(Heatmap.(TrialNum),'OneFixationX')
    Heatmap.(TrialNum).OneFixationXClean=Heatmap.(TrialNum).OneFixationX(Heatmap.(TrialNum).OneFixationX~=0)
        Heatmap.(TrialNum).OneFixationYClean=Heatmap.(TrialNum).OneFixationY(Heatmap.(TrialNum).OneFixationY~=0)

              offsetTarget.(TrialNum).FixationY=(Heatmap.(TrialNum).OneFixationYClean)-Heatmap.(TrialNum).TargetYRespectToCenter;
            offsetTarget.(TrialNum).FixationX=(Heatmap.(TrialNum).OneFixationXClean)-Heatmap.(TrialNum).TargetXRespectToCenter;
  
                    if length(offsetTarget.(TrialNum).FixationY)>length(offsetTarget.(TrialNum).FixationX)
                offsetTarget.(TrialNum).FixationY=offsetTarget.(TrialNum).FixationY(1:length(offsetTarget.(TrialNum).FixationX));
                    
                    end
            
                                        if length(offsetTarget.(TrialNum).FixationY)<length(offsetTarget.(TrialNum).FixationX)
                offsetTarget.(TrialNum).FixationX=offsetTarget.(TrialNum).FixationX(1:length(offsetTarget.(TrialNum).FixationY));

                                        end
                        
                             coordinates.(TrialNum).RelativeToCenter=[offsetTarget.(TrialNum).FixationX'  offsetTarget.(TrialNum).FixationY'];
                             
          
               for ww=1:length(offsetTarget.(TrialNum).FixationY)

           scatter((coordinates.(TrialNum).RelativeToCenter(ww,1)/pix_deg),(coordinates.(TrialNum).RelativeToCenter(ww,2))/pix_deg_vert, 50,[0.3 0.3 0.3], '+');
set (gca,'YDir','reverse')

   hold on
           
            degX=(coordinates.(TrialNum).RelativeToCenter(ww,1)/pix_deg);
 degY=(coordinates.(TrialNum).RelativeToCenter(ww,2)/pix_deg_vert);

for sss=2:length(sampleX)
    for dd=2:length(sampleY)
   
   if degX<=sampleX(sss) && degX>=sampleX(sss-1) && degY<=sampleY(dd) && degY>=sampleY(dd-1)
   
   heatmatrix(sss-1,dd-1)=heatmatrix(sss-1,dd-1)+1;
    end
end
    
    
    

end

fix_counter=coordinates.(TrialNum).RelativeToCenter(ww,:);


BCEA_data(i)=fix_counter(1,1);

fixation_counter=[fixation_counter;fix_counter];
           end
    
clear fix_counter

           

                numFixation.(TrialNum).Fix=fix;

  end
  end
     elseif sum(EyeSummary.(TrialNum).EyeData(:,5)>=EyeSummary.(TrialNum).TimeStamps.StimulusStart)==0
             % elseif sum(EyeSummary.(TrialNum).EyeData(:,5)>=EyeSummary.(TrialNum).TimeStamps.Stimulus)==0
      numFixation.(TrialNum).Fix=0
     end

end
end





         xlim([(-(wRect(3)/2)/pix_deg)*1.2 ((wRect(3)/2)/pix_deg)*1.2 ]);
ylim([(-(wRect(4)/2)/pix_deg_vert)*1.2 ((wRect(4)/2)/pix_deg_vert)*1.2]);


FixationsX=fixation_counter(:,1)/pix_deg;
FixationsY=fixation_counter(:,2)/pix_deg_vert;
AllFix=[FixationsX FixationsY];
  %  AllFix_deg=[FixationsX FixationsY];
center_PRL(1)=mean(fixation_counter(:,1));
center_PRL(2)=mean(fixation_counter(:,2));

center_PRL_deg(1)=mean(fixation_counter(:,1)/pix_deg);
center_PRL_deg(2)=mean(fixation_counter(:,2)/pix_deg_vert);

%PRL split
PRL_left_counter=0;
PRL_right_counter=0;
for ui=1:length(AllFix)
    
    if AllFix(ui,1)<0
        PRL_left_counter=PRL_left_counter+1;
        PRL_left(PRL_left_counter,:)= AllFix(ui,:);
    elseif AllFix(ui,1)>0
                PRL_right_counter=PRL_right_counter+1;
           PRL_right(PRL_right_counter,:)= AllFix(ui,:);
    end

    
end
ellli=cov(FixationsX,FixationsY);
data=[FixationsX FixationsY];
error_ellipse(ellli, mean(data), .68);

[eigenvec, eigenval ] = eig(ellli);
d=sqrt(eigenval);

areaEll=pi*d(1)*d(4);

%areaEllarcmin=3600*areaEll;
caption=round(areaEll);
thetaM=rad2deg(acos(eigenvec(1,1)))


%text(-15,10, ['angle ' txt11, ' deg'], 'FontSize', 20)


set(gca, 'FontName', 'Arial')
set (gca,'YDir','reverse')
set(gca,'FontSize',25)

name11=[name ' fixation distribution' ]
         title( name11);
         
         
         
         
         set(gca,'FontSize',16)

pbaspect([2 1 1]);



     print([dir name '_fixationdistribution'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI
hold on
txt10=num2str(caption);
text(-15,10, ['BCEA= ' txt10, ' deg^2'], 'FontSize', 20)

txt11=num2str(thetaM);

     print([dir name '_fixationdi_bcea'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI

    
FixationsX=fixation_counter(:,1)/pix_deg;
FixationsY=fixation_counter(:,2)/pix_deg_vert;

figure
poss2 = [-(wRect(3)/2)/pix_deg -(wRect(4)/2)/pix_deg_vert ((wRect(3)/2)*2)/pix_deg ((wRect(4)/2)*2)/pix_deg_vert]; 
              rectangle('Position',poss2,'EdgeColor',[1 1 1],'FaceColor',[1 1 1])
               hold on
poss = [-scotomadeg/2 -scotomadeg/2 scotomadeg scotomadeg]; 
rectangle('Position',poss,'Curvature',[1 1],'EdgeColor',[.8 .8 .8],'FaceColor',[.8 .8 .8])
hold on
line([-15,15],[0,0],'LineWidth',1,'Color',[.1 .1 .1])
hold on
line([0,0], [-15,15],'LineWidth',1,'Color',[.1 .1 .1])
hold on
viscircles([0 0], 20/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
viscircles([0 0], 30/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
           text(0,-11.5, '10^{\circ} ', 'FontSize', 20)
           text(0.5,-6.5, '5^{\circ} ', 'FontSize', 20)
           text(0,-16.5, '15^{\circ} ', 'FontSize', 20)


           hold on
data=[FixationsX FixationsY];


PRLdist_X=mean(FixationsX);
PRLdist_Y=mean(FixationsY);
  % call the routine
    [bandwidth,density,X,Y]=kde2d(data);
  % plot the data and the density estimate
    contour3(X,Y,density,50), hold on
    plot(data(:,1),data(:,2),'r.','MarkerSize',5)
    view(2)
   % viscircles([0 0], scotomadeg/2,'EdgeColor',[.8 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 3);
pbaspect([2 1 1]);
set(gca, 'FontName', 'Arial')
set (gca,'YDir','reverse')


set(gca,'FontSize',14)
         title( name);
hold on
 ylabel('degrees of visual angle', 'fontsize', 14);
  xlabel('degrees of visual angle', 'fontsize', 14);

         xlim([(-(wRect(3)/2)/pix_deg)*1.2 ((wRect(3)/2)/pix_deg)*1.2 ]);
ylim([(-(wRect(4)/2)/pix_deg_vert)*1.2 ((wRect(4)/2)/pix_deg_vert)*1.2]);

     
     print([dir name '_kernel'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI
%
figure
poss2 = [-(wRect(3)/2)/pix_deg -(wRect(4)/2)/pix_deg_vert ((wRect(3)/2)*2)/pix_deg ((wRect(4)/2)*2)/pix_deg_vert]; 
              rectangle('Position',poss2,'EdgeColor',[1 1 1],'FaceColor',[1 1 1])
               hold on
poss = [-scotomadeg/2 -scotomadeg/2 scotomadeg scotomadeg]; 
rectangle('Position',poss,'Curvature',[1 1],'EdgeColor',[.8 .8 .8],'FaceColor',[.8 .8 .8])
hold on
line([-15,15],[0,0],'LineWidth',1,'Color',[.1 .1 .1])
hold on
line([0,0], [-15,15],'LineWidth',1,'Color',[.1 .1 .1])
hold on
viscircles([0 0], 20/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
viscircles([0 0], 30/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
           text(0,-11.5, '10^{\circ} ', 'FontSize', 20)
           text(0.5,-6.5, '5^{\circ} ', 'FontSize', 20)
           text(0,-16.5, '15^{\circ} ', 'FontSize', 20)


           hold on
%dens=std(data)/length(data)^(1/6);

dens=std(data)/length(data)^(1/10);
npern=512;
MAX=max(data,[],1); MIN=min(data,[],1); Range=MAX-MIN;
      MAX_XY=MAX+Range/4; MIN_XY=MIN-Range/4;
       % call the routine
    [bandwidth,density,X,Y]=kde2d_mm(data,npern,MAX_XY,MIN_XY,dens);
  % plot the data and the density estimate
    contour3(X,Y,density,50), hold on
    view(2)
pbaspect([2 1 1]);
set(gca, 'FontName', 'Arial')
set (gca,'YDir','reverse')

set(gca,'FontSize',26)
name2=[name ' adjust']


MaxKDE=(density==max(max(density)));
PRLKDE_X=X(MaxKDE);
PRLKDE_Y=Y(MaxKDE);

name2=[name ' KDE']
         title(name2);
hold on
 ylabel('degrees of visual angle', 'fontsize', 28);
  xlabel('degrees of visual angle', 'fontsize', 28);

         xlim([(-(wRect(3)/2)/pix_deg)*1.2 ((wRect(3)/2)/pix_deg)*1.2 ]);
ylim([(-(wRect(4)/2)/pix_deg_vert)*1.2 ((wRect(4)/2)/pix_deg_vert)*1.2]);

     
    
          print([dir name 'KDE'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI

    
%     %%
%     
%      
%     BCEA_anal=nan(totaltrial,1);
%     for i=firsttrial:totaltrial
%     TrialNum = strcat('Trial',num2str(i));
%     
%     if BCEA_data(i)~=0
%     BCEA_anal(i,1)=mean(coordinates.(TrialNum).RelativeToCenter(:,1))
%     BCEA_anal(i,2)=mean(coordinates.(TrialNum).RelativeToCenter(:,2))    
%     end
%         
%     end
% 
%     
%     BCEA_area_arcmin=nan(totaltrial,1);
% average_X=nan(totaltrial,1);
% average_Y=nan(totaltrial,1);
%     eyeposnX=nan(totaltrial,1);
%         eyeposnY=nan(totaltrial,1);
% 
%         for i=firsttrial:totaltrial
%     TrialNum = strcat('Trial',num2str(i));
%     lax=[];
%     lay=[];
%        if BCEA_data(i)~=0
%           lax= coordinates.(TrialNum).RelativeToCenter(:,1)/pix_deg           
%           lay= coordinates.(TrialNum).RelativeToCenter(:,2)/pix_deg_vert
% eyeposnX(i)=length(lax)
% eyeposnY(i)=length(lay)
% if length(lax)>2
% ellli=cov(lax,lay)
% data=[lax lay]
% error_ellipse(ellli, mean(data), .68)
% 
% [eigenvec, eigenval ] = eig(ellli);
% d=sqrt(eigenval)
% 
% areaEll=pi*d(1)*d(4)
% 
% areaEllarcmin=3600*areaEll;
% BCEA_area_arcmin(i)=areaEllarcmin
% average_X(i)=mean(lax)
% average_Y(i)=mean(lay)
% 
% end
%        end
%         end
%     
%         
%      meanBCEA=nanmean(BCEA_area_arcmin);
%               sdBCEA=nanstd(BCEA_area_arcmin);
%               cutoffBCEA=meanBCEA+(2*sdBCEA)
%               
%               
%               for uie=1:totaltrial
%                 if BCEA_area_arcmin(uie)> cutoffBCEA
%                     adjustBCEA(uie)=1
%                 else
%                     adjustBCEA(uie)=0
%                 end
%               end
%               
%                             BCEA_area_arcmin_adj=BCEA_area_arcmin(adjustBCEA==0)
%                             BCEA_area_arcmin=BCEA_area_arcmin(~isnan(BCEA_area_arcmin))
%                                           BCEA_area_arcmin_adj=BCEA_area_arcmin_adj(~isnan(BCEA_area_arcmin_adj))
%               eyeposnX_adj=eyeposnX(adjustBCEA==0)
%               figure
%               subplot(1,2,1)
%               hist(BCEA_area_arcmin)
% 
%                xlabel('BCEA area (arcmin2)', 'fontsize', 16);
%   ylabel('trial', 'fontsize', 26);
%   set(gca,'FontSize',25)
%               
%               
%               subplot(1,2,2)
%               hist(BCEA_area_arcmin_adj)
%                xlabel('BCEA area (arcmin2) - adj', 'fontsize', 16);
%   ylabel('trial', 'fontsize', 26);
%   set(gca,'FontSize',25)
% %xlim(max(BCEA_area_arcmin_adj))
%               suptitle( ['Sub ' baseName(8:16) 'single trial BCEA adj' ]);
% 
%                    print(['Sub ' baseName(8:16) '_histBCEA_fix'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI
% 
%                    
%                    
%                    figure
%                    
%                    hist(BCEA_area_arcmin_adj)
%                xlabel('BCEA area (arcmin2) - adj', 'fontsize', 16);
%   ylabel('trial', 'fontsize', 26);
%   set(gca,'FontSize',26)
% %xlim(max(BCEA_area_arcmin_adj))
%               title( ['Sub ' baseName(8:16) ' single trial BCEA' ]);
%          xlabel('arcmin', 'fontsize', 28);
%        
% 
%                    
%                                       print(['Sub ' baseName(8:16) '_histBCEA_fix_2'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI
% 
%                    
%                                       
%                                       
%              figure
%                                 hist(BCEA_area_arcmin_adj)
%                                  
%                          xlabel('BCEA area (arcmin2) - adj', 'fontsize', 16);
%   ylabel('trial', 'fontsize', 26);
%   set(gca,'FontSize',26)
%               title( ['Sub ' baseName(8:11) ' single trial BCEA' ]);
%          xlabel('arcmin', 'fontsize', 28);
%          
%                                       print([name '_histBCEA_fix_2_fix'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI
% 
%  
%             
%             figure
%  set(gca,'FontSize',28)
%  G={'BCEA'}
%  boxplot(BCEA_area_arcmin_adj, G);
%  thenums=num2str(mean(BCEA_area_arcmin_adj))
%   text(1,max(BCEA_area_arcmin_adj)*0.8,['area: ' thenums(1:end-2) ' arcmin'], 'FontSize', 22)
%  set(gca,'FontSize',28)
% 
%   ylabel('arcmin', 'fontsize', 28);
%             
%                                                   print([ name '_boxplotbces_fix'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI
% 
%                                       
%                                 
%                                       
%                    
%                    
%               figure
%               poss2 = [-(wRect(3)/2)/pix_deg -(wRect(4)/2)/pix_deg_vert ((wRect(3)/2)*2)/pix_deg ((wRect(4)/2)*2)/pix_deg_vert]; 
%               rectangle('Position',poss2,'EdgeColor',[1 1 1],'FaceColor',[1 1 1])
%                hold on
%                poss2=poss2*1.2
% poss = [-scotomadeg/2 -scotomadeg/2 scotomadeg scotomadeg]; 
% rectangle('Position',poss,'Curvature',[1 1],'EdgeColor',[.8 .8 .8],'FaceColor',[.8 .8 .8])
% hold on
% line([-15,15],[0,0],'LineWidth',1,'Color',[.1 .1 .1])
% hold on
% line([0,0], [-15,15],'LineWidth',1,'Color',[.1 .1 .1])
% hold on
% viscircles([0 0], 20/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
% viscircles([0 0], 30/2,'EdgeColor',[.1 .1 .1],'DrawBackgroundCircle',false, 'LineWidth', 1);
%            text(0,-11.5, '10^{\circ} ', 'FontSize', 20)
%            text(0,-6.5, '5^{\circ} ', 'FontSize', 20)
%            text(0,-16.5, '15^{\circ} ', 'FontSize', 20)
% 
%                          average_X_nozero=average_X(average_X~=isnan(average_X));
%                             average_Y_nozero=average_Y(average_Y~=isnan(average_Y));
% scatter(average_X_nozero,average_Y_nozero, 10, [0 0 1],'filled');
%         
% 
% 
%          xlim([(-(wRect(3)/2)/pix_deg)*1.2 ((wRect(3)/2)/pix_deg)*1.2 ]);
% ylim([(-(wRect(4)/2)/pix_deg_vert)*1.2 ((wRect(4)/2)/pix_deg_vert)*1.2]);
% 
%         set (gca,'YDir','reverse')
% 
%    hold on
% pbaspect([1.5 1 1]);
%   set(gca,'FontSize',26)
% 
%     thetitle=[name(1:end-7) ' single-trial BCEA center']   
% title(thetitle,'fontsize', 20);
% 
%  ylabel('degrees of visual angle', 'fontsize', 28);
%   xlabel('degrees of visual angle', 'fontsize', 28);
%         
%        BCEA_area_arcmin_nozero=BCEA_area_arcmin(BCEA_area_arcmin~=0)
%        eyeposnXnozero=eyeposnX(eyeposnX~=0)
%        
%        eyeposnXnozero=eyeposnX(~isnan(eyeposnX));
%        
%        
%        eyeposnXnouno=eyeposnX(~isnan(eyeposnX))
%               eyeposnXnouno=(eyeposnXnouno(eyeposnXnouno~=2 & eyeposnXnouno~=0 & eyeposnXnouno~=1))
% 
% 
%        BCEA_anal_nozero=BCEA_anal(~isnan(BCEA_anal(:,1)),:)
%        
% BCEA_anal_nozero=BCEA_anal(~isnan(BCEA_anal(:,1)),:);       
%         if length(BCEA_anal_nozero(:,1))>1
%        BCEA_anal_average=mean(BCEA_anal_nozero)       
%         else %if length(BCEA_anal_nozero(:,1))==1
%             BCEA_anal_average=BCEA_anal_nozero
%         end
% 
%         
%                BCEA_area_arcmin_nozero_adj=BCEA_area_arcmin_adj(BCEA_area_arcmin_adj~=0)
%        eyeposnXnozero_adj=eyeposnX_adj(eyeposnX_adj~=0)
%                              eyeposnXnouno_adj=eyeposnX_adj(~isnan(eyeposnX_adj));
%        eyeposnXnouno_adj=(eyeposnXnouno_adj(eyeposnXnouno_adj~=2 & eyeposnXnouno_adj~=0 & eyeposnXnouno_adj~=1))
% 
%      print([name '_plotBCEAcentr'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI
% 
%      
% figure
% subplot(1,2,1)
% scatter(eyeposnXnouno, BCEA_area_arcmin_nozero, 'filled')
%  xlabel('number of fixations (133 ms)', 'fontsize', 16);
%   ylabel('BCEA size', 'fontsize', 16);
%     title('BCEA')
%  % print([name '_BCEA_scatter'], '-dpng', '-r300'); %<-Save as PNG with 300 DPI
% 
%   
%          xlim([0 max(eyeposnXnouno)*1.1]);
% ylim([0 max(BCEA_area_arcmin_nozero)*1.1]);
%   subplot(1,2,2)
%   scatter(eyeposnXnouno_adj, BCEA_area_arcmin_nozero_adj, 'filled')
%  xlabel('number of fixations (133 ms)', 'fontsize', 16);
%   ylabel('BCEA size', 'fontsize', 16);
%     title('BCEA sans outlier')
%          xlim([0 max(eyeposnXnouno_adj)*1.1]);
% ylim([0 max(BCEA_area_arcmin_nozero_adj)*1.1]);
%     suptitle([name ' BCEA x fixations'])
% 
%   print([name 'BCEA_scatter_adj'], '-dpng', '-r300'); 
% 


else
    'old fixation task'
end
