function StoreInDB(hObject, EventData)

    
    
    % get user data
    fh = ancestor(hObject.hghandle, 'figure');    
    main_user_data = get(fh, 'UserData');
    
    
    
    
    % create new window
    window_h = figure('Units', 'normalized', 'Position', [0 0 0.5 0.9], 'Name', ['SALSA++ - Store Runs in DB'], 'Color', [0.9 0.9 0.9]);
    user_data.window_h = window_h;
    
    set(window_h,'Toolbar','figure');
    
    no_of_runs = length(main_user_data.runs);
    
    margin = 0.05;
    plot_height_dist = 0.97 / no_of_runs;
    plot_height = plot_height_dist - margin;
    
    %
    for i=1:no_of_runs
        
        
        h=subplot(no_of_runs,1,i);
        set(h, 'Position', [0.05, 1-(plot_height_dist*i), 0.52, plot_height])
    
        main_user_data.runs(i).plotHCRFs(h);
        
        % create check boxes
        user_data.run_checkbox(i) = javax.swing.JCheckBox(num2str(i));
        jcontrol(user_data.window_h, user_data.run_checkbox(i), 'Position', [0.7 (1-(plot_height_dist*i) + plot_height/2) 0.05 0.05]); 

        user_data.run_checkbox(i).setSelected(1);    
        
    
    end
    
    gbutton=jcontrol(user_data.window_h, javax.swing.JButton('Store selected runs in database'), 'Position', [0.65 0.95 0.3 0.03]);
    set(gbutton, 'MouseClickedCallback', @Store);   
    
    
    user_data.main_user_data = main_user_data;
    
    % store    
    set(window_h, 'UserData', user_data);      
    

end



function Store(hObject, EventData)

    import ch.specchio.types.*;

    % get user data
    fh = ancestor(hObject.hghandle, 'figure'); 
    user_data = get(fh, 'UserData');
    
    main_user_data = user_data.main_user_data;
    
    no_of_runs = length(main_user_data.runs);
    
    % move up in the hierarchy to the level where the RAW resides and
    % insert new 'Processed' hierarchy

    % get directory of first spectrum
    s = main_user_data.specchio_client.getSpectrum(main_user_data.runs(1).wvl_int.R.ids.get(0), false);  % load first spectrum to get the hierarchy
    current_hierarchy_id = s.getHierarchyLevelId();
        

    first_parent_id = main_user_data.specchio_client.getHierarchyParentId(current_hierarchy_id);  
    second_parent_id = main_user_data.specchio_client.getHierarchyParentId(first_parent_id);  
    
    campaign = main_user_data.specchio_client.getCampaign(s.getCampaignId());
    
    processed_hierarchy_id = main_user_data.specchio_client.getSubHierarchyId(campaign, 'Reflectance', second_parent_id);    
    
    
    new_spectrum_ids = java.util.ArrayList();
    
    no_of_spectra_to_insert = 0;
    for n=1:no_of_runs
        if user_data.run_checkbox(n).isSelected()
            no_of_spectra_to_insert = no_of_spectra_to_insert + main_user_data.runs(n).wvl_int.R.ids.size();
        end
    end
    
    
     progressbar_h = progressbar( [],0,['Storing ' num2str(no_of_spectra_to_insert) ' Reflectance Spectra']); 
     
     run_attribute = main_user_data.specchio_client.getAttributesNameHash().get('Tram Run');
     
     % insert reflectances for all selected runs
     for n=1:no_of_runs
         
         if user_data.run_checkbox(n).isSelected()
                          
             for i=0:main_user_data.runs(n).wvl_int.R.ids.size()-1
                 
                 % copy the spectrum to new hierarchy
                 new_spectrum_id = main_user_data.specchio_client.copySpectrum(main_user_data.runs(n).wvl_int.R.ids.get(i), processed_hierarchy_id);
                                
                 % replace spectral data
                 vector = main_user_data.runs(n).wvl_int.R.vectors(i+1,:);
                 main_user_data.specchio_client.updateSpectrumVector(new_spectrum_id, vector);
                                 
                 new_spectrum_ids.add(java.lang.Integer(new_spectrum_id));     
                 main_user_data.runs(n).R_spectrum_ids.add(java.lang.Integer(new_spectrum_id));
                 
                 progressbar( progressbar_h,1/no_of_spectra_to_insert );
                 
             end     
             
             % add tram run number for the spectra of this run
             e = MetaParameter.newInstance(run_attribute);
             e.setValue(java.lang.Integer(n));
             main_user_data.specchio_client.updateEavMetadata(e, main_user_data.runs(n).R_spectrum_ids);
             
         end   
         
         
     end
    
    metasteps = 4;
    
    
    % change EAV entry to new Processing Level by removing old and inserting new
    progressbar( progressbar_h,metasteps, 'Updating processing level'); 
    
    attribute = main_user_data.specchio_client.getAttributesNameHash().get('Processing Level');
    
    main_user_data.specchio_client.removeEavMetadata(attribute, new_spectrum_ids);
    
    
    e = MetaParameter.newInstance(attribute);
    e.setValue(1.0);
    main_user_data.specchio_client.updateEavMetadata(e, new_spectrum_ids);
    
    % remove the channel metadata
%     attribute = user_data.specchio_client.getAttributesNameHash().get('Instrument Channel');
%     
%     user_data.specchio_client.removeEavMetadata(attribute, new_spectrum_ids);    
    
    
    % change sensor and instrument  
    progressbar( progressbar_h,metasteps/2, 'Updating sensor info');
    
    sensors = main_user_data.specchio_client.getSensors();
    sensor_index = 1;
    while (~strcmp(sensors(sensor_index).getName().get_value(), 'UniSpec_DC_305-1105_ip'))
        sensor_index = sensor_index + 1;
    end
    
    main_user_data.specchio_client.updateSpectraMetadata(new_spectrum_ids, 'sensor', sensors(sensor_index).getSensorId());
    
    main_user_data.specchio_client.updateSpectraMetadata(new_spectrum_ids, 'instrument', 0);
    
    
    % set unit to reflectance
    progressbar( progressbar_h,metasteps/3, 'Updating units');
    
    category_values = main_user_data.specchio_client.getMetadataCategoriesForNameAccess(Spectrum.MEASUREMENT_UNIT);
    reflectance_id = category_values.get('Reflectance');
    main_user_data.specchio_client.updateSpectraMetadata(new_spectrum_ids, 'measurement_unit', reflectance_id);
    
    
    % set beam geometry to hemispherical-conical
    progressbar( progressbar_h,metasteps/4, 'Setting beam geometry');
    
    beam_geometry_attribute = main_user_data.specchio_client.getAttributesNameHash().get('Beam Geometry');
    beam_id = main_user_data.specchio_client.getTaxonomyId(beam_geometry_attribute.getId(), 'Hemispherical-conical (CASE 8)');
    
    e = MetaParameter.newInstance(beam_geometry_attribute);
    e.setValue(beam_id);
    main_user_data.specchio_client.updateEavMetadata(e, new_spectrum_ids);
    
    progressbar( progressbar_h,-1 );
    
    
    msgbox(['Reflectances are stored in DB (' num2str(new_spectrum_ids.size()) ' spectra were inserted)'],'SALSA++');
    
    
end


