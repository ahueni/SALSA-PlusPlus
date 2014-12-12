function InstrumentTimeLine(hObject, EventData)

    % get user data
    fh = ancestor(hObject, 'figure');   
    user_data_ = get(fh, 'UserData');
    
    
    % create new window
    user_data.window_h = figure('Units', 'normalized', 'Position', [0 0 0.5 0.5], 'Name', 'SALSA++ Instrument Time Line', 'Color', [0.9 0.9 0.9]);

    set(user_data.window_h,'Toolbar','figure');
    
    
    col1_pos = 0.05;
    col2_pos = 0.68;
    axes_width = 0.5;
    axes_height = 0.2;
    row1_pos = 0.95 - axes_height;
    row2_pos = 0.59 - axes_height;
    
    user_data.instr_time_axes = axes('Parent',user_data.window_h,'Position',[col1_pos row1_pos axes_width axes_height]);  
    
    
    
    channel_info = split_into_channels(user_data_);
    
    % get instrument info for channel A
    progressbar_h = progressbar( [],0,['Getting instrument info for ' num2str(channel_info.raw.a.ids.size()) ' Spectra']); 
    instr_ids = user_data_.specchio_client.getInstrumentIds(channel_info.raw.a.ids);
    
    instrument_ids = zeros(instr_ids.size(), 1);
    
    for i=0:instr_ids.size()-1
        instrument_ids(i+1) = instr_ids.get(i); % get the ids into a matlab array for easier processing       
    end
    
    
    unique_ids = unique(instrument_ids);
    
    processing_steps = 3;
    
    
    
    progressbar( progressbar_h,processing_steps, ['Loading ' size(unique_ids,1) ' instruments']); 
    for i=1:size(unique_ids,1)
        instruments(i) = user_data_.specchio_client.getInstrument(unique_ids(i));
        instrument_names{i} = escape_(char(instruments(i).getInstrumentName()));
        instrument_names_for_combobox{i} = char(instruments(i).getInstrumentName());
        user_data.instr_id_hash.id = unique_ids(i);
        user_data.instr_id_hash.instr = instruments(i);
    end
    
    
    % create drop down list for all instruments
    
    user_data.instr_combo = uicontrol(user_data.window_h, 'Style', 'popup',...
           'Units', 'normalized',...
           'Position', [0.6 0.93 0.3 0.04],  'Callback', @InstrInfo);        
       
    set(user_data.instr_combo,'String',instrument_names_for_combobox);
         
    
    
    
    % get a timeline bar plot 
    progressbar( progressbar_h,processing_steps, ['Loading acquisition times']); 
    capture_times = get_acquisition_times(user_data_.specchio_client, channel_info.raw.a.ids);
    
    % build time series per instrument
    
    progressbar( progressbar_h,processing_steps, ['Creating time series ...']); 

    
    all_instr_ts = timeseries(ones(size(capture_times,1),1), capture_times);
    %set(user_data.window_h,'CurrentAxes',user_data.instr_time_axes);
    axes(user_data.instr_time_axes)
    
    plot(all_instr_ts, '.');
    
    set(0,'DefaultAxesColorOrder',hsv(size(unique_ids,1)))
    colorOrder = get(gca, 'ColorOrder');
    
    %hold all
    hold(user_data.instr_time_axes)
    for i=1:size(unique_ids,1)
        
        index = instrument_ids == unique_ids(i);
        
        instr_ts = timeseries(ones(sum(index),1), capture_times(index));
        
        
        
        plot(instr_ts,'s','MarkerSize',6, 'MarkerFaceColor',colorOrder(i,:), 'MarkerEdgeColor',colorOrder(i,:)); 
        
    end
    legend([{'All Instruments'} instrument_names]);
    

    progressbar( progressbar_h,-1 );
    
    
    % store data in figure    
    set(user_data.window_h, 'UserData', user_data);      
    
    
end



function InstrInfo(hObject, EventData)

    import ch.specchio.gui.*;

    
    % get user data
    fh = ancestor(hObject, 'figure');    
    user_data = get(fh, 'UserData');
    
    index = get(hObject,'Value');
    
    
    instr = user_data.instr_id_hash.instr(index);
    
    
    
    
end



