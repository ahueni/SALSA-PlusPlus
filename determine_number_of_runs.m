
function user_data = determine_number_of_runs(user_data, time_gap_minutes, do_plot, dlg_user_data)

    % state machine codes
    global ref_panel
    global target
    
    ref_panel = 1;
    target = 2;
    
    

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
    
    
    ref_index = 1;
    
    
    
    
    if dlg_user_data.radiometric_splitting_checkbox.isSelected()
        
        if dlg_user_data.run.ref_index(1) == 1

            state = ref_panel;
            refs(ref_index).start = 1;
            
        else
            
            state = target;
            
        end        
        
    end
    
    
    rad_index = 1;
    rad_index_float = rad_index;
    
    
    for i=2:length(user_data.capture_times_in_millis)
        
        delta = user_data.capture_times_in_millis(i) - user_data.capture_times_in_millis(i-1);
        
        cal_delta = user_data.cal_ids(i) - user_data.cal_ids(i-1);
        
        if dlg_user_data.radiometric_splitting_checkbox.isSelected()
            
            % check for a change from target to panel
%             if dlg_user_data.run.ref_index(i-1) == 0 && dlg_user_data.run.ref_index(i) == 1
%                 
%                 ref_panel_post = true;
%                 ref_panel_pre = false;
%                 target = false;
%                                 
%             end
%             
%             if dlg_user_data.run.ref_index(i-1) == 1 && dlg_user_data.run.ref_index(i) == 0
%                 
%                 %ref_panel_post = false;
%                 ref_panel_pre = true;
%                 target = true;
%                                 
%             end
%             
%             if dlg_user_data.run.ref_index(i-1) == 0 && dlg_user_data.run.ref_index(i) == 0
%             
%                 target = true;
%             
%             end
%             
%             diff = dlg_user_data.run.ref_index(i-1) - dlg_user_data.run.ref_index(i);
%             
%             if dlg_user_data.run.ref_index(i-1) == 1 && dlg_user_data.run.ref_index(i) == 0 && diff == 1 && ref_panel_post == true
%             
%                 ref_panel_pre_target_change = true;
%                 ref_panel_post = false;
%             
%             else
%                 
%                 ref_panel_pre_target_change = false;
%                 
%             end

            
            [state, old_state] = state_machine(state, dlg_user_data.run.ref_index, rad_index);
            
           
            if state == ref_panel && old_state == target
                refs(ref_index).start = i; % first occurence
            end
            
            
            if state == target && old_state == ref_panel
                refs(ref_index).end = i-1; % last occurence
                ref_index = ref_index + 1;
            end
            
            
            
            if (delta > time_gap_millis || cal_delta ~= 0) && state == ref_panel

                runs(run_index).end = i-1;

                times(run_index).time = user_data.capture_times_in_millis(runs(run_index).start:runs(run_index).end);
                matlab_times(run_index).time = user_data.capture_times_in_matlab_datenum(runs(run_index).start:runs(run_index).end);

                run_index = run_index + 1;

                runs(run_index).start = i;
                runs(run_index).cal_id = user_data.cal_ids(i);


            end   
            
            
            if delta > time_gap_millis && state == ref_panel

                tgb_runs(tgb_run_index).end = i-1;

                tgb_times(tgb_run_index).time = user_data.capture_times_in_millis(tgb_runs(tgb_run_index).start:tgb_runs(tgb_run_index).end);
                tgb_matlab_times(tgb_run_index).time = user_data.capture_times_in_matlab_datenum(tgb_runs(tgb_run_index).start:tgb_runs(tgb_run_index).end);

                tgb_run_index = tgb_run_index + 1;

                tgb_runs(tgb_run_index).start = i;
                tgb_runs(tgb_run_index).cal_id = user_data.cal_ids(i);


            end             
            
            
            rad_index_float = rad_index_float + 0.5; % deal with the duplication of time stamps by channels A and B by increasing the index by half the increment
            
            rad_index = floor(rad_index_float);
            
            
        else
        
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
    
    end
    
    % fill last run info as the loop exits before setting them ...
    runs(run_index).end = length(user_data.capture_times_in_millis);
    times(run_index).time = user_data.capture_times_in_millis(runs(run_index).start:runs(run_index).end);
    matlab_times(run_index).time = user_data.capture_times_in_matlab_datenum(runs(run_index).start:runs(run_index).end);
      
    tgb_runs(tgb_run_index).end = length(user_data.capture_times_in_millis);
    tgb_times(tgb_run_index).time = user_data.capture_times_in_millis(runs(tgb_run_index).start:runs(tgb_run_index).end);
    tgb_matlab_times(tgb_run_index).time = user_data.capture_times_in_matlab_datenum(runs(tgb_run_index).start:runs(tgb_run_index).end);
       
    
    % check if there are reference blocks without splits. First and last
    % blocks are OK, all others need splitting, by overlapping starts/ends
    % to the neighbouring targets
    
    missing_breaks = [];
    
    if dlg_user_data.radiometric_splitting_checkbox.isSelected()
        
        missing_break_ind = 1;
    
            % get breaks
        breaks = [runs(:).end];


        for i=2:length(refs)-1
            
            index = refs(i).start <= breaks & refs(i).end >= breaks


            if sum(index) == 0
                
                % missing break
                missing_breaks(missing_break_ind) = round((refs(i).end + refs(i).start) / 2);
                
                missing_break_ind = missing_break_ind + 1;
            end

        end
    
    
    end
    
    
    user_data.run_info.times = times;
    user_data.run_info.matlab_times = matlab_times;
    user_data.run_info.runs = runs;
    user_data.run_info.missing_breaks = missing_breaks;
    user_data.cal_block_index = cal_block_index;
    
    user_data.tgb_run_info.times = tgb_times;
    user_data.tgb_run_info.matlab_times = tgb_matlab_times;
    user_data.tgb_run_info.runs = tgb_runs;    
   
    
        
    
    if do_plot
        
        
        figure
        plot(user_data.capture_times_in_matlab_datenum(1:2:end), dlg_user_data.run.ref_index);
        datetick('x','HH:MM')
        
        
        figure
        x = user_data.capture_times_in_matlab_datenum(1:2:end);
        x = x(2:end);
        y_input = user_data.capture_times_in_millis(1:2:end);
        y = diff(y_input);
        y = y/1000;
        plot(x, y); 
        
        tgts = dlg_user_data.run.ref_index == 0;
        refs = dlg_user_data.run.ref_index == 1;
        
        tgts = tgts(2:end);
        refs = refs(2:end);
        
        hold
        
        plot(x(tgts), y(tgts), 'g*');
        plot(x(refs), y(refs), 'rx');
        
        datetick('x','HH:MM')
        xlabel('Time');
        ylabel('Delta Time between Measurements [s]');
        title('Target and Reference Measurements over Time');
        
        legend('All Measurements Line', 'Targets', 'References');
        
    
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
    
    
    

end





function [state, old_state] = state_machine(old_state, ref_index, i)

    global ref_panel
    global target

    
%     if ref_index(i-1) == 0 && ref_index(i) == 1
% 
%         state = ref_panel;
% 
%     elseif ref_index(i-1) == 0 && ref_index(i) == 0
% 
%         state = target;
% 
%     elseif ref_index(i-1) == 1 && ref_index(i) == 0
% 
%         state = target;
%         
%     elseif ref_index(i-1) == 1 && ref_index(i) == 1
% 
%         state = ref_panel;        
% 
%     end

    if ref_index(i) == 1
        
        state = ref_panel;
        
    else
        
        state = target;
        
    end
    

end




