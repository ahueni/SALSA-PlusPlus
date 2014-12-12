function spectra=load_spectra(specchio_client, ids)

    timer = tic();
    
    spaces = specchio_client.getSpaces(ids, 1, 0, 'Acquisition Time');
    
    elapsedTime = toc(timer);
    disp(['getSpaces in ' num2str(elapsedTime) ' secs.'])
    
    timer = tic();
    space = spaces(1);   
    space = specchio_client.loadSpace(space);
    
    elapsedTime = toc(timer);
    disp(['loadSpace in ' num2str(elapsedTime) ' secs.'])   
    
    timer = tic();
    
    spectra.vectors = space.getVectorsAsArray();
    spectra.wvl = space.getAverageWavelengths();
    spectra.unit = 'DN';
    spectra.instrument = space.getInstrument();
    spectra.no_of_bands = length(spectra.wvl);
    
    spectra.ids = space.getSpectrumIds(); % get them sorted by 'Acquisition Time' (sequence as they appear in space)

    [spectra.capture_times, spectra.capture_times_in_millis, spectra.capture_joda_times] = get_acquisition_times(specchio_client, spectra.ids);

    spectra.capture_times_in_matlab_datenum = (spectra.capture_times_in_millis/1000/60/60/24) + datenum(1970,1,1,0,0,0);

    spectra.processing_level = 'RAW'; 
    
    
    IT = specchio_client.getMetaparameterValues(ids, 'Integration Time').toArray();
    
    for i=1:length(IT)      
       spectra.IT(i) =  IT(i); % converts from java object to double
    end
    
    elapsedTime = toc(timer);
    disp(['Metadata et al in ' num2str(elapsedTime) ' secs.'])
    
    
end
