function TimeCheck(hObject, EventData)

    % get user data
    fh = ancestor(hObject, 'figure');   
    user_data = get(fh, 'UserData');
    
    
    % create new window
    user_data_.window_h = figure('Units', 'normalized', 'Position', [0 0 0.5 0.5], 'Name', 'SALSA++ Instrument Time Line', 'Color', [0.9 0.9 0.9]);

    set(user_data.window_h,'Toolbar','figure');
    
    first_spectrum_id = java.util.ArrayList(); % assuming the all got the same position
    first_spectrum_id.add(java.lang.Integer(user_data.level0_ids.get(0)));
    
    % get spatial position
    lat_java =  user_data.specchio_client.getMetaparameterValues(first_spectrum_id, 'Latitude');
    
    lat = lat_java.get(0);
    
    
    lon_java =  user_data.specchio_client.getMetaparameterValues(first_spectrum_id, 'Longitude');
    
    lon = lon_java.get(0);   
    
    
    

    
end


