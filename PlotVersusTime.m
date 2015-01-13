function PlotVersusTime(hObject, EventData)


    fh = ancestor(hObject.hghandle,'figure');% gets the parent figure handle
    
    % get user data
    user_data = get(fh, 'UserData');
    
    if (~user_data.spectral_pos_slider.getValueIsAdjusting())        
    
        band = user_data.spectral_pos_slider.getValue();
        
        cla(user_data.A_time_axes)
        cla(user_data.B_time_axes)
        
        hold(user_data.A_time_axes);
        hold(user_data.B_time_axes);  
        all_data_a = [];
        all_data_b = [];
        all_times = [];
        for i=1:length(user_data.run_info.runs)
            user_data.runs(i).plot_raw_band_versus_time(user_data.A_time_axes, user_data.B_time_axes, band, '*');

            all_data_a = vertcat(all_data_a, user_data.runs(i).raw.a.vectors(:, band));
            all_data_b = vertcat(all_data_b, user_data.runs(i).raw.b.vectors(:, band));

            all_times = vertcat(all_times, user_data.runs(i).raw.a.capture_times_in_matlab_datenum);
        end

        plot(user_data.A_time_axes, all_times, all_data_a);
        plot(user_data.B_time_axes, all_times, all_data_b);
        
        datetick(user_data.A_time_axes, 'x','HH:MM:ss')
        xlabel(user_data.A_time_axes, 'Time');
        ylabel(user_data.A_time_axes, 'DN');
        
        datetick(user_data.B_time_axes, 'x','HH:MM:ss')
        xlabel(user_data.B_time_axes, 'Time');
        ylabel(user_data.B_time_axes, 'DN');        

        hold(user_data.A_time_axes);
        hold(user_data.B_time_axes);  
        
        
%         % check if timeseries already exists: this is for the speed up of
%         % the interface ...
%         if ~isfield(user_data, 'irrad_ts') 
%             % create time series
%             user_data.irrad_ts = timeseries(user_data.raw.a.vectors(:, band), user_data.raw.a.capture_times);
%             user_data.rad_ts = timeseries(user_data.raw.b.vectors(:, band), user_data.raw.b.capture_times);
%             
%             % store data in figure    
%             set(user_data.window_h, 'UserData', user_data);   
%             
%         else
%             
%             user_data.irrad_ts.Data = user_data.raw.a.vectors(:, band);
%             user_data.rad_ts.Data = user_data.raw.b.vectors(:, band);            
%         end
% 
% 
%         set(user_data.window_h,'CurrentAxes',user_data.A_time_axes);
%         plot(user_data.irrad_ts);
%         hold(user_data.A_time_axes)    
%         plot(user_data.irrad_ts, 'og', 'MarkerFaceColor', 'g');
%         hold(user_data.A_time_axes)
%         title(user_data.A_time_axes, ['Sky Irradiance over time @ ' num2str(user_data.raw.a.wvl(band)) 'nm']);
% 
%         set(user_data.window_h,'CurrentAxes',user_data.B_time_axes);
% 
%         plot(user_data.rad_ts);
%         hold(user_data.B_time_axes);
%         plot(user_data.rad_ts, 'og', 'MarkerFaceColor', 'g');
%         hold(user_data.B_time_axes);
%         title(user_data.B_time_axes, ['Ground Radiance over time @ ' num2str(user_data.raw.b.wvl(band)) 'nm']);
% 


    %     plot(user_data.A_time_axes, user_data.raw.a.capture_times, user_data.raw.a.vectors(:, band), 'og');
    %     hold(user_data.A_time_axes)
    %     plot(user_data.A_time_axes, user_data.raw.a.capture_times, user_data.raw.a.vectors(:, band));
    %     hold(user_data.A_time_axes)
    %     
    %     
    %     plot(user_data.B_time_axes, user_data.raw.b.capture_times, user_data.raw.b.vectors(:, band));  
    %     
    %     title(user_data.A_time_axes, ['Sky Irradiance over time @ ' num2str(user_data.raw.a.wvl(band)) 'nm']);
    %     title(user_data.B_time_axes, ['Ground Radiance over time @ ' num2str(user_data.raw.b.wvl(band)) 'nm']);
    
    end

end
