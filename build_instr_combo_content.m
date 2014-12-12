function user_data=build_instr_combo_content(user_data)

    if isempty(user_data.Instruments)
        user_data.instr_list = {'NIL'};
        user_data.current_instrument_index = 1;
    end

    for i=1:length(user_data.Instruments)

        user_data.instr_list{i} = build_name_string_for_combobox(user_data.Instruments(i));
    end

    set(user_data.instrument_combo,'String',user_data.instr_list);
    set(user_data.instrument_combo,'Value',user_data.current_instrument_index);

    % store data in figure    
    %set(user_data.window_h, 'UserData', user_data);           

end

function name_str = build_name_string_for_combobox(instrument)

    name_str = [instrument.name ' (' num2str(instrument.serial_number) ')'];

end
