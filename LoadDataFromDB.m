function LoadDataFromDB(user_data)
    
    msgbox_h = msgbox('Loading data from DB');
    
    if isfield(user_data, 'irrad_ts')     
        user_data = rmfield(user_data, 'irrad_ts');
        user_data = rmfield(user_data, 'rad_ts');
    end
    
    ColorSet = varycolor(length(user_data.run_info.runs));
    ids_as_array = user_data.level0_ids.toArray();
    
    progressbar_h = progressbar( [],0,['Loading ' num2str(length(user_data.run_info.runs)) ' Runs ..']); 
    
    if (isfield(user_data, 'runs'))
        user_data = rmfield(user_data, 'runs'); % clear existing data
    end
    
    % carry out loading on each time cluster
    for i=1:length(user_data.run_info.runs)
        
        
        run_ids = getArrayList(ids_as_array(user_data.run_info.runs(i).start:user_data.run_info.runs(i).end));
    
        user_data.runs(i) = UniSpecDC_DataClass(user_data.specchio_client, run_ids, ColorSet(i,:));
        
        user_data.runs(i).run_no = i;
        
        user_data.runs(i).load_from_db();
        
        user_data.runs(i).setWvlsCoeffs(user_data.Instruments(user_data.current_instrument_index).coeffs_b);
        
        progressbar( progressbar_h,1/length(user_data.run_info.runs) );
    
    end
    
    progressbar( progressbar_h,-1 );
    

    user_data.spectral_pos_slider.setMaximum(length(user_data.runs(1).raw.a.wvl));
    user_data.spectral_pos_slider.setValue(40); % set to band 40 for the time line to be meaningful for a start
    
    
    % store data in figure (for below plot versus time call)   
    set(user_data.window_h, 'UserData', user_data);         
    
    
    % plot raw
    hold(user_data.raw_A_axes);
    hold(user_data.raw_B_axes);
    for i=1:length(user_data.run_info.runs)
        user_data.runs(i).plot_raw(user_data.raw_A_axes, user_data.raw_B_axes);
    end
    hold(user_data.raw_A_axes);
    hold(user_data.raw_B_axes);
    

    
    % plot versus time
    o.hghandle = user_data.window_h;
    PlotVersusTime(o , 0);
    
    
    
    % display content information
    set(user_data.Channel_A_content, 'String', [ 'Assumed content: ' user_data.runs(1).channel_a_content]);
    set(user_data.Channel_B_content, 'String', [ 'Assumed content: ' user_data.runs(1).channel_b_content ' / UniSpec spec.resampl.: ' user_data.runs(1).unispec_spectral_resampling]);
    
    
    % process clusters & plot
    hold(user_data.TGT_axes)
    hold(user_data.REF_axes)
    hold(user_data.wvl_int_R_axes)
    for i=1:length(user_data.run_info.runs)
        
        user_data.runs(i).wvlCalibration();
        user_data.runs(i).wvlInterpolation();
        user_data.runs(i).splitGndSpectraIntoTgtAndRef();
        user_data.runs(i).plotTGTs(user_data.TGT_axes);
        user_data.runs(i).plotREFs(user_data.REF_axes);
        
        user_data.runs(i).calcReflectances();
        user_data.runs(i).plotHCRFs(user_data.wvl_int_R_axes);
        
    end
    hold(user_data.TGT_axes)
    hold(user_data.REF_axes)
    hold(user_data.wvl_int_R_axes) 
    

    
    % store data in figure    
    set(user_data.window_h, 'UserData', user_data);    
    
    close(msgbox_h);


end




