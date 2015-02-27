%TODO LIST
% Figure out hop sizing for different sample rates

function spectragram
    close all; %closes all open figures

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%% GUI INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %First, create axes
    set(gcf, 'doublebuffer','on','units','pixels','position',...
        [40, 40, 840, 640]); %Set figure limits and settings, CHANGE UNITS??
    a = gca; %get current axes, sets a as handle
    set(a,'xlim',[-20,0]); %Start x-axis range 0-20 seconds
    set(a,'ylim',[0, 10000]); %Start y-axis range 0-10000 Hz
    %set(a, 'xdir','reverse') %Experimental to reverse x-axis

    %Second, get axis positions for slider placement
    pos = get(a, 'position'); %Gets position of axes, for normalized units
    hSliderPos=[pos(1) pos(2)-0.1 pos(3) 0.05]; %Sets relative position
    vSliderPos=[pos(1)-0.1 pos(2) .05 pos(4)]; %Sets relative position
    fsBoxPos=[pos(2)+0.5 pos(4)+.1 .075 .05];
    
    %Callback functions for the GUI Interactivity
    hSliderCallback=('set(gca,''xlim'',[get(gcbo,''value'') 0])');
    vSliderCallback=('set(gca,''ylim'',[0 get(gcbo,''value'')])');
    %fsBoxCallback  =('set(amp,str2num(get(gcbo,''string'')))');
 function fsBoxCallback(source,eventdata)
        str = source.String;
        val = source.Value;
        switch str{val};
            case '8000'
                fs = 8000;
            case '48000'
                fs = 48000;
        end
    end
    %Add GUI elements
    %Create time slider
    hSlider = uicontrol('style','slider','units','normalized','position',...
        hSliderPos,'callback',hSliderCallback,'min',-20,'max',-2,'value',-2,...
        'SliderStep',[0.0556 .2778]); %Change max and min here to change sliders
    
    %Create frequency slider
    vSlider = uicontrol('style','slider','units','normalized','position',...
        vSliderPos,'callback',vSliderCallback,'min',100,'max',10000,'value',100,...
        'SliderStep',[0.0556 .2778]); %Change max and min here to change sliders
    
    %Create sampling freqeuncy box
   
    fsBox = uicontrol('style','popupmenu','units','normalized','Position',fsBoxPos,...
        'String',{'8000','48000'},'callback',@fsBoxCallback)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%% USER VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fs = 8000; %Sampling Frequency, to change with GUI
    %fs can be 8000, 11025, 22050, 44100, 48000, and 96000 Hz.
    %Determine hop size, must be less than 1, based off frequency
    recTime = 0.0625; %250millisecond record time THIS IS HOP SIZE, or HOP RATE
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%% ARRAY INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    timeArray = 0:1/fs:20; %create time storage points based on fs until 20 seconds
    timeArray = timeArray-20; %Shifts time array by -20s
    dataArray = timeArray+5000; %shifts input signal, TEMPORARY BEFORE FFT
    %dataArray = zeros(1,length(timeArray));
    tempDataArray = 0:1/fs:recTime; %This array is for data calculations
    calcArray = tempDataArray; %array for FFT data

    %THE FOLLOWING WILL BE IN A LOOP
    loop = 0;
    x=1;
    maxLoop = ((length(timeArray)-1)/(length(tempDataArray)-1)-1); %This calculates how many times to loop before circshifting array

    while x == 1 %Infinite loop, CTRL+C to stop

        recObj = audiorecorder(fs,8,1); %Initialize microphone with sampling frequency variable
        recordblocking(recObj, recTime); %Record using microphone for recording time (seconds)
        tempDataArray = getaudiodata(recObj); % Get audio data recordblocking
        tempDataArray = rot90(tempDataArray); %rotate the array to match size
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%% FFT CALCULATION HERE %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tempDataArray = tempDataArray*5000+5000; %temporary scaling to display signal
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

              
        %FILL ARRAY FORWARDS
        i = 1; 
        while i<recTime*fs %this loop fills the dataArray with the "hop" data
            dataArray(i+loop*recTime*fs) = tempDataArray(i);
            i=i+1;
        end
        if loop >= maxLoop %fills array
            %timeArray = circshift(timeArray, [0 -recTime*fs]); %NOT
            %NEEDED!
            dataArray = circshift(dataArray, [0 -recTime*fs]); %Circleshift
        else
            loop = loop+1;
        end
        cla %CLA will clear the old dataArray plotted so the circshift doesnt plot over it
        hold on %keep the axes how the user has set them
        plot(timeArray, dataArray); %Create the plot
        drawnow; %Is this needed??
        
    end
end
        

