function table=create_report_table(user_data, parent_window_h, position)


    dat = cell(5,1);
    dat{1} = user_data.capture_times{1};
    dat{2} = user_data.capture_times{end};
    dat{3} = num2str(length(user_data.run_info.runs));   
    dat{4} = num2str(user_data.capture_joda_times(end).dayOfMonth().get - user_data.capture_joda_times(1).dayOfMonth().get + 1);
    
    % get spatial position
    first_spectrum_id = java.util.ArrayList(); % assuming the all got the same position
    first_spectrum_id.add(java.lang.Integer(user_data.level0_ids.get(0)));    
    lat_java =  user_data.specchio_client.getMetaparameterValues(first_spectrum_id, 'Latitude');
    lon_java =  user_data.specchio_client.getMetaparameterValues(first_spectrum_id, 'Longitude');  
    
    if lon_java.size() > 0 && lat_java.size() > 0
        dat{5} = ['Lat = ' num2str(lat_java.get(0)) ', Lon = ' num2str(lon_java.get(0))];
    end
    
    cnames = {'Value'};
    rnames = {'Start Time','End Time','Number of runs', 'Number of days covered', 'Location', 'Time zone based on location'};

    
    table = uitable('Units', 'normalized','Parent',parent_window_h,'Data',dat,'ColumnName',cnames,... 
            'RowName',rnames,'Position',position, 'FontSize', 13);
        
    set(table,'ColumnWidth',{300})

end