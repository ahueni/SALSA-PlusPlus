
function user_data = SelectDataFromDB(user_data)

    import ch.specchio.client.*;
    import ch.specchio.queries.*;

    msgbox_h = msgbox('Selecting data from DB');
    
    % get ids of all spectra
    ids = user_data.sdb.get_selected_spectrum_ids();  
    
    
    % check if data were selected
    if(ids.size() > 0)
        
        % store info about selected hierarchy
        user_data.selected_hierarchy_id = user_data.sdb.get_selected_hierarchy_ids();
        
    
        %user_data.qb.qbb.getSelect_query()
        set(user_data.TotalSpectra, 'String', num2str(ids.size()));

        [user_data.all_level0_ids, user_data.level0_ids, level1_ids] = select_ids_from_db(user_data.specchio_client, ids);
        
        if user_data.level0_ids.size > 0


        set(user_data.RAWSpectra, 'String', num2str(user_data.level0_ids.size()));

        set(user_data.ProcessedSpectra, 'String', num2str(level1_ids.size()));    
        

        
        % get instrument info for all spectra
        [user_data.instr_hash, user_data.cal_ids] = get_instrument_hash(user_data);
        
        %user_data.cal_hash = get_calibration_hash(user_data)

        % set instrument name; there should be only one instance here
        if size(user_data.instr_hash , 2) == 1
            
            
            set(user_data.InstrumentInDB, 'String', char(user_data.instr_hash(1).instr.getInstrumentName()));   
            set(user_data.InstrumentInDB, 'BackgroundColor', [0.8 0.9 0.9]);
            
            
            user_data=get_instrument_index(user_data, 1);
            
        else
            % this would result in multiple spaces anyway, i.e. this is an
            % exception that must be caught
            
            set(user_data.InstrumentInDB, 'String', 'Attention: Multiple Instruments!');
            
            set(user_data.InstrumentInDB, 'BackgroundColor', 'r');
            
            
        end

        % store data in figure    
        set(user_data.window_h, 'UserData', user_data);   
        
        else
            
            msgbox('The selected spectra are no dual channel data and not supported by SALSA++!');
            
        end
    
    end
    
    close(msgbox_h);

end



function user_data=get_instrument_index(user_data, instr_hash_index)

    

    % check if wvls calibrations match with currently selected
    % instrument coefficients by comparing the wavelengths based on coeffs for channel A
    % with the SPECCHIO calibration

    bands=1:user_data.instr_hash.instr(instr_hash_index).getNoOfBands;

    % get coefficients of current instrument
    %instr_index = get(user_data.instrument_combo,'Value');
    
    for i=1:length(user_data.Instruments)

        coeffs = user_data.Instruments(i).coeffs_a;

        wvl  = bands.^2*coeffs(1) + bands * coeffs(2) + coeffs(3); % calculate wvl vector

        rmse_values(i) = rmse(user_data.instr_hash.instr.getAverageWavelengths(), wvl');
    
    
    end
    
    % ~ fails in matlab 2009
    [x,user_data.current_instrument_index] = min(rmse_values);
    
    set(user_data.instrument_combo,'Value', user_data.current_instrument_index);
    
    
    

    %             diff = user_data.instr_hash.instr.getAverageWavelengths() - wvl';
    %             figure
    %             plot(diff)

%     disp(['RMSE between database instrument wvls and selected wvls calibration:' num2str(rmse(user_data.instr_hash.instr.getAverageWavelengths(), wvl')) '[nm]']);




end


