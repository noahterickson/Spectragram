%Noah Erickson and Dario Morote
%ECE 312 Fourier Analysis - Dr. James McNames
%Portland State  University - ECE Department
%This program will take the real time fft of microphone input and display
%it in a good looking spectrogram housed in an awesome GUI.
function spectrogramFINAL
        close all; %closes all open figures
        clear %Clears workspace
        clc %Clears command window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%% INITIALUSER VARIABLES %%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fs = 8000; %Initial sampling frequency
        WIND = 270; %Initial window size
        colOption = 'jet'; %Initial colormap
        spectragramRUN(fs, WIND, colOption) %Call the function to run
    function spectragramRUN(fs, WIND, colOption)
        close all %closes all open figures
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%% ARRAY INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        hopRate = 0.05; %Hoprate of 50 ms, this translates to a 20Hz estimate rate
        hopSize = fs*hopRate; %How many datapoints to go in the hop, function of sampling rate
        timeArray = -20:1:0; %Setup the time array 
        dataArray = transpose(timeArray); %Data array 
        N = 2^nextpow2(WIND)*4; %N is the zero padding variable, function of window size
        if fs > 42000 %if high sampling rate, need sufficient zero padding, so increase it
            N = 2^12; %2048
            if fs > 47900 %Increase zero padding even more
                N = 2^12; %4096
            end
        end
        k = 1:(N/2)+1; %Half the FFT length
        dataMatrix = zeros (length(k), 20/(hopRate)); %Initialize final matrix for spectrogram
        freq = (k-1)*fs/N; %Frequencies needed to plot in spectrogram axis
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%% GUI INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%% FIGURE AND AXES %%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure %initialize figure
        set(gcf, 'doublebuffer','on','units','normalized','position',...
            [0.05 0.05 .75 .75]); %Set position of initial window
        a = gca; %axis needed for housing spectrogram
        set(a, 'position',[.085 .085 .7 .9],'visible','off'); %Position the FFT
        specPlot = imagesc(dataMatrix,'parent',a,'EraseMode','None'); %Initialize spectrogram
        caxis([0 100]); %Set the inital Caxis max to 100
        colormap(colOption); %Set the CData Color scheme
        set(gca,'YDir','normal'); %Set YDir to do top to bottom frequencies
        set(specPlot,'YData',freq); %Axis frequency data
        set(specPlot,'XData',timeArray); %Axis time data, not too important
        xlabel('Time Elapsed (s)'); %axis label
        ylabel('Frequency (Hz)'); %axis label   
        xlim([-10 0]); %initial axes
        ylim([0 fs/2]); %initial axes
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SlIDERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Callback functions for the sliders (need to be before slider creation)
        hSliderCallback=('set(gca,''xlim'',[get(gcbo,''value'') 0])');
        vSliderCallback=('set(gca,''ylim'',[0 get(gcbo,''value'')])');
        %Get axis positions for slider placement
        pos = get(gca, 'position'); %Gets position of axes, for normalized units
        hSliderPos=[pos(1) 0.01 pos(3) 0.025]; %Sets relative position
        vSliderPos=[0.01 pos(2) .025 pos(4)]; %Sets relative position
        %Create time slider
        hSlider = uicontrol('style','slider','units','normalized','position',...
        hSliderPos,'callback',hSliderCallback,'min',-20,'max',-2,'value',-2,...
        'SliderStep',[0.0556 .2778]); %Change max and min here to change sliders
        %Create frequency slider
        vSlider = uicontrol('style','slider','units','normalized','position',...
            vSliderPos,'callback',vSliderCallback,'min',100,'max',fs/2,'value',100,...
            'SliderStep',[0.0556 .2778]); %Change max and min here to change sliders
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% CONTROL PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cPanel = uipanel('Title','Control Panel','FontSize',12,...
             'Position',[.8 .025 .19 .974]);  
        %Create label for sampling frequency box
        fsBoxLabel = uicontrol('parent',cPanel,'Style','text',...
            'String','Sampling Frequency',...
            'units','normalized','Position',[.04 .925 .4 .05]);
        %Create sampling freqeuncy drop down
        fsBox = uicontrol('parent',cPanel,'style','popupmenu',...
            'units','normalized','Position',[.6 .8 .3 .175],...
            'String',{'8000','11025','22050','44100','48000','96000'},'callback',@fsBoxCallback);
        %Create label for window duration
        windowBoxLabel = uicontrol('parent',cPanel,'Style','text',...
            'String','Window Duration',...
            'units','normalized','Position',[.04 .845 .4 .05]);
        %Create window dropdown
        windowBox = uicontrol('parent',cPanel,'style','edit',...
            'units','normalized','Position',[.6 .8725 .3 .025],...
            'string','time','callback',@windowBoxCallback);
        %Label for color scheme box
        colMenuLabel = uicontrol('parent',cPanel,'Style','text',...
            'String','Color Map',...
            'units','normalized','Position',[.04 .79 .4 .025]);
        %Create Color scheme dropdown box
        colMenu = uicontrol('parent',cPanel,'style','popupmenu',...
            'units','normalized','Position',[.6 .8 .3 .025],...
            'Callback',@colMenuCallback,...
            'String',{'Jet','HSV','Lines','Pink','Winter','Spring','Summer','Autumn','Cool','Hot','Gray','Copper','Bone','Parula'});
        %Colorbar creation
        colSliderCallback = ('set(caxis([0 get(gcbo,''value'')]))'); %Adjust caxis max value
        colSlider = uicontrol('parent',cPanel,'style','slider','units','normalized','position',...
            [.125 .24 .1 .51],'callback',colSliderCallback,'min',0,'max',100,'value',1,...
            'SliderStep',[0.0556 .2778]); %Change max and min here to change sliders
        colorbar('units','normalized','position',[.85 .26 .025 .475]); %Create the color bar, automattically updated with color scheme
        %Refresh button
        refreshButtonLabel = uicontrol('parent',cPanel,'style','text',...
            'units','normalized','position',[.5 .275 .45 .1],'string', 'Running slow?');
        refreshButton = uicontrol('parent',cPanel,'style','pushbutton','units','normalized','position',...
            [.5 .25 .45 .1],'string','Refresh!','callback',@refreshButtonCallback);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%INFO PANEL%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        iPanel = uipanel('parent',cPanel,'Title','Info Panel','Fontsize',12,...
            'BackgroundColor','white','units','normalized','Position',[.1 .02 .8 .2]);
        fsValue = uicontrol('parent',iPanel,'Style','text',...
            'units','normalized','position',[.6 .8 .3 .125],...
            'BackgroundColor','white','string',fs);
        fsValueLabel = uicontrol('parent',iPanel,'Style','text',...
            'units','normalized','position',[.05 .7 .5 .25],...
            'BackgroundColor','white','string','Sampling Frequency');
        zeroPadValue = uicontrol('parent',iPanel,'Style','text',...
            'units','normalized','position',[.6 .44 .3 .125],...
            'BackgroundColor','white','string',N);
        zeroPadLabel = uicontrol('parent',iPanel,'Style','text',...
            'units','normalized','position',[0.05 .42 .5 .15],...
            'BackgroundColor','white','string','Zero Padding');
        colormapValue = uicontrol('parent',iPanel,'Style','text',...
            'units','normalized','position',[.6 .1 .3 .1],...
            'BackgroundColor','white','string',colOption);
        colormapValueLabel = uicontrol('parent',iPanel,'Style','text',...
            'units','normalized','position',[.05 .1 .5 .1],...
            'BackgroundColor','white','string','Color Scheme');
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%% END OF GUI INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%% AUDIO INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        recObj=audiorecorder(fs,8,1); %initialize audiorecorder to recObj handle
        record(recObj); %Start recording with microphone
        pause(.3); %pause the mic input for an arbitrary time to get initial data
        recArray = []; %Initialize array for audio input

        x=1;%Set loops to infinite!
        while x == 1 %Infinite loop, CTRL+C to stop
            tic;
            recArray = getaudiodata(recObj); %Get data from the microphone
            [recArrayRowSize, rec_c] = size(recArray);

            
            if recArrayRowSize < hopSize+1
                %dataArray(1:hopSize-recArrayRowSize,1)=0; %I dont think this is needed
                dataArray((hopSize-recArrayRowSize+1):hopSize)=recArray;
            else
                recArray = recArray((recArrayRowSize-hopSize+1):end,1);
                dataArray(1:hopSize,1)=recArray;
            end
            
            %DETERMINE WINDOW SIZE
            if WIND > length(recArray) %we cant get more data in an array than is in an array
                actWIND = length(recArray); %So if window is bigger than recarray size limit it
            else
                actWIND = WIND;
            end
            
            
            fftData = fft(recArray(1:actWIND),N);
            fftData = fftData(k); %takes first half of the FFT, McNames explained this in class
            dataMatrix(:,1: end-1)=dataMatrix(:,2:end); %shifts columns to the left to make room for new data
            dataMatrix(:,end) = (abs(fftData))'; %CData cannot be complex, so take absolute value

            set(specPlot,'CData',dataMatrix); %update the color data of the matrix

            hold on %hold on!
            drawnow %updates image

            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%% MORE GUI STUFF AFTER FFT %%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            windowValue = uicontrol('parent',iPanel,'Style','text',...
                'units','normalized','position',[.6 .62 .3 .125],...
                'BackgroundColor','white','string',actWIND);
            windowValueLabel = uicontrol('parent',iPanel,'Style','text',...
                'units','normalized','position',[.05 .62 .5 .15],...
                'BackgroundColor','white','string','Window Size');
            refreshValueLabel = uicontrol('parent',iPanel,'Style','text',...
                'units','normalized','Position',[0.05 .23 .5 .15],...
                'BackgroundColor','white','string','Display refresh');
            refreshValue = uicontrol('parent',iPanel,'Style','text',...
                'units','normalized','position',[.6 .25 .3 .125],...
                'BackgroundColor','white','string',1/toc);
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
            otherwise
                fs = 8000;
        end
        spectragramRUN(fs, WIND, colOption);
    end
    function windowBoxCallback(obj, event)
        WIND = get(windowBox,'string');
        WIND = str2num(WIND);
        if WIND > 500
            WIND = 500;
        end
        if WIND < 10
            WIND = 10;
        end
        spectragramRUN(fs, WIND, colOption);
    end
    function refreshButtonCallback(obj, event)
        spectragramRUN(fs, WIND, colOption);
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
                colOption = 'Autumn';
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
            case 14
                colOption = 'parula';
            otherwise
                colOption = 'Jet';
        end
        spectragramRUN(fs, WIND, colOption);
    end
    end
end
