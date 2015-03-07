%TODO LIST


function fullcodeTest
        close all; %closes all open figures
        clear
        clc
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%% INITIALUSER VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fs = 8000; %Initial sampling frequency
        WIND = 300; %Initial window size
        colOption = 'Jet'; %Initial colormap
        cMAX = 65;
        spectragramRUN(fs, WIND, colOption)
    function spectragramRUN(fs, WIND, colOption)
        clc
        close all;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%% ARRAY INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        hopRate = 0.05; % in seconds
        hopSize = fs*hopRate;
        timeArray = -20:1/fs:0;
        dataArray = transpose(timeArray);
        N = 2^nextpow2(WIND);
        k = 1:(N/2)+1;
        dataMatrix = zeros (length(k), 20/hopRate); %Final matrix for spectrogram
        freq = (k-1)*fs/N;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%% GUI INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%% FIGURE AND AXES %%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure
        set(gcf, 'doublebuffer','on','units','normalized','position',...
            [0.05 0.05 .75 .75]);
        a = gca; %axis needed for fitting spectrogram
        set(a, 'position',[.085 .085 .7 .9],'visible','off');
        specPlot = imagesc(dataMatrix,'parent',a,'EraseMode','None');
        colormap(colOption);
        set(gca,'YDir','normal');
        set(specPlot,'YData',freq);
        set(specPlot,'XData',timeArray);
        xlabel('Time Elapsed (s)');
        ylabel('Frequency (Hz)');
        
        xlim([-20 0]);
        ylim([0 fs/2]);
       
        %set(specPlot,'xlim',[-20,0]); %Start x-axis range 0-20 seconds
        %set(specPlot,'ylim',[0, 10000]); %Start y-axis range 0-10000 Hz

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SlIDERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Callback functions for the sliders (need to be before slider creation)
        hSliderCallback=('set(gca,''xlim'',[get(gcbo,''value'') 0])');
        vSliderCallback=('set(gca,''ylim'',[0 get(gcbo,''value'')])');
        %Get axis positions for slider placement
        %pos = get(specPlot, 'position'); %Gets position of axes, for normalized units
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
            'String',{'Jet','HSV','Lines','Pink','Winter','Spring','Summer','Autumn','Cool','Hot','Gray','Copper','Bone','Parula'});
        
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
        colormapValue = uicontrol('parent',iPanel,'Style','text',...
            'units','normalized','position',[.6 .2 .3 .125],...
            'BackgroundColor','white','string',colOption);
        colormapValueLabel = uicontrol('parent',iPanel,'Style','text',...
            'units','normalized','position',[.05 .1 .5 .25],...
            'BackgroundColor','white','string','Color Scheme');

 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%% END OF GUI INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



        
   
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%% AUDIO INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        recObj=audiorecorder(fs,16,1);
        record(recObj); %Start recording, or resume
        pause(.3); %pause the mic input for an arbitrary time to get initial data
        recArray = []; %Initialize array for audio input
        

        x=1;%Set loops to infinite!
        while x == 1 %Infinite loop, CTRL+C to stop
            recArray = getaudiodata(recObj); %Get data from the microphone
            [recArrayRowSize, rec_c] = size(recArray);

            if recArrayRowSize < hopSize+1
                %dataArray(1:hopSize-recArrayRowSize,1)=0; %I dont think this is needed
                dataArray((hopSize-recArrayRowSize+1):hopSize)=recArray;
            else
                recArray = recArray((recArrayRowSize-hopSize+1):end,1);
                dataArray(1:hopSize,1)=recArray;
            end

            %tempDataArray = [tempDataArray dataArray];
            if WIND > length(recArray)
                actWIND = length(recArray);
            else
                actWIND = WIND;
            end
            fftData = fft(recArray(1:actWIND),N);
            fftData = fftData(k); %takes first half of the FFT, McNames explained this in class
            dataMatrix(:,1: end-1)=dataMatrix(:,2:end); %shifts columns to the left to make room for new data
            dataMatrix(:,end) = (abs(fftData))'; %CData cannot be complex, so take absolute value
            dataArray = circshift(dataArray,[round(hopSize) 1]); %use circle shift to move the aray

            set(specPlot,'CData',dataMatrix); %update the color data of the matrix

            hold on
            drawnow %updates image
            
            
            %Thisinfo panel stuff has to be here since actWIND updates
            windowValue = uicontrol('parent',iPanel,'Style','text',...
                'units','normalized','position',[.6 .5 .3 .125],...
                'BackgroundColor','white','string',actWIND);
            windowValueLabel = uicontrol('parent',iPanel,'Style','text',...
                'units','normalized','position',[.05 .4 .5 .25],...
                'BackgroundColor','white','string','Window Size');

            
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
        close all;
        spectragramRUN(fs, WIND, colOption);
    end
    end
end
