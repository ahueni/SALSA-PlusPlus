function BrowseAndFlag(hObject, EventData)

    import javax.swing.JTable;
    import javax.swing.table.DefaultTableModel;
    import java.awt.Dimension;
    import javax.swing.JScrollPane;

    
    % get user data
    fh = ancestor(hObject.hghandle, 'figure'); 
    
    i = 0; % required for some bizarre error: 
    
    md_obj = getappdata(fh, 'ModifyDataClass');
    
    main_user_data = md_obj.parent_user_data;
    
    run = md_obj.run;
    
    % create new window
    window_h = figure('Units', 'normalized', 'Position', [0 0 0.7 0.5], 'Name', ['SALSA++ - Browse & Flag for Cluster' num2str(i)], 'Color', [0.9 0.9 0.9]);
    user_data.window_h = window_h;
    
    set(window_h,'Toolbar','figure');
    
    
    col1_pos = 0.3;
    col2_pos = 0.65;
    axes_width = 0.3;
    axes_height = 0.35;
    row1_pos = 0.9 - axes_height;
    row2_pos = 0.45 - axes_height;
    
    user_data.A_axes = axes('Parent',window_h,'Position',[col1_pos row1_pos axes_width axes_height]);  
    user_data.B_axes = axes('Parent',window_h,'Position',[col2_pos row1_pos axes_width axes_height]);       

    user_data.A_time_axes = axes('Parent',window_h,'Position',[col1_pos row2_pos axes_width axes_height]);  
    user_data.B_time_axes = axes('Parent',window_h,'Position',[col2_pos row2_pos axes_width axes_height]);  
    
    % only create button if there is a ModifyDataClass window existing
    if ~isempty(md_obj.window_h )
        gbutton=jcontrol(window_h, javax.swing.JButton('Apply in Cluster Window'), 'Position', [0.69 0.96 0.2 0.04]);
        set(gbutton, 'MouseClickedCallback', @ApplyInClusterModificationWindow);     
    end
    
    model = matlab_integration.SpectraNamesAndFlagsTableModel();
		

    model.addColumn('Filename');
    model.addColumn('DC Flag');
    model.addColumn('Garbage Flag');
    model.setRowCount(run.original_ids_per_channel.a.size());

    user_data.SpectraNamesAndFlagsTableModel = model;

    table = JTable(model);
    d =  Dimension(350,150);
    table.setPreferredScrollableViewportSize(d);   
    
    
    
    filenames = main_user_data.specchio_client.getMetaparameterValues(run.original_ids_per_channel.a, 'File Name');    
    

    dc_spectra_ids = main_user_data.specchio_client.filterSpectrumIdsByHavingAttribute(run.original_ids_per_channel.a, 'DC Flag');
    garbage_spectra_ids = main_user_data.specchio_client.filterSpectrumIdsByHavingAttribute(run.original_ids_per_channel.a, 'Garbage Flag');
    
    for i=0:filenames.size() - 1
        
        cur_id = run.original_ids_per_channel.a.get(i);
        
        table.setValueAt(filenames.get(i), i, 0);
        
        if dc_spectra_ids.contains(java.lang.Integer(cur_id)) % integer conversion needed, otherwise it is Double!
            table.setValueAt(java.lang.Boolean(true), i, 1);
        else       
            table.setValueAt(java.lang.Boolean(false), i, 1);
        end
        
         if garbage_spectra_ids.contains(java.lang.Integer(cur_id)) % integer conversion needed, otherwise it is Double!
            table.setValueAt(java.lang.Boolean(true), i, 2);
        else       
            table.setValueAt(java.lang.Boolean(false), i, 2);
        end       
        
    end
    
    scroll_pane =  JScrollPane();
    
    scroll_pane.getViewport().add(table);
    
    
    table_h=jcontrol(window_h, scroll_pane, 'Position', [0 0.0 0.28 1]);
    
    % add listener to table
    set(table, 'MouseClickedCallback', {@DisplaySelectedSpectra,window_h});     
    set(table, 'KeyPressedCallback', {@DisplaySelectedSpectra,window_h});
    set(model, 'TableChangedCallback', {@FlagEdit,window_h});
    

    user_data.browse_and_flag.jtable = table;
    
    
    
%     set(fh, 'UserData', user_data); % store in main window   

    user_data.main_user_data = main_user_data;
    user_data.md_obj = md_obj;
    user_data.run =run;
    
    % store    
    set(window_h, 'UserData', user_data);          
    
    % display first row
    table.changeSelection(0,0, 1, 0);
    DisplaySelectedSpectra(0, 0, window_h);
    

    
end



function ApplyInClusterModificationWindow(hObject, EventData)


    % get user data
    fh = ancestor(hObject.hghandle, 'figure'); 
    user_data = get(fh, 'UserData');
    
    msgbox_h = msgbox(['Reloading data from DB for cluster ' user_data.md_obj.current_cluster_index]);
    
    user_data.run.reload();
    
    
    user_data.md_obj.plot_data();
    
    
    close(msgbox_h);
    
    
