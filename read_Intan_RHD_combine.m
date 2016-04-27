function read_Intan_RHD_combine

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

for trial = 1 : length(trials)
    
    index = strfind(files, trials{trial});
    amplifier_data
    aux_input_data
    board_dig_in_data
    supply_voltage_data
    t_amplifier
    t_aux_input
    t_dig
    t_supply_voltage
    
    for ind = 1 : length(index)
        if index{ind} == 1
            arrange_Intan_RHD(files{ind});
            
        end
    end
    disp('----------------')
end

%%
arrange_Intan_RHD(path, file)
