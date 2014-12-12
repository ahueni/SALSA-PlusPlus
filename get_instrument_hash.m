function [instr_hash, cal_ids] = get_instrument_hash(user_data)


    ids = user_data.specchio_client.getCalibrationIds(user_data.level0_ids);
    
    % unique_ids = java.util.HashSet(ids); 
    % unique_ids.toArray()
    % fair enough, but still needs conversion to double ...
   
    cal_ids = zeros(ids.size(), 1);
    
    for i=0:ids.size()-1
        cal_ids(i+1) = ids.get(i); % get the ids into a matlab array for easier processing       
    end
    
    instr_hash = [];
    
    unique_ids = unique(cal_ids);
    

    for i=1:size(unique_ids,1)
        instrument = user_data.specchio_client.getCalibratedInstrument(unique_ids(i));
%         instrument_names{i} = escape_(char(instruments(i).getInstrumentName()));
%         instrument_names_for_combobox{i} = char(instruments(i).getInstrumentName());
        instr_hash(i).id = unique_ids(i);
        instr_hash(i).instr = instrument;
    end
    

end
