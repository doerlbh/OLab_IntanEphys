clear all %Starting a new analysis so we want to eliminate all old variables
close all

 %% Begin with opening file to be analyzed
%
%First we import the data using:
%read_Intan_RHD2000_file = Opens the Matlab file browser UI to locate the 
%file of interest. Afterward it reads header info and establishes basic
%variables from the .rhd file
%
% read_Intan_RHD2000_file
%
%From function info: % Reads Intan Technologies RHD2000 data file generated by evaluation board
% GUI.  Data are parsed and placed into variables that appear in the base
% MATLAB workspace.  Therefore, it is recommended to execute a 'clear'
% command before running this program to clear all other variables from the
% base workspace.

% Modified by Baihan Lin
% Apr 2016

% read_Intan_RHD2000_file_combine
%
% Version 1.3, 10 December 2013
%
% Reads Intan Technologies RHD2000 data file generated by evaluation board
% GUI.  Data are parsed and placed into variables that appear in the base
% MATLAB workspace.  Therefore, it is recommended to execute a 'clear'
% command before running this program to clear all other variables from the
% base workspace.
%
% Example:
% >> clear
% >> read_Intan_RHD200_file
% >> whos
% >> amplifier_channels(1)
% >> plot(t_amplifier, amplifier_data(1,:))

% Here I change it from:
%[file, path, filterindex] = uigetfile('*.rhd', 'Select an RHD2000 Data File', 'MultiSelect', 'off');

% Read most recent file automatically.
%path = 'C:\Users\Reid\Documents\RHD2132\testing\';
%d = dir([path '*.rhd']);
%file = d(end).name;

% I decided to use automatic method for data collection:

prompt = 'What is your folder?: ';
path = input(prompt,'s');
% /Users/DoerLBH/Dropbox/git/OLab_IntanEphys/Data/test

% So that I can specify a folder to access all data files.

%[status, list] = system('cd path');
[~,list] = system(['find ' path ' -type f -name "*.rhd"']);

files = strsplit(list);
length(files);

for countfile = 1:length(files)
    trials{countfile} = files{countfile}(1:end-11);
end

trials = unique(trials);
trials = trials(~cellfun('isempty',trials));

index = strfind(files, trials{1});

for trial = 1 : length(trials)
    index = strfind(files, trials{trial});
    indexmat = cell2mat(index);
    [~,first,~] = unique(indexmat, 'first');
    arrange_Intan_RHD(files{first(trial)});
    
    amp_data = amplifier_data;
    ai_data = aux_input_data;
    bdi_data = board_dig_in_data;
    sv_data = supply_voltage_data;
    t_amp = t_amplifier;
    t_ai = t_aux_input;
    t_d = t_dig;
    t_sv = t_supply_voltage;
    
    if length(index) > 1
        for ind = 2 : length(index)
            if index{ind} == 1
                arrange_Intan_RHD(files{ind});
                amp_data = [amp_data, amplifier_data];
                ai_data = [ai_data, aux_input_data];
                bdi_data = [bdi_data, board_dig_in_data];
                sv_data = [sv_data, supply_voltage_data];
                t_amp = [t_amp, t_amplifier];
                t_ai =  [t_ai,t_aux_input];
                t_d = [t_d, t_dig];
                t_sv = [t_sv, t_supply_voltage];
            end
        end
    end
    
    amplifier_data = amp_data;
    aux_input_data = ai_data;
    board_dig_in_data = bdi_data;
    supply_voltage_data = sv_data;
    t_amplifier = t_amp;
    t_aux_input = t_ai;
    t_dig = t_d;
    t_supply_voltage = t_sv;
    
    disp('----------------')
end


%check what variables have been imported, especially if youre unsure
%whether accessory amplifier channels were disabled or not during recording
%% Establishing some basic variables from values pulled in by above function

amp_chan = 1;
amp_imp = amplifier_channels(1).electrode_impedance_magnitude

for chan = 1 : length(amplifier_channels) 
   if amplifier_channels(chan).electrode_impedance_magnitude < amp_imp
       amp_chan = chan;
   end
end
    
