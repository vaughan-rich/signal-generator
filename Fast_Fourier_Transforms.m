%% SIGNAL PROCESSING - RICHARD VAUGHAN - SCIENTIFIC COMPUTING WEEK 5

%% MOST OF THE GUI

clear all;
close all;
clc;

% Maximise the figure
scrsz = get(groot,'ScreenSize');
figure('name','FFT Control Panel','Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);
set(gcf,'units','normalized','outerposition',[0 0 1 1]);

% Create Off Button
onoff=uicontrol('Style','togglebutton',...
'Position',[30 35 80 80],'String','Power Off','FontSize',13);

% Create pop-up menu
popup = uicontrol('Style', 'popup', 'String',...
    {'Sine','Square','Saw'},...
    'Position', [1330 275 100 100],'Max',3,'Min',1,'Value',1);
uicontrol('Style','text','Position',[1330 380 100 20],'String','Wave Shape:','FontSize',13);

% Freq range of 1-20 Hz
freq_slider = uicontrol('Style','slider','Position',[20 620 80 20],... 
    'SliderStep',[0.1 0.1],'Max',20,'Min',1,'Value',5);

% Number of points
points_slider = uicontrol('Style','slider','Position',[20 540 80 20],... 
    'SliderStep',[0.01 0.1],'Max',5000,'Min',50,'Value',1000);

% Timespan slider: Range 1-3s
timespan = 3; % initial timespan value
timespan_slider = uicontrol('Style','slider','Position',[20 460 80 20],... 
    'SliderStep',[0.5 0.5],'Max',timespan,'Min',1,'Value',1);

% Phase slider: Range 0-2pi
phase_slider = uicontrol('Style','slider','Position',[20 380 80 20],... 
    'SliderStep',[0.01 0.1],'Max',(2*pi),'Min',0,'Value',0);

% Noise Slider
noise_slider = uicontrol('Style','slider','Position',[20 300 80 20],...
'SliderStep',[0.1 0.1],'Max',1,'Min',0,'Value',0); % Starts off initially with no noise.
uicontrol('Style','text','Position',[1 325 80 20],'String','Noise:','FontSize',13);

% Max Window Slider:
maxwin_slider = uicontrol('Style','slider','Position',[20 140 80 20],... 
    'SliderStep',[0.001 0.01],'Max',1,'Min',0,'Value',1);
uicontrol('Style','text','Position',[15 165 120 20],'String','Max Window Edge:','FontSize',13);
% Min Window Slider:
minwin_slider = uicontrol('Style','slider','Position',[20 220 80 20],... 
    'SliderStep',[0.001 0.01],'Max',1,'Min',0,'Value',0);
uicontrol('Style','text','Position',[15 245 120 20],'String','Min Window Edge:','FontSize',13);

%% THE MAIN PROGRAM BODY

A = 1; % Amplitude always set to 1 Hz. Adding a slider doesn't change much.

% Program starts running immediately + stops when off button pressed
while onoff.Value == onoff.Min
    
    freq = freq_slider.Value;
    uicontrol('Style','text','Position',[15 645 100 30],'String',['Frequency = ',num2str(freq)],'FontSize',13);
    points = round(points_slider.Value); % number of points as integer
    uicontrol('Style','text','Position',[5 565 120 30],'String',['Number of Points = ',num2str(points)],'FontSize',13);
    timespan = round(timespan_slider.Value); % makes sure timespan is an integer also
    t = linspace(0,timespan,points);
    uicontrol('Style','text','Position',[15 485 100 20],'String',['Timespan = ',num2str(timespan)],'FontSize',13);
    phase = phase_slider.Value;
    uicontrol('Style','text','Position',[1 405 100 30],'String',['Phase = ',num2str(phase)],'FontSize',13);
    
    % Generation of random noise: takes slider value and multiplies by
    % random number to produce random noise. Subtraction term ensures that
    % noise acts also in the negative direction.
    noise = (noise_slider.Value*rand(1,points))-(noise_slider.Value/2);
    
    % Windowing array element values
    minwind = round(points * minwin_slider.Value);
    maxwind = round(points * maxwin_slider.Value);
    
    % Prevents element values from becoming zero (and thus producing error)
    if minwind < 1
        minwind = 1;
    end
    if maxwind < 1
        maxwind = 1;
    end
    
    % Stops window edges from crossing middle of generated wave (i.e. stops them
    % from overlapping) - pings them back to inital pos.
    if minwind >= points/2 | maxwind <= points/2 | noise_slider.Value ~= 0
        minwin_slider.Value = 0;
        maxwin_slider.Value = 1;
        mindwind = 1;
        maxwind = points;
    % Note that window is also reset once noise is added and window can't
    % be moved if noise is already present. This is a limitation of my program -
    % this is one failsafe written in to stop it crashing. Windowing + Noise
    % addition/cleaning can't be done simultaneously.
    end
    
    if popup.Value == 1
        y = A*sin(2*pi*freq*t + phase); % Sine wave equation
        y = y + noise; % Adds the previously generated noise
        subplot(2,1,1);
        plot(t,y,'k');
        title('User-Generated Sine Wave with Cleaned-Up Signal in Red','FontSize',15);
        xlabel('Time (s)','FontSize',13);
        ylabel('Displacement (m)','FontSize',13);
        hold on
        bar(t(minwind),1,0.002,'b'); % Plots window edges
        hold on
        bar(t(maxwind),1,0.002,'b');
        hold off
        % Axes here scale with the timespan, but also the proportion of
        % noise added - otherwise there is a risk of the noisy wave
        % exceeding the dimensions of the plot
        axis([0 timespan -A-noise_slider.Value A+noise_slider.Value]);
        drawnow;
        
        % Calculate fourier tranfsorm + power spectrum
        foury = fft(y(minwind:maxwind));
        pow = foury.*conj(foury)/points;
        
        subplot(2,1,2);
        rate = timespan/points;
        % considering nyquist freq.
        xrange = linspace(0,1/(2*rate),length(pow)/2);
        pplt = semilogy(xrange,pow(1:(length(pow)/2)),'g');
        pplt.LineWidth = 2;
        title('Calculated Power Spectrum','FontSize',15);
        xlabel('Frequency (Hz)','FontSize',13);
        ylabel('Power','FontSize',13);
        % scales x axis so that it doesn't get too big (can easily pinpoint freq peak)
        axis([0 (freq*5) 0 10^5]); 
        drawnow;
        
        % CLEANING UP THE NOISY SIGNAL
        
        % only starts cleaning after significant noise and window reset
        if noise_slider.Value >= 0.5 && minwind == 1 && maxwind == points ...
                && minwin_slider.Value == 0 && maxwin_slider.Value == 1
            
        % Find top N values in the power spectrum, and extract their index
        % values 
            N = 10; % Here let's find first 10
            [sorted_pow,indexnum] = sort(pow,'descend');
       
        % Important to recalc. FT as windows have been reset
            foury = fft(y(minwind:maxwind));
            
        % Now go into the fourier transform,
        % take all the unwanted values after the 'top 10 peak'
        % and get rid of them.
            foury(indexnum(N:points)) = 0;
        
        % Then inverse FT and plot on top of original noisy wave
            cleansig = ifft(foury);
            subplot(2,1,1);
            hold on
            csp = plot(t,cleansig,'r');
            csp.LineWidth = 2.5; % Highlights clean signal
            hold off;
            drawnow;
        
        end
              
        % Program now switches to square wave for 2nd menu option 
        % and repeats process as before
        %(hence lack of repeated comments here-on).
        
    elseif popup.Value == 2
        y = A*square(2*pi*freq*t + phase); % generates square wave
        y = y + noise; % Adds the previously generated noise
        subplot(2,1,1);
        plot(t,y,'k');
        title('User-Generated Square Wave with Cleaned-Up Signal in Red','FontSize',15);
        xlabel('Time (s)','FontSize',13);
        ylabel('Displacement (m)','FontSize',13);
        hold on
        bar(t(minwind),1,0.002,'b');
        hold on
        bar(t(maxwind),1,0.002,'b');
        hold off
        axis([0 timespan -A-noise_slider.Value A+noise_slider.Value]);
        drawnow;
        
        foury = fft(y(minwind:maxwind));
        pow = foury.*conj(foury)/points;
        
        subplot(2,1,2);
        rate = timespan/points;
        xrange = linspace(0,1/(2*rate),length(pow)/2);
        pplt = semilogy(xrange,pow(1:(length(pow)/2)),'g');
        pplt.LineWidth = 2;
        title('Calculated Power Spectrum','FontSize',15);
        xlabel('Frequency (Hz)','FontSize',13);
        ylabel('Power','FontSize',13);
        axis([0 (freq*5) 0 10^5]);
        drawnow;
        
        % CLEANING UP THE NOISY SIGNAL
        
        % only starts cleaning after significant noise and window reset
        if noise_slider.Value >= 0.5 && minwind == 1 && maxwind == points ...
                && minwin_slider.Value == 0 && maxwin_slider.Value == 1
        
            N = 10;
            [sorted_pow,indexnum] = sort(pow,'descend');
        
            foury = fft(y(minwind:maxwind));
            foury(indexnum(N:points)) = 0;
        
            cleansig = ifft(foury);
            subplot(2,1,1);
            hold on
            csp = plot(t,cleansig,'r');
            csp.LineWidth = 2.5;
            hold off;
            drawnow;
            
        end
        
        % And once again for menu option 3 - a sawtooth wave
    elseif popup.Value == 3
        
        y = A*sawtooth(2*pi*freq*t + phase); % generates sawtooth wave
        y = y + noise; % Adds the previously generated noise
        subplot(2,1,1);
        plot(t,y,'k');
        title('User-Generated Sawtooth Wave with Cleaned-Up Signal in Red','FontSize',15);
        xlabel('Time (s)','FontSize',13);
        ylabel('Displacement (m)','FontSize',13);
        hold on
        bar(t(minwind),1,0.002,'b');
        hold on
        bar(t(maxwind),1,0.002,'b');
        hold off
        axis([0 timespan -A-noise_slider.Value A+noise_slider.Value]);
        drawnow;
        
        foury = fft(y(minwind:maxwind));
        pow = foury.*conj(foury)/points;
        
        subplot(2,1,2);
        rate = timespan/points;
        xrange = linspace(0,1/(2*rate),length(pow)/2);
        pplt = semilogy(xrange,pow(1:(length(pow)/2)),'g');
        pplt.LineWidth = 2;
        title('Calculated Power Spectrum','FontSize',15);
        xlabel('Frequency (Hz)','FontSize',13);
        ylabel('Power','FontSize',13);
        axis([0 (freq*5) 0 10^5]);
        drawnow;
        
        % CLEANING UP THE NOISY SIGNAL
        
         % only starts cleaning after significant noise and window reset
        if noise_slider.Value >= 0.5 && minwind == 1 && maxwind == points ...
                && minwin_slider.Value == 0 && maxwin_slider.Value == 1
            
            N = 10;
            [sorted_pow,indexnum] = sort(pow,'descend');
        
            foury = fft(y(minwind:maxwind));
            foury(indexnum(N:points)) = 0;
        
            cleansig = ifft(foury);
            subplot(2,1,1);
            hold on
            csp = plot(t,cleansig,'r');
            csp.LineWidth = 2.5;
            hold off;
            drawnow;
            
        end
          
    end
      
end
close all;
disp('Program Ended.');


