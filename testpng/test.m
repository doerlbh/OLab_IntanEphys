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