amplifier_channels(amp_chan) %Channel data is being collected on (on 
%preamplifier this would be 'A-004'
%Above command gives data output about the channel on which data is being
%collected

%% Variable name changes below to simplify:

tRat = t_amplifier; %time variable for ephys data
tLED = t_dig; %time variable for LED data
ui.ratData = amplifier_data(amp_chan,:);
lLED = board_dig_in_data(1,:);
rLED = board_dig_in_data(2,:);

% %% Check variables look right-- plot should be identical to last one
% figure % for spike detection
%     hold on
%     plot(tRat, ui.ratData,'blue')
%     plot(tLED,lLED,'red')  %max makes red lines continue across top half of vertical axis
%     plot(tLED,rLED,'green')
%     xlabel 'time (s)'
%     ylabel 'amplitude (A.U.)'
%     legend('Raw Data', 'Left Eye LED','Right Eye LED')

%% filter data
     Wn = 300/10000;                   % Normalized cutoff frequency        
    [b,a] = butter(5,Wn,'high');   
    
    ui.ratData = filtfilt(b,a,ui.ratData);  
    %% invert signal data for thresholding
    ui.ratData = ui.ratData.*(-1);
    
    
    %% Setting threshold for spikes and finding light ON times
threshold = 25;
Fs =  20000; %amplifier_sample_rate
windowSize = Fs * 0.05; %creates our time interval by taking the 20k 
% sampling rate at which the data was collected and converts it to
% timestamps collected every millisecond, in other words the value of
% windowSize is 1 ms.


% Finding all spikes in recording:
    ui.spikes = diff(ui.ratData > threshold) > 0.1;



%% Plot Again with spikes showing & correct time axis now:

time = length(tRat)-1;
figure % for spike detection
    hold on
    plot(tRat(1:time), ui.ratData(1:time),'blue')
    plot(tRat(1:time), ui.spikes*max(ui.ratData),'black')
    plot(tLED(1:time),lLED(1:time)*80,'green')  %max makes red lines continue across top half of vertical axis
    plot(tLED(1:time),rLED(1:time)*80,'red')
    xlabel 'time (s)'
    ylabel 'amplitude (A.U.)'
    legend('Raw Data', 'Spikes', 'Left Eye LED','Right Eye LED')    


    
%% Count spikes during each LED stimulation

 SpikesL = sum(ui.spikes.*lLED(1:end-1))
 SpikesR = sum(ui.spikes.*rLED(1:end-1))   
    
    
    %%   This creates a whole lot of extra light related variables, but unsure if they are actually useful
 
     lightstim = 199; %change?
         ui.leftLEDon = diff(lLED < -lightstim)>0.1;
         ui.rightLEDon = diff(rLED < -lightstim)>0.1;
%         times.leftLED = find(leftLED == 500);
%         times.rightLED = find(rightLED == 500);
%rewrite:
times.lLEDon = find(lLED == 1);
% Gives all time points that left LED is on
    %result is a vector 1 x 80299
times.lLEDoff = find(lLED == 0);
% Gives all time points that left LED is off
    %result is a vector 1 x 1119941
times.rLEDon = find(rLED == 1);
times.rLEDoff = find(rLED == 0);
% the above code will break out the time points when the LED is on for each
% side and when it is off. Next step: 
%           Need to ask it to count how many times ui.spikes takes place
%           during each LEDon segment

%% gets light "on" times into one array
times.lLEDstart = times.lLEDon(diff(times.lLEDon)>Fs*0.05);
    %results in three specific time points for this LED
times.rLEDstart = times.rLEDon(diff(times.rLEDon)>Fs*0.05);
% this turns the times.xLEDon into a list of the points when the LED turned
% on ***Use this for making a raster plot****
    %results in two specific time points for this LED


    %% create raster plots-Left Stim
    % Error: Subscript indices must either be real ve integers or
    % logicals.
    for l = 1:length(times.lLEDstart)
        % collects window of data each time the light stimulus initiated
        windowSize = round(Fs*0.5); % window size in samples
        ui.Lrastercell{l} = ui.spikes(times.lLEDstart(l) - windowSize:times.lLEDstart(l) + windowSize);   
    end
    
    %In original script, variable that's equivalent to 'times.lLEDon' is e.g. 
    % a 23x1 double that includes only the start times for light turning
    % on. Maybe be better to use times.lLEDstart?
    %times.lLedon in this script gives the chunks when led was on, aka a
    %1x80299 double
    
    t.Lraster = transpose((1:length(ui.Lrastercell{1}(:)))/Fs);
    t.Lraster = repmat(t.Lraster,1,length(times.lLEDstart));
    % creates time vector for raster
    
    times.Lrasterlight = 1:(length(times.lLEDstart));
    t.Lrasterlight = ones(1,(length(times.lLEDstart)))*windowSize/Fs;
    % creates dashed line for indicating stim onset on raster plot
    
    ui.Lraster = horzcat(ui.Lrastercell{:}); 
    % concatenates cell array into a double
    
    Lstack = repmat(1:length(times.lLEDstart),length(t.Lraster),1);
    % creates transform for stacking windowed data for the raster plot
    
    %% create raster plots-Right Stim
    % Error: Subscript indices must either be real ve integers or
    % logicals.
    for r = 1:length(times.rLEDstart)
        % collects window of data each time the light stimulus initiated
        windowSize = round(Fs*0.5); % window size in samples
        ui.Rrastercell{r} = ui.spikes(times.rLEDstart(r) - windowSize:times.rLEDstart(r) + windowSize);   
    end
 
    
    t.Rraster = transpose((1:length(ui.Rrastercell{1}(:)))/Fs);
    t.Rraster = repmat(t.Rraster,1,length(times.rLEDstart));
    % creates time vector for raster
    
    times.Rrasterlight = 1:(length(times.rLEDstart));
    t.Rrasterlight = ones(1,(length(times.rLEDstart)))*windowSize/Fs;
    % creates dashed line for indicating stim onset on raster plot
    
    ui.Rraster = horzcat(ui.Rrastercell{:}); 
    % concatenates cell array into a double
    
    Rstack = repmat(1:length(times.rLEDstart),length(t.Rraster),1);
    % creates transform for stacking windowed data for the raster plot
        
    
%% Before running next part, need to find how many times light goes on,
% do this by checking the variable "times.lLEDstart" and "times.rLEDstart".
% It will either show the exact values for the start times or will indicate 
% how many different light on times there are, if trials exceeds ~5.
times


%% this number needs to be input as last value in reshape function below: 
    
    
     ui.LrasterStack = reshape(ui.Lraster,20001,length(times.Lrasterlight));
     ui.RrasterStack = reshape(ui.Rraster,20001,length(times.Rrasterlight));
%% Check plot to verify reshape has been applied appropriately to LEFT data:

    figure % creates raster plot
    plot(t.Lraster,ui.LrasterStack+Lstack-1);
    hold on
    line([0.5 0.5], [0 length(times.Lrasterlight)], 'Color', 'k', 'LineWidth',2)
    %     plot(t.Lrasterlight,times.Lrasterlight,'-black', 'LineWidth',8);
    hold off
    ylabel 'trial number';
    xlabel 'time (s)';
    xlim([0 1]);

    
%% Check plot to verify reshape has been applied appropriately to RIGHT data:

    figure % creates raster plot
    plot(t.Rraster,ui.RrasterStack+Rstack-1);
    hold on
    line([0.5 0.5], [0 length(times.Rrasterlight)], 'Color', 'k', 'LineWidth',2)
    hold off
    ylabel 'trial number';
    xlabel 'time (s)';
    xlim([0 1]);
       
%% Lastly, get spike averages for each eye     
     stats.spikes.Laveon = sum(sum(ui.LrasterStack(windowSize:end,:)))/length(times.lLEDstart);
%     % calculates average number of spikes after light turned on
     stats.spikes.Laveoff = sum(sum(ui.LrasterStack(1:windowSize,:)))/length(times.lLEDstart);
%     % calculates average number of spikes preceding light onset
    

stats.spikes.Laveon
stats.spikes.Laveoff

%% Lastly, get spike avwerages for each eye     
     stats.spikes.Raveon = sum(sum(ui.RrasterStack(windowSize:end,:)))/length(times.rLEDstart);
%     % calculates average number of spikes after light turned on
     stats.spikes.Raveoff = sum(sum(ui.RrasterStack(1:windowSize,:)))/length(times.rLEDstart);
%     % calculates average number of spikes preceding light onset
    

stats.spikes.Raveon
stats.spikes.Raveoff