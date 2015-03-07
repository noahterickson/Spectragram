%TODO LIST
%Figure out hop sizing for different sample rates

function spectragram
    close all; %closes all open figures
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%% GUI INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% FIGURE AND AXES %%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(gcf, 'doublebuffer','on','units','normalized','position',...
        [0.05 0.05 .75 .75]);
    a = gca; %get current axes, sets a as handle
    xlabel('Time Elapsed (s)');
    ylabel('Frequency (Hz)');
    set(a, 'position',[.085 .085 .7 .9]);
    set(a,'xlim',[-20,0]); %Start x-axis range 0-20 seconds
    set(a,'ylim',[0, 10000]); %Start y-axis range 0-10000 Hz
    %set(a, 'xdir','reverse') %Experimental to reverse x-axis

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SlIDERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Callback functions for the sliders (need to be before slider creation)
    hSliderCallback=('set(gca,''xlim'',[get(gcbo,''value'') 0])');
    vSliderCallback=('set(gca,''ylim'',[0 get(gcbo,''value'')])');
    %Get axis positions for slider placement
    pos = get(a, 'position'); %Gets position of axes, for normalized units
    hSliderPos=[pos(1) 0.01 pos(3) 0.025]; %Sets relative position
    vSliderPos=[0.01 pos(2) .025 pos(4)]; %Sets relative position
    %Create time slider
    hSlider = uicontrol('style','slider','units','normalized','position',...
    hSliderPos,'callback',hSliderCallback,'min',-20,'max',-2,'value',-2,...
    'SliderStep',[0.0556 .2778]); %Change max and min here to change sliders
    %Create frequency slider
    vSlider = uicontrol('style','slider','units','normalized','position',...
        vSliderPos,'callback',vSliderCallback,'min',100,'max',10000,'value',100,...
        'SliderStep',[0.0556 .2778]); %Change max and min here to change sliders
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% CONTROL PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cPanel = uipanel('Title','Control Panel','FontSize',12,...
         'Position',[.8 .1 .19 .89]);  
       %Create label for sampling frequency box
    fsBoxLabel = uicontrol('parent',cPanel,'Style','text',...
        'String','Sampling Frequency',...
        'units','normalized','Position',[.04 .945 .4 .025]);
    %Create sampling freqeuncy drop downbox
    fsBox = uicontrol('parent',cPanel,'style','popupmenu',...
        'units','normalized','Position',[.6 .1 .3 .875],...
        'String',{'8000','48000'},'callback',@fsBoxCallback);
    %Create label for window duration
    windowBoxLabel = uicontrol('parent',cPanel,'Style','text',...
        'String','Window Duration',...
        'units','normalized','Position',[.04 .8725 .4 .025]);
    %Create sampling freqeuncy drop downbox
    windowBox = uicontrol('parent',cPanel,'style','popupmenu',...
        'units','normalized','Position',[.6 .1 .3 .8],...
        'String',{'10','500'});
    iPanel = uipanel('parent',cPanel,'Title','Info Panel','Fontsize',12,...
        'BackgroundColor','white','units','normalized','Position',[.1 .04 .8 .4]);
    timeText = uicontrol('parent',iPanel,'Style','text','string',2);
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%% USER VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fs = 8000; %Sampling Frequency, to change with GUI
    %fs can be 8000, 11025, 22050, 44100, 48000, and 96000 Hz.
    %Determine hop size, must be less than 1, based off frequency
    recTime = 0.125; %250millisecond record time THIS IS HOP SIZE, or HOP RATE
    %recTime = 0.0625 %is slower, recTime will change speed of

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%% ARRAY INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    timeArray = 0:1/fs:20; %create time storage points based on fs until 20 seconds
    timeArray = timeArray-20; %Shifts time array by -20s
    dataArray = timeArray+5000; %shifts input signal, TEMPORARY BEFORE FFT
    %dataArray = zeros(1,length(timeArray));
    tempDataArray = 0:1/fs:recTime; %This array is for data calculations
    calcArray = tempDataArray; %array for FFT data

    x=1;%Set loops to infinite!
    while x == 1 %Infinite loop, CTRL+C to stop

        recObj = audiorecorder(fs,8,1); %Initialize microphone with sampling frequency variable
        recordblocking(recObj, recTime); %Record using microphone for recording time (seconds)
        tempDataArray = getaudiodata(recObj); % Get audio data recordblocking
        %tempDataArray = rot90(tempDataArray); %rotate the array to match size
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%% FFT CALCULATION HERE %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tempDataArray = tempDataArray*5000+5000; %temporary scaling to display signal
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              
        %FILL ARRAY FORWARDS
        i = 1; 
        while i<recTime*fs %this loop fills the dataArray with the "hop" data
            dataArray(i) = tempDataArray(i); %store the hop data
            i=i+1;
        end
     
        dataArray = circshift(dataArray, [0 -recTime*fs]); %Circleshift,

        cla %CLA will clear the old dataArray plotted so the circshift doesnt plot over it
        hold on %keep the axes how the user has set them
        plot(timeArray, dataArray); %Create the plot
        drawnow; %Is this needed??
        
    end

    function fsBoxCallback(obj,event)
        x=0;
        fs = get(fsBox,'value');
    end
   
end

