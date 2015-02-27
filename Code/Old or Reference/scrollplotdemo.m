function scrollplotdemo
close all;
%%%%% Generate and plot data
x=0:1e-2:6.7*pi;
amp = 5000;
y=amp*cos(x)+5000;
% dx is the width of the axis 'window'
a=gca;
p=plot(x,y);
%%%%% Set appropriate axis limits and settings
set(gcf,'doublebuffer','on',...
    'units','pixels',...
    'position',[40,40,840,640]);
% This avoids flickering when updating the axis
set(a,'xlim',[0 2]);
set(a,'ylim',[0 100]);
%%%%% Generate constants for use in uicontrol initialization
pos=get(a,'position');
%pos(1) is left
%pos(2) is bottom
%pos(3) is width
%pos(4) is height
hSliderPos=[pos(1) pos(2)-0.1 pos(3) 0.05];
vSliderPos=[pos(1)-0.1 pos(2) .05 pos(4)];
fsBoxPos=[pos(2)+pos(3)+.05 pos(4) .1 .05];
% This will create a slider which is just underneath the axis
% but still leaves room for the axis labels above the slider

linkdata on;
linkdata(gcf);

xmax=max(x);

hSlideCallback=['set(gca,''xlim'',[0 get(gcbo,''value'') ])'];
vSlideCallback=['set(gca,''ylim'',[0 get(gcbo,''value'') ])'];
fsBoxCallback=['set(amp,str2num(get(gcbo,''string'')))'];
% Setting up callback string to modify XLim of axis (gca)
% based on the position of the slider (gcbo)
%%%%% Creating Uicontrol
hSlide = uicontrol('style','slider',...
      'units','normalized','position',hSliderPos,...
      'callback',hSlideCallback,'min',2,'max',20,'value',2,...
      'SliderStep',[0.0556 .2778]);

vSlide = uicontrol('style','slider',...
      'units','normalized','position',vSliderPos,...
      'callback',vSlideCallback,'min',100,'max',10000,'value',100,...
      'SliderStep',[0.0556 .2778]);
  
fsBox = uicontrol('style','edit',...
      'units','normalized','Position',fsBoxPos,...
      'String','0',...
      'callback',fsBoxCallback);

  
 drawnow
  
end