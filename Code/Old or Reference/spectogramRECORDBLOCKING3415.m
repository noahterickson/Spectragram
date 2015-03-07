%TODO LIST
%Figure out hop sizing for different sample rates

function spectragram
        close all; %closes all open figures
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%% INITIALUSER VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fs = 8000; %Sampling Frequency, to change with GUI
        %fs can be 8000, 11025, 22050, 44100, 48000, and 96000 Hz.
        %Determine hop size, must be less than 1, based off frequency
        hopSize = .1;
        hop = fs*hopSize;
        recTime = 0.125; %250millisecond record time THIS IS HOP SIZE, or HOP RATE
        %recTime = 0.0625 %is slower, recTime will change speed of .208 for
        %48khz
        window = 50;
        cMAX = 65;
        colOption = 'Jet';
        spectragramRUN(fs, window, colOption);
    function spectragramRUN(fs, window, colOption)
        switch fs %setup recording time based on frequency
            case 8000
                fs = 8000;
                recTime = 0.125;
            case 48000
                fs = 48000;
                recTime = 0.208;
        end
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
             'Position',[.8 .025 .19 .974]);  
           %Create label for sampling frequency box
        fsBoxLabel = uicontrol('parent',cPanel,'Style','text',...
            'String','Sampling Frequency',...
            'units','normalized','Position',[.04 .925 .4 .05]);
        %Create sampling freqeuncy drop downbox
        fsBox = uicontrol('parent',cPanel,'style','popupmenu',...
            'units','normalized','Position',[.6 .8 .3 .175],...
            'String',{'8000','11025','22050','44100','48000','96000'},'callback',@fsBoxCallback);
        %Create label for window duration
        windowBoxLabel = uicontrol('parent',cPanel,'Style','text',...
            'String','Window Duration',...
            'units','normalized','Position',[.04 .845 .4 .05]);
        %Create sampling freqeuncy drop downbox
        windowBox = uicontrol('parent',cPanel,'style','edit',...
            'units','normalized','Position',[.6 .8725 .3 .025],...
            'string','time','callback',@windowBoxCallback);
                   
        colMenuLabel = uicontrol('parent',cPanel,'Style','text',...
            'String','Color Map',...
            'units','normalized','Position',[.04 .79 .4 .025]);
        %Create sampling freqeuncy drop downbox
        colMenu = uicontrol('parent',cPanel,'style','popupmenu',...
            'units','normalized','Position',[.6 .8 .3 .025],...
            'Callback',@colMenuCallback,...
            'String',{'Jet','HSV','Lines','Pink','Winter','Spring','Summer','Fall','Cool','Hot','Gray','Copper','Bone'});
        
        %COLORBAR STUFF HERE
        colSlider = uicontrol('parent',cPanel,'style','slider','units','normalized','position',...
            [.125 .24 .1 .51],'callback',@colSliderCallback,'min',0,'max',60,'value',1,...
            'SliderStep',[0.0556 .2778]); %Change max and min here to change sliders
        colorbar('units','normalized','position',[.85 .26 .025 .475]);



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%INFO PANEL%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        iPanel = uipanel('parent',cPanel,'Title','Info Panel','Fontsize',12,...
            'BackgroundColor','white','units','normalized','Position',[.1 .02 .8 .2]);
        fsValue = uicontrol('parent',iPanel,'Style','text',...
            'units','normalized','position',[.6 .8 .3 .125],...
            'BackgroundColor','white','string',fs);
        fsValueLabel = uicontrol('parent',iPanel,'Style','text',...
            'units','normalized','position',[.05 .7 .5 .25],...
            'BackgroundColor','white','string','Sampling Frequency');
        windowValue = uicontrol('parent',iPanel,'Style','text',...
            'units','normalized','position',[.6 .4 .3 .125],...
            'BackgroundColor','white','string',window);
        windowValueLabel = uicontrol('parent',iPanel,'Style','text',...
            'units','normalized','position',[.05 .3 .5 .25],...
            'BackgroundColor','white','string','Window Size');
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%% END OF GUI INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%% ARRAY INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        timeArray = 0:1/fs:20; %create time storage points based on fs until 20 seconds
        timeArray = timeArray-20; %Shifts time array by -20s
        dataArray = timeArray+5000; %shifts input signal, TEMPORARY BEFORE FFT
        %dataArray = zeros(1,length(timeArray));
        tempDataArray = 0:1/fs:20; %This array is for data calculations
        recArray = tempDataArray; %array for FFT data

   

        x=1;%Set loops to infinite!
        while x == 1 %Infinite loop, CTRL+C to stop

            
            recObj = audiorecorder(fs,8,1);
            recordblocking(recObj,recTime);
            tempDataArray = getaudiodata(recObj);
           
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%% FFT CALCULATION HERE %%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            tempDataArray = tempDataArray*5000+5000; %temporary scaling to display signal

            %FILL ARRAY FORWARDS
            i = 1; 
            while i<fs*recTime %this loop fills the dataArray with the "hop" data
                dataArray(i) = tempDataArray(i); %store the hop data
                i=i+1;
            end

            dataArray = circshift(dataArray, [0 -recTime*fs]);

            
            cla %CLA will clear the old dataArray plotted so the circshift doesnt plot over it
            hold on %keep the axes how the user has set them
            plot(timeArray, dataArray); %Create the plot 
            drawnow; %Is this needed??
        end


    function fsBoxCallback(obj,event)
        fs = get(fsBox,'value');
        switch fs
            case 1
                fs = 8000;
            case 2 
                fs = 11025;
            case 3
                fs = 22050;
            case 4
                fs = 44100;
            case 5
                fs = 48000;
            case 6
                fs = 96000;
        end
        spectragramRUN(fs, window, colOption);
    end
    function windowBoxCallback(obj, event)
        window = get(windowBox,'string');
        window = str2num(window);
        if window > 500
            window = 500;
        end
        if window < 10
            window = 10;
        end
        spectragramRUN(fs, window, colOption);
    end
    function colSliderCallback(obj, event)
            cMAX = get(colSlider,'value');
    end
    function colMenuCallback(obj, event)
        colOption = get(colMenu,'value');
        switch colOption
            case 1
                colOption = 'Jet';
            case 2
                colOption = 'HSV';
            case 3
                colOption = 'Lines';
            case 4
                colOption = 'Pink';
            case 5
                colOption = 'Winter';
            case 6
                colOption = 'Spring';
            case 7
                colOption = 'Summer';
            case 8
                colOption = 'Fall';
            case 9
                colOption = 'Cool'; 
            case 10
                colOption = 'Hot';
            case 11
                colOption = 'Gray';
            case 12
                colOption = 'Copper';
            case 13
                colOption = 'Bone';
        end
        spectragramRUN(fs, window, colOption);
    end
    end
end
