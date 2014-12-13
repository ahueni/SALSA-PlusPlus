function FlagDCSpectra(hObject, EventData)
    
    % get user data
    fh = ancestor(hObject, 'figure');   
    main_user_data = get(fh, 'UserData');
    
    
    % create new window
    window_h = figure('Units', 'normalized', 'Position', [0 0 0.5 0.5], 'Name', 'SALSA++ DC Spectra Flagging', 'Color', [0.9 0.9 0.9]);

    user_data.window_h = window_h;
    
    set(window_h,'Toolbar','figure');
    
    no_of_runs = length(main_user_data.runs);
    
    margin = 0.05;
    plot_height_dist = 0.97 / no_of_runs;
    plot_height = plot_height_dist - margin;
    
    plot_width = 0.3;
    panel_cnt = 1;
    %
    for i=1:no_of_runs
        
        
        ha=subplot(no_of_runs,1,panel_cnt);
        set(ha, 'Position', [0.05, 1-(plot_height_dist*i), plot_width, plot_height])
        
        main_user_data.runs(i).plotDCSpectra(ha,'a');
        
        panel_cnt = panel_cnt + 1;
        
        hb=subplot(no_of_runs,2,panel_cnt);
        set(hb, 'Position', [plot_width+margin, 1-(plot_height_dist*i), plot_width, plot_height])        
    
        main_user_data.runs(i).plotDCSpectra(hb, 'b');
        
        panel_cnt = panel_cnt + 1;
        
        % create check boxes
        user_data.run_checkbox(i) = javax.swing.JCheckBox(num2str(i));
        jcontrol(user_data.window_h, user_data.run_checkbox(i), 'Position', [0.9 (1-(plot_height_dist*i) + plot_height/2) 0.05 0.05]); 

        user_data.run_checkbox(i).setSelected(1);    
        
    
    end
    
    
    gbutton=jcontrol(user_data.window_h, javax.swing.JButton('Flag selected spectra as DC in database'), 'Position', [0.68 0.95 0.3 0.04]);
    set(gbutton, 'MouseClickedCallback', @FlagIdentifiedDCSpectra);   
    
    
    user_data.main_user_data = main_user_data;
    
    % store    
    set(window_h, 'UserData', user_data);      
    

end


function FlagIdentifiedDCSpectra(hObject, EventData)
    
    % get user data
    fh = ancestor(hObject.hghandle, 'figure'); 
    user_data = get(fh, 'UserData');
    
    main_user_data = user_data.main_user_data;
    
    no_of_runs = length(main_user_data.runs);
    
    for n=1:no_of_runs
        if user_data.run_checkbox(n).isSelected()
            
            if main_user_data.runs(n).DC_index.a == main_user_data.runs(n).DC_index.b
            
                a_ids = get_dc_ids(main_user_data.runs(n).ids_per_channel.a, main_user_data.runs(n).DC_index.a);
                b_ids = get_dc_ids(main_user_data.runs(n).ids_per_channel.b, main_user_data.runs(n).DC_index.b);

                a_ids.addAll(b_ids);

                insert_flag(main_user_data, a_ids, 'DC Flag');
                
            else
                
                msgbox(['Dark currents are not detected for both channels at the same position for run ' num2str(n) ' No flagging is applied; please use the Flag&Browse tools to designate dark current files.']);
            
            end
        end
        
    end

    
    % close window
    close(fh);
    
    % initiate reselection data
    SelectDataFromDB(main_user_data);
    

end


function ids=get_dc_ids(input_ids, dc_index)


    id_array = input_ids.toArray();
    id_array = id_array(dc_index);
    
    
    ids = getArrayList(id_array);


end





