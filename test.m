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

