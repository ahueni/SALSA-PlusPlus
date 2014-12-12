function cal_hash = get_calibration_hash(user_data)


    channel_info = split_into_channels(user_data);
    
    ids = user_data.specchio_client.getCalibrationIds(channel_info.raw.a.ids);
    
    % unique_ids = java.util.HashSet(ids); 
    % unique_ids.toArray()
    % fair enough, but still needs conversion to double ...
   
    cal_ids = zeros(ids.size(), 1);
    
    for i=0:cal_ids.size()-1
        cal_ids(i+1) = ids.get(i); % get the ids into a matlab array for easier processing       
    end
    
    
    unique_ids = unique(cal_ids);
    
%     for i=1:size(unique_ids,1)
%         instruments(i) = user_data.specchio_client.getInstrument(unique_ids(i));
% %         instrument_names{i} = escape_(char(instruments(i).getInstrumentName()));
% %         instrument_names_for_combobox{i} = char(instruments(i).getInstrumentName());
%         instr_hash.id = unique_ids(i);
%         instr_hash.instr = instruments(i);
%     end
    

end
