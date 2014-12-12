function RefinePanelSpectra(hObject, EventData)


    % get user data
    fh = ancestor(hObject.hghandle, 'figure');    
    dm_dlg_user_data = get(fh, 'UserData');
    main_user_data = dm_dlg_user_data.parent_user_data;
    
    i = dm_dlg_user_data.current_cluster_index;
    
    % create new window
    user_data.refinepanel_window_h = figure('Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'Name', ['SALSA++ - Reference Panel Spectra Refinement for Cluster ' num2str(i)], 'Color', [0.9 0.9 0.9]);

    set(user_data.refinepanel_window_h,'Toolbar','figure');
        
    
    % data display axes and panels
    col1_pos = 0.1;
    col2_pos = 0.4;
    col3_pos = 0.7;
    axes_width = 0.25;
    axes_height = 0.25;
    row1_pos = 0.9 - axes_height;
    row3_pos = 0.3 - axes_height;
    
    user_data.all_axes = axes('Parent',user_data.refinepanel_window_h,'Position',[col1_pos row1_pos axes_width axes_height]);  
    user_data.selected_axes = axes('Parent',user_data.refinepanel_window_h,'Position',[col2_pos row1_pos axes_width axes_height]);  
    user_data.disabled_axes = axes('Parent',user_data.refinepanel_window_h,'Position',[col3_pos row1_pos axes_width axes_height]); 
    
    user_data.all_pct_axes = axes('Parent',user_data.refinepanel_window_h,'Position',[col1_pos row3_pos axes_width axes_height]);  
    user_data.selected_pct_axes = axes('Parent',user_data.refinepanel_window_h,'Position',[col2_pos row3_pos axes_width axes_height]);  
    user_data.disabled_pct_axes = axes('Parent',user_data.refinepanel_window_h,'Position',[col3_pos row3_pos axes_width axes_height]); 
    
    
    % listboxes
    user_data.all_files_listbox = uicontrol('Style', 'listbox',...
           'Units', 'normalized','FontSize', 12,...
           'Position', [0.15 0.35 0.15 0.25]);    
       
    set(user_data.all_files_listbox, 'Callback', @files_selection); 
    
    user_data.selected_files_listbox = uicontrol('Style', 'listbox',...
           'Units', 'normalized','FontSize', 12,...
           'Position', [0.45 0.35 0.15 0.25]);    
       
    set(user_data.selected_files_listbox, 'Callback', @files_selection);  
    
    user_data.disabled_files_listbox = uicontrol('Style', 'listbox',...
           'Units', 'normalized','FontSize', 12,...
           'Position', [0.75 0.35 0.15 0.25]);    
       
    set(user_data.disabled_files_listbox, 'Callback', @files_selection);      
    
    % buttons
    gbutton=jcontrol(user_data.refinepanel_window_h, javax.swing.JButton('>'), 'Position', [0.65 0.5 0.03 0.03]);
    set(gbutton, 'MouseClickedCallback', @Disable); 
    
    gbutton=jcontrol(user_data.refinepanel_window_h, javax.swing.JButton('<'), 'Position', [0.65 0.45 0.03 0.03]);
    set(gbutton, 'MouseClickedCallback', @Enable); 
    
    
    gbutton=jcontrol(user_data.refinepanel_window_h, javax.swing.JButton('Use these selected Spectra'), 'Position', [0.43 0.95 0.15 0.03]);
    set(gbutton, 'MouseClickedCallback', @UseSelectedSpectra); 
    
    
    

    % inital PCT 
    main_user_data.runs(i).wvl_int.ref.pct12 = PCT(main_user_data.runs(i).wvl_int.ref.vectors);
    main_user_data.runs(i).wvl_int.ref.enabled_pct12 = PCT(main_user_data.runs(i).wvl_int.ref.vectors(main_user_data.runs(i).wvl_int.ref.selected_index, :));
    main_user_data.runs(i).wvl_int.ref.disabled_pct12 = PCT(main_user_data.runs(i).wvl_int.ref.vectors(main_user_data.runs(i).wvl_int.ref.disabled_index, :));
    
    
    
    % get spectrum filenames for all data
    
    filenames = main_user_data.specchio_client.getMetaparameterValues(main_user_data.runs(i).wvl_int.gnd.ids, 'File Name');    
    
    main_user_data.runs(i).wvl_int.ref.filenames_array = generate_string_array(filenames);
    
    set(user_data.all_files_listbox, 'String', main_user_data.runs(i).wvl_int.ref.filenames_array);
    
    update_listboxes(user_data, main_user_data.runs(i))
    
    %legend_string=generate_legend(filenames);

    
    plot_data(user_data, main_user_data.runs(i));


    %legend(user_data.all_axes, legend_string, 'Location','EastOutside');

    
    % store data in parent figure    
    set(user_data.window_h, 'UserData', user_data);   

    
    set(user_data.refinepanel_window_h, 'UserData', user_data.window_h); % store parent figure window handle in the refinepanel_window
    

end


function update_listboxes(user_data, run)

    set(user_data.selected_files_listbox, 'String', {run.wvl_int.ref.filenames_array{run.ref_index}});
    set(user_data.selected_files_listbox, 'Value', 1); % try to ensure a valid selection
    
    set(user_data.disabled_files_listbox, 'String', {run.wvl_int.ref.filenames_array{run.ref_index}});
    set(user_data.disabled_files_listbox, 'Value', 1); % try to ensure a valid selection

end



function plot_data(user_data, run)

    % spectra
    plot_2d(user_data.all_axes, run.wvl_int.ref, 'Reference Panel - All Spectra');

    % PCT
    plot_pct(user_data.all_pct_axes, run.wvl_int.ref.pct12);
    
    
    % spectra
    plot_2d(user_data.selected_axes, run.wvl_int.ref, 'Reference Panel - Selected Spectra', run.wvl_int.ref.selected_index);

    % PCT
    plot_pct(user_data.selected_pct_axes, run.wvl_int.ref.enabled_pct12);    
    
    
    % spectra
    plot_2d(user_data.disabled_axes, run.wvl_int.ref, 'Reference Panel - Disabled Spectra', run.wvl_int.ref.disabled_index);

    % PCT
    plot_pct(user_data.disabled_pct_axes, run.wvl_int.ref.disabled_pct12);    
    


end



function pct12=PCT(input)

    if size(input,1) <= 1     
        pct12 = [];
        return;
    end


    X_t=input';

    eigv=pcafunc(input, 2);
    
    pct12 = zeros(size(input, 1), 2);

    for i=1:size(input, 1)

       pct12(i,:) =  eigv' * X_t(:,i);
        
    end


end


function legend_string_array=generate_string_array(filename_list)

    for i=1:size(filename_list);

        legend_string_array{i} = filename_list.get(i-1);
        
    end


end


function files_selection(hObject, EventData)

    % get user data
    parent_handle = get(ancestor(hObject,'figure'), 'UserData'); 
    
    user_data = get(parent_handle, 'UserData'); 
    
    % define what data to use for displaying (depending on originating
    % listbox)
    
    data = user_data.wvl_int.ref;
    
    if(user_data.all_files_listbox == hObject)
    
        index = user_data.wvl_int.ref.all_index;
        spectrum_axes_handle = user_data.all_axes;
        pct_axes_handle = user_data.all_pct_axes;    
        title_str = 'Reference Panel - All Spectra';
        pct12 = user_data.wvl_int.ref.pct12;
    end
    
    if(user_data.selected_files_listbox == hObject)
    
        index = user_data.wvl_int.ref.selected_index;
        spectrum_axes_handle = user_data.selected_axes;
        pct_axes_handle = user_data.selected_pct_axes;    
        title_str = 'Reference Panel - Selected Spectra';
        pct12 = user_data.wvl_int.ref.enabled_pct12;
    end    
    
    
    if(user_data.disabled_files_listbox == hObject)
    
        index = user_data.wvl_int.ref.disabled_index;
        spectrum_axes_handle = user_data.disabled_axes;
        pct_axes_handle = user_data.disabled_pct_axes;    
        title_str = 'Reference Panel - Disabled Spectra';
        pct12 = user_data.wvl_int.ref.disabled_pct12
    end        
    
    

    
    % spectra
    plot_2d(spectrum_axes_handle, data, title_str, index);

    hold(spectrum_axes_handle);
    
    % highlight the selected spectrum
    ind = get(hObject,'Value');
    
    plot(spectrum_axes_handle, data.wvl, data.vectors(ind, :), 'xr');
    
    hold(spectrum_axes_handle); % release
    
    
    % pct
    if ~isempty(pct12)
        plot_pct(pct_axes_handle, pct12);

        hold(pct_axes_handle);

        plot(pct_axes_handle, pct12(ind, 1), pct12(ind, 2), '*r', 'MarkerSize', 20);

        hold(pct_axes_handle); % release
    end


end




function plot_pct(axes_handle, data)

    if isempty(data)
        % only plot titles, etc
    else
        plot(axes_handle, data(:,1), data(:,2), 'o');        
    end;


    title(axes_handle, 'PCT Components 1&2');
    xlabel(axes_handle, 'PC1');
    ylabel(axes_handle, 'PC2');

end



function Disable(hObject, EventData)

    % get user data
    fh = ancestor(hObject.hghandle, 'figure');    
    parent_h = get(fh, 'UserData');
    user_data = get(parent_h, 'UserData');

    ind = get(user_data.selected_files_listbox,'Value');
    
    % get absolute index of enabled spectra
    abs_ind = find(user_data.wvl_int.ref.selected_index == 1);
    
    % switch this element to zero in the selected and set to 1 in the
    % disabled index
    
    user_data.wvl_int.ref.selected_index(abs_ind(ind)) = 0;
    user_data.wvl_int.ref.disabled_index(abs_ind(ind)) = 1;

    update_listboxes(user_data);
    
    % PCT
    user_data.wvl_int.ref.enabled_pct12 = PCT(user_data.wvl_int.ref.vectors(user_data.wvl_int.ref.selected_index, :));
    user_data.wvl_int.ref.disabled_pct12 = PCT(user_data.wvl_int.ref.vectors(user_data.wvl_int.ref.disabled_index, :));
    
    
    plot_data(user_data);
    
    % store data in figure    
    set(user_data.window_h, 'UserData', user_data);       

end


function Enable(hObject, EventData)

    % get user data
    fh = ancestor(hObject.hghandle, 'figure');    
    parent_h = get(fh, 'UserData');
    user_data = get(parent_h, 'UserData');
    
    ind = get(user_data.disabled_files_listbox,'Value');
    
    % get absolute index of enabled spectra
    abs_ind = find(user_data.wvl_int.ref.disabled_index == 1);
    
    % switch this element to zero in the disabled and set to 1 in the
    % selected index
    
    user_data.wvl_int.ref.selected_index(abs_ind(ind)) = 1;
    user_data.wvl_int.ref.disabled_index(abs_ind(ind)) = 0;

    update_listboxes(user_data);
    
    % PCT
    user_data.wvl_int.ref.enabled_pct12 = PCT(user_data.wvl_int.ref.vectors(user_data.wvl_int.ref.selected_index, :));
    user_data.wvl_int.ref.disabled_pct12 = PCT(user_data.wvl_int.ref.vectors(user_data.wvl_int.ref.disabled_index, :));
    
    
    plot_data(user_data);
    
    % store data in figure    
    set(user_data.window_h, 'UserData', user_data);           
    
end


function UseSelectedSpectra(hObject, EventData)

    % get user data
    fh = ancestor(hObject.hghandle, 'figure');    
    parent_h = get(fh, 'UserData');
    user_data = get(parent_h, 'UserData');
    
    user_data = calc_reflectances(user_data);
    
    % plot selected targets
    plot_2d(user_data.REF_axes,  user_data.wvl_int.ref, 'Reference Panel - 1nm interp.', user_data.wvl_int.ref.selected_index);

    % plot reflectances
    plot_2d(user_data.wvl_int_R_axes,  user_data.wvl_int.spectra.R, 'Target Reflectances - 1nm interp.');
    ylim(user_data.wvl_int_R_axes, [0 1]);
    
    % store data in figure    
    set(user_data.window_h, 'UserData', user_data);        


end






