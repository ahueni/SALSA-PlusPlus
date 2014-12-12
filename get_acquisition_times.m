function [times, time_in_millis, joda_time] = get_acquisition_times(specchio_client, spectrum_ids)

    joda_time = specchio_client.getMetaparameterValues(spectrum_ids, 'Acquisition Time').toArray();    


    % compile SPECCHIO capture times into a format expected by Matlab
    times = cell(spectrum_ids.size(),1);
    time_in_millis = zeros(spectrum_ids.size(),1);

    for i=1:spectrum_ids.size()
        times{i} = char(ch.specchio.types.MetaDate.formatDate(joda_time(i), 'MMM.dd,yyyy HH:mm:ss'));
        time_in_millis(i) = joda_time(i).getMillis();
        joda_time(i) = joda_time(i);
    end

    
end