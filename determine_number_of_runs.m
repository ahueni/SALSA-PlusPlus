
function user_data = determine_number_of_runs(user_data, time_gap_minutes, do_plot)


   % multiple instruments or calibrations: the calibration id is
    % a further criterion to cluster the data
    
    for i=1:length(user_data.unique_cal_ids)
    
        cal_block_index(i,:) = user_data.cal_ids == user_data.unique_cal_ids(i);
    
    end
    
 


    time_gap_millis = time_gap_minutes * 60 *1000;
    
    run_index = 1;    
    runs(run_index).start = 1;
    runs(run_index).cal_id = user_data.cal_ids(1);
    
    % time_gap_based_runs
    tgb_run_index = 1;    
    tgb_runs(tgb_run_index).start = 1;
    tgb_runs(tgb_run_index).cal_id = user_data.cal_ids(1);    
    
    
    for i=2:length(user_data.capture_times_in_millis)
        
        delta = user_data.capture_times_in_millis(i) - user_data.capture_times_in_millis(i-1);
        
        cal_delta = user_data.cal_ids(i) - user_data.cal_ids(i-1);
        
        if delta > time_gap_millis || cal_delta ~= 0
            
            runs(run_index).end = i-1;
            
            times(run_index).time = user_data.capture_times_in_millis(runs(run_index).start:runs(run_index).end);
            matlab_times(run_index).time = user_data.capture_times_in_matlab_datenum(runs(run_index).start:runs(run_index).end);
            
            run_index = run_index + 1;
            
            runs(run_index).start = i;
            runs(run_index).cal_id = user_data.cal_ids(i);
            
            
            
        end
        
        if delta > time_gap_millis
            
            tgb_runs(tgb_run_index).end = i-1;
            
            tgb_times(tgb_run_index).time = user_data.capture_times_in_millis(tgb_runs(tgb_run_index).start:tgb_runs(tgb_run_index).end);
            tgb_matlab_times(tgb_run_index).time = user_data.capture_times_in_matlab_datenum(tgb_runs(tgb_run_index).start:tgb_runs(tgb_run_index).end);
            
            tgb_run_index = tgb_run_index + 1;
            
            tgb_runs(tgb_run_index).start = i;
            tgb_runs(tgb_run_index).cal_id = user_data.cal_ids(i);
                        
            
        end        
    
    end
    
    % fill last run info as the loop exits before setting them ...
    runs(run_index).end = length(user_data.capture_times_in_millis);
    times(run_index).time = user_data.capture_times_in_millis(runs(run_index).start:runs(run_index).end);
    matlab_times(run_index).time = user_data.capture_times_in_matlab_datenum(runs(run_index).start:runs(run_index).end);
      
    tgb_runs(tgb_run_index).end = length(user_data.capture_times_in_millis);
    tgb_times(tgb_run_index).time = user_data.capture_times_in_millis(runs(tgb_run_index).start:runs(tgb_run_index).end);
    tgb_matlab_times(tgb_run_index).time = user_data.capture_times_in_matlab_datenum(runs(tgb_run_index).start:runs(tgb_run_index).end);
       
    
    
    if do_plot
    
        ColorSet = varycolor(run_index);
%         figure
%         hold
%         for i=1:run_index
% 
%             plot(times(i).time, runs(i).start:1:runs(i).end, 'Color', ColorSet(i,:))
% 
%         end

        band = user_data.spectral_pos_slider.getValue();


        figure
        subplot(2,1,1);
        hold
        for i=1:run_index

            plot(times(i).time, user_data.raw.a.vectors(runs(i).start:runs(i).end, band), '*', 'Color', ColorSet(i,:))

        end
        
        subplot(2,1,2);
        hold
        for i=1:run_index

            plot(times(i).time, user_data.raw.b.vectors(runs(i).start:runs(i).end, band), '*', 'Color', ColorSet(i,:))

        end
    
    end
    
    
    user_data.run_info.times = times;
    user_data.run_info.matlab_times = matlab_times;
    user_data.run_info.runs = runs;
    user_data.cal_block_index = cal_block_index;
    
    user_data.run_info.tgb_times = tgb_times;
    user_data.run_info.tgb_matlab_times = tgb_matlab_times;
    user_data.run_info.tgb_runs = tgb_runs;    
   
    

end