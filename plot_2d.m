function plot_2d(figure_handle, data, title_string, datapoint_index)

    

    if nargin == 3 % create datapoint index selecting all points
        tmp = zeros(data.ids.size(), 1);
        datapoint_index = tmp == 0;               
    end
    
    
    if (sum(datapoint_index) == 0) 
        % avoid trying to plot empty vectors
        % clf(figure_handle);
    else    
         
        if(isempty(data.vectors)) % catch empty vectors
            disp(['No spectral data to display for ' title_string]);
            return;
        end

        plot(figure_handle, data.wvl, data.vectors(datapoint_index,:));
    
    end;
    
    % this are set in any case, even when no data is to be displayed
    title(figure_handle, title_string);
    xlabel(figure_handle, 'wvl [nm]');
    ylabel(figure_handle, data.unit);
        
     

end