function spectragram
close all;
% Sample plot for GUI configuration
a=gca; %create axes

%x=0:1e-2:6.7*pi;
%amp = 5000;%test variable
%y=amp*cos(x)+5000; %y
%p=plot(x,y); %plot cos function
%xmax=max(x); %what is this

% Record your voice for 5 seconds.
recObj = audiorecorder;
disp('Start speaking.')
recordblocking(recObj, 5);
disp('End of Recording.');
% Play back the recording.
play(recObj);
% Store data in double-precision array.
myRecording = getaudiodata(recObj);
myRecording2 = myRecording*5000+5000;
% Plot the waveform.
plot(myRecording2);

%Set appropriate axis limits and settings
set(gcf,'doublebuffer','on',...
    'units','pixels',...
    'position',[40,40,840,640]);
set(a,'xlim',[0 2]); %Start x-axis range 0-2s
set(a,'ylim',[0 100]);%Start y-axis range 0-100Hz

% Relative positiong for sliders and buttons for resizeability
pos=get(a,'position'); %pos(1) is left - pos(2) is bottom - pos(3) is width - pos(4) is height
hSliderPos=[pos(1) pos(2)-0.1 pos(3) 0.05];
vSliderPos=[pos(1)-0.1 pos(2) .05 pos(4)];
fsBoxPos=[pos(2)+pos(3)+.05 pos(4) .1 .05];


%Callback functions for the GUI interactivity
hSlideCallback=['set(gca,''xlim'',[0 get(gcbo,''value'') ])'];
vSlideCallback=['set(gca,''ylim'',[0 get(gcbo,''value'') ])'];
fsBoxCallback=['set(amp,str2num(get(gcbo,''string'')))'];


%GUI Elements
hSlide = uicontrol('style','slider',...
      'units','normalized','position',hSliderPos,...
      'callback',hSlideCallback,'min',2,'max',50000,'value',2,...
      'SliderStep',[0.0556 .2778]);

vSlide = uicontrol('style','slider',...
      'units','normalized','position',vSliderPos,...
      'callback',vSlideCallback,'min',100,'max',10000,'value',100,...
      'SliderStep',[0.0556 .2778]);
  
fsBox = uicontrol('style','edit',...
      'units','normalized','Position',fsBoxPos,...
      'String','0',...
      'callback',fsBoxCallback);


