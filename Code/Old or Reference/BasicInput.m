clear
clc
fs = 48000;
hopRate = 0.05; % in seconds
hopSize = fs*hopRate;

timeArray = -20:1/fs:0;
dataArray = transpose(timeArray);
recObj = audiorecorder(fs,8,1);

resume(recObj);
pause(.3);
t = 0;
WIND = 50;
N = 256;
k = 1:(N/2)+1;
recArray = [];
dataMatrix = zeros (length(k), 20/hopRate);
%tempDataArray = zeros (length(dataArray),1);

figure
h2 = imagesc(dataMatrix,'EraseMode','None');
freq = (k-1)*fs/N;
colormap jet
set(gca, 'YDir','normal');
%set(h2, 'Colormap',winter);
set(h2,'YData',freq);
set(h2,'XData',timeArray);
xlim([-20 0]);
ylim([0 fs/2]);
x = 1; %SET LOOPS TO INFINITE


while x == 1; %Infinite loop, break with CTRL+C
    recArray = getaudiodata(recObj);
    [recArrayRowSize rec_c] = size(recArray);
    
    if recArrayRowSize < hopSize+1
        %dataArray(1:hopSize-recArrayRowSize,1)=0; %I dont think this is needed
        dataArray((hopSize-recArrayRowSize+1):hopSize)=recArray;
    else
        recArray = recArray((recArrayRowSize-hopSize+1):end,1);
        dataArray(1:hopSize,1)=recArray;
    end
    
    
    %tempDataArray = [tempDataArray dataArray];
    fftData = fft(recArray(1:WIND),N);
    fftData = fftData(k); %takes first half of the FFT, McNames explained this in class
    dataMatrix(:,1: end-1)=dataMatrix(:,2:end); %shifts columns to the left to make room for new data
    dataMatrix(:,end) = (abs(fftData))'; %CData cannot be complex, so take absolute value
    dataArray = circshift(dataArray,[hopSize 1]); %use circle shift to move the aray
    
    set(h2,'CData',dataMatrix); %update the color data of the matrix
    
    
    %plot(recArray);
    hold on
    drawnow %updates image
 end