end


function DisplaySelectedSpectra(hObject, EventData, window_h)


    % get user data
    user_data = get(window_h, 'UserData');
        

    % get the selected row
    row_index = user_data.browse_and_flag.jtable.getSelectedRows() + 1;


    
    user_data.run.plot_raw(user_data.A_axes, user_data.B_axes, row_index);

% 
%     
%     plot_2d(user_data.browse_and_flag.A_axes, user_data.runr.a, 'Channel A - RAW', row_index);
%     plot_2d(user_data.browse_and_flag.B_axes, user_data.all_level0.b, 'Channel B - RAW', row_index);

     
    %band = user_data.spectral_pos_slider.getValue();
    band = 50;
    
    
   % band = user_data.spectral_pos_slider.getValue();

    user_data.run.plot_raw_band_versus_time(user_data.A_time_axes, user_data.B_time_axes, band, '*');
    hold(user_data.A_time_axes)
    hold(user_data.B_time_axes)
    
    user_data.run.plot_raw_band_versus_time(user_data.A_time_axes, user_data.B_time_axes, band, '-', 'b');
    
    hold(user_data.A_time_axes)
    hold(user_data.B_time_axes)
    
    datetick(user_data.A_time_axes, 'x','HH:mm')
    xlabel(user_data.A_time_axes, 'Time');
    ylabel(user_data.A_time_axes, 'DN');
    
    datetick(user_data.B_time_axes, 'x','HH:mm')
    xlabel(user_data.B_time_axes, 'Time');
    ylabel(user_data.B_time_axes, 'DN');
    
    
    user_data.run.plot_marker_on_time_lines(user_data.A_time_axes, user_data.B_time_axes, band, row_index);
    
    
    % create time series
%     irrad_ts = timeseries(user_data.all_level0.a.vectors(:, band), user_data.all_level0.a.capture_times);
%     rad_ts = timeseries(user_data.all_level0.b.vectors(:, band), user_data.all_level0.b.capture_times);
%     
%     selected_point_irrad_ts = timeseries(user_data.all_level0.a.vectors(row_index, band), {user_data.all_level0.a.capture_times{row_index}});
%     selected_point_rad_ts = timeseries(user_data.all_level0.b.vectors(row_index, band), {user_data.all_level0.b.capture_times{row_index}});
%     
%     
%     set(user_data.browse_and_flag.window_h,'CurrentAxes',user_data.browse_and_flag.A_time_axes);
%     plot(irrad_ts);
%     hold(user_data.browse_and_flag.A_time_axes)    
%     plot(irrad_ts, 'og', 'MarkerFaceColor', 'g');
%     plot(selected_point_irrad_ts, '*r', 'MarkerFaceColor', 'r', 'MarkerSize', 15);
%     hold(user_data.browse_and_flag.A_time_axes)
%     title(user_data.browse_and_flag.A_time_axes, ['Sky Irradiance over time @ ' num2str(user_data.all_level0.a.wvl(band)) 'nm']);
%     
%     set(user_data.browse_and_flag.window_h,'CurrentAxes',user_data.browse_and_flag.B_time_axes);
%     
%     plot(rad_ts);
%     hold(user_data.browse_and_flag.B_time_axes);
%     plot(rad_ts, 'og', 'MarkerFaceColor', 'g');
%     plot(selected_point_rad_ts, '*r', 'MarkerFaceColor', 'r', 'MarkerSize', 15);
%     hold(user_data.browse_and_flag.B_time_axes);
%     title(user_data.browse_and_flag.B_time_axes, ['Ground Radiance over time @ ' num2str(user_data.all_level0.b.wvl(band)) 'nm']);
        
    

end



function FlagEdit(hObject, EventData, window_h)

    import ch.specchio.types.MetaParameter;

    % get user data
    user_data = get(window_h, 'UserData');
    main_user_data = user_data.main_user_data;
    

    
    row = EventData.getFirstRow();    
    col = EventData.getColumn();
    
    if col == 1 || col == 2
    
        % get the actual value
        flag = user_data.SpectraNamesAndFlagsTableModel.getValueAt(row, col);

        ids = java.util.ArrayList();

        % add A and B spectra ids
        ids.add(java.lang.Integer(user_data.run.original_ids_per_channel.a.get(row)));
        ids.add(java.lang.Integer(user_data.run.original_ids_per_channel.b.get(row)));    

        if col == 1 % DC flag
            flag_name = 'DC Flag';
        end

        if col == 2 % Garbage flag
            flag_name = 'Garbage Flag';
        end  

        flag_attribute = main_user_data.specchio_client.getAttributesNameHash().get(flag_name);

        if flag == 1
            % insert flag            
            e = MetaParameter.newInstance(flag_attribute);
            e.setValue(1);
            
            main_user_data.specchio_client.updateEavMetadata(e, ids);

        else

            % remove flag            
            main_user_data.specchio_client.removeEavMetadata(flag_attribute, ids);

        end

    
    end

end





