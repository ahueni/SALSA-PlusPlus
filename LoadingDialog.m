function LoadingDialog(hObject, EventData)

    
    % get user data
    fh = ancestor(hObject.hghandle, 'figure');    
    user_data = get(fh, 'UserData');
    

    


     % create new window
    dlg_user_data.window_h = figure('Units', 'normalized', 'Position', [0 0 0.5 0.5], 'Name', 'SALSA++ Loading Dialog', 'Color', [0.9 0.9 0.9]);

    set(dlg_user_data.window_h,'Toolbar','figure');
    
    
    col1_pos = 0.05;
    col2_pos = 0.5;
    axes_width = 0.4;
    axes_height = 0.3;
    row1_pos = 0.90 - axes_height;
    row2_pos = 0.59 - axes_height;
    
    no_box_height = 0.03;
    no_box_x_pos = 0.2;
    no_box_y_pos_1 = row1_pos-0.09;

    font_size = 13;
    
    
    dlg_user_data.time_cluster_axes = axes('Parent',dlg_user_data.window_h,'Position',[col1_pos row1_pos axes_width axes_height]);  
    dlg_user_data.cal_cluster_axes = axes('Parent',dlg_user_data.window_h,'Position',[col2_pos row1_pos axes_width axes_height]);  
    
    
    % sliders
    dlg_user_data.cluster_time_slider = javax.swing.JSlider(javax.swing.SwingConstants.HORIZONTAL, 1, 360, 10);

    slider = jcontrol(dlg_user_data.window_h, dlg_user_data.cluster_time_slider, 'Position', [col1_pos-0.05 row1_pos-0.15 0.5 0.05 ]);
    set(slider, 'StateChangedCallback', @ClusterTimeChange);
    
    
    dlg_user_data.ClusterTimeText = uicontrol(dlg_user_data.window_h,'Style','text',...
                'String','Time cluster gap [minutes]:',...
                'Units', 'normalized','FontSize', font_size,...
                'Position',[no_box_x_pos no_box_y_pos_1 0.18 no_box_height], 'BackgroundColor', [0.9 0.9 0.9]);   
    
    
    dlg_user_data.ClusterTime = uicontrol(dlg_user_data.window_h,'Style','text',...
            'String',num2str(dlg_user_data.cluster_time_slider.getValue()),...
            'Units', 'normalized','FontSize', font_size,...
            'Position',[no_box_x_pos+0.2 no_box_y_pos_1 0.05 no_box_height], 'BackgroundColor', [0.8 0.9 0.9]);   
    
    
    % buttons    
    dlg_user_data.LoadButton=jcontrol(dlg_user_data.window_h, javax.swing.JButton('Load designated acquisition clusters'), 'Position', [0.55 row1_pos-0.15 0.4 0.05]);
    set(dlg_user_data.LoadButton, 'MouseClickedCallback', @Load); 
       
    
    % get acquisition times
    [user_data.capture_times, user_data.capture_times_in_millis, user_data.capture_joda_times] = get_acquisition_times(user_data.specchio_client, user_data.level0_ids);
    
    user_data.unique_cal_ids = unique(user_data.cal_ids);
    
    dlg_user_data.parent_user_data = user_data;
    

    
    % carry out a time analysis first to define clusters
    dlg_user_data=displayData(dlg_user_data);
    
    
    
    % store data in figure    
    set(dlg_user_data.window_h, 'UserData', dlg_user_data);   
    

    %LoadDataFromDB(user_data)

end


function dlg_user_data=displayData(dlg_user_data)

    user_data=dlg_user_data.parent_user_data;

    
    
    
    
    % sort to make sure time is monotonously increasing (sorting of ids
    % could not be proper at this point?)
    %[user_data.capture_times_in_millis, ind] = sort(user_data.capture_times_in_millis);
    %user_data.capture_times = user_data.capture_times(ind);
    
    % sort ids too
    %tmp = user_data.level0_ids.toArray();
    %user_data.level0_ids_sorted_by_time = tmp(ind);
    
    
    user_data.capture_times_in_matlab_datenum = (user_data.capture_times_in_millis/1000/60/60/24) + datenum(1970,1,1,0,0,0);
    
    
       
    % try determine the number of runs in this data set
    user_data = determine_number_of_runs(user_data, dlg_user_data.cluster_time_slider.getValue(), false); % no plotting
    
    
    
    
    
    dlg_user_data.report = create_report_table(user_data, dlg_user_data.window_h, [0 0 0.5 0.4]);
    
    
    ColorSet = varycolor(length(user_data.run_info.runs));

    hold(dlg_user_data.time_cluster_axes)
    for i=1:length(user_data.run_info.runs)
        
        plot(dlg_user_data.time_cluster_axes, user_data.run_info.matlab_times(i).time, user_data.run_info.runs(i).start:1:user_data.run_info.runs(i).end, '*', 'Color', ColorSet(i,:))
        
    end
    
    hold(dlg_user_data.time_cluster_axes)
    datetick(dlg_user_data.time_cluster_axes,'x','HH:mm')
    xlabel(dlg_user_data.time_cluster_axes,'Time');
    ylabel(dlg_user_data.time_cluster_axes,'Spectra Count');  
    title(dlg_user_data.time_cluster_axes,'Time Clustering');  
    
    ColorSet = varycolor(size(user_data.cal_block_index, 1));

    hold(dlg_user_data.cal_cluster_axes)
    for i=1:size(user_data.cal_block_index, 1)
        plot(dlg_user_data.cal_cluster_axes, user_data.capture_times_in_matlab_datenum(user_data.cal_block_index(i,:)), user_data.cal_ids(user_data.cal_block_index(i,:)), '*', 'Color', ColorSet(i,:))

    end
    hold(dlg_user_data.cal_cluster_axes)
    datetick(dlg_user_data.cal_cluster_axes,'x','HH:mm')
    xlabel(dlg_user_data.cal_cluster_axes,'Time');
    ylabel(dlg_user_data.cal_cluster_axes,'Internal Calibration IDs');   
    title(dlg_user_data.cal_cluster_axes,'Calibration Clustering');  
    
    dlg_user_data.parent_user_data = user_data;

end



function ClusterTimeChange(hObject, EventData)


    fh = ancestor(hObject.hghandle,'figure');% gets the parent figure handle
    
    % get user data
    dlg_user_data = get(fh, 'UserData');
    
    if (~dlg_user_data.cluster_time_slider.getValueIsAdjusting())     
        
        set(dlg_user_data.ClusterTime, 'String', num2str(dlg_user_data.cluster_time_slider.getValue));
        
        dlg_user_data=displayData(dlg_user_data);
        
        % store data in figure    
        set(dlg_user_data.window_h, 'UserData', dlg_user_data);   
        
        
    end
    
end


function Load(hObject, EventData)

    
    % get user data
    fh = ancestor(hObject.hghandle, 'figure');    
    dlg_user_data = get(fh, 'UserData');
    
    LoadDataFromDB(dlg_user_data.parent_user_data);

    
end

