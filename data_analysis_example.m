function data_analysis_example()

    import eav_db.*
    import specchio.*
   
query = sprintf('SELECT spectrum.spectrum_id FROM spectrum WHERE spectrum_id in (25559, 25560, 25561, 25562, 25563, 25564, 25565, 25566, 25567, 25568, 25569, 25570, 25571, 25572, 25573, 25574, 25575, 25576, 25577, 25578, 25579, 25580, 25581, 25582, 25583, 25584, 25585, 25586, 25587, 25588, 25589, 25590, 25591, 25592, 25593, 25594, 25595, 25596, 25597, 25598, 25599, 25600, 25601, 25602, 25603, 25604, 25605, 25606, 25607, 25608, 25609, 25610, 25611, 25612, 25613, 25614, 25615, 25616, 25617, 25618, 25619, 25620, 25621, 25622, 25623, 25624, 25625, 25626, 25627, 25628, 25629, 25630, 25631, 25632, 25633, 25634, 25635, 25636, 25637, 25638, 25639, 25640, 25641, 25642, 25643, 25644, 25645, 25646, 25647, 25648, 25649, 25650, 25651, 25652, 25653, 25654, 25655, 25656, 25657, 25658, 25659, 25660, 25661, 25662, 25663, 25664, 25665, 25666, 25667, 25668, 25669, 25670, 25671, 25672, 25673, 25674, 25675, 25676, 25677, 25678, 25679, 25680, 25681, 25682, 25683, 25684, 25685, 25686, 25687, 25688, 25689, 25690, 25691, 25692, 25693, 25694, 25695, 25696, 25697, 25698, 25699, 25700, 25701, 25702, 25703, 25704, 25705, 25706, 25707, 25708, 25709, 25710, 25711, 25712, 25713, 25714, 25715, 25716, 25717, 25718, 25719, 25720, 25721, 25722, 25723, 25724, 25725, 25726, 25727)');
query = [query 'order by date'];

%query = sprintf('SELECT spectrum.spectrum_id FROM spectrum, campaign WHERE campaign.name = ''Tram Experiment 2012.8.31'' AND spectrum.date >= 20120831123700 AND spectrum.date <= 20120831124330 AND spectrum.measurement_type_id = ''8'' AND spectrum.campaign_id = campaign.campaign_id');


    qbb=QueryBuilderBaseClass('spectrum');    
    qbb.setSelect_query(query);    
    ids = qbb.get_spectrum_ids();

    %% get spectral data    
    sf = specchio.SpaceFactory.getInstance();   
    spaces=sf. create_spaces(ids)    
    space = spaces.get(0);    
    space.load_data();   
    vectors = space.get_array();   
    wvl = space.get_wvls();

    %% get position
    sms = SpecchioMetadataServices();
    positions = sms.get_measurement_positions(ids);   

    li = positions.listIterator();
    i=1;

    lat = zeros(ids.size(),1);
    lon = zeros(ids.size(),1);

    while (li.hasNext()) % store data in vectors
        pos = li.next();
        lat(i) = pos.latitude.doubleValue();
        lon(i) = pos.longitude.doubleValue();
        i = i + 1;
    end    
    
    %% get time
    times = sms.get_capture_times(ids);
    times_millis =  sms.get_capture_times_in_millis(ids);
    time_li = times.listIterator();
    time_millis_li = times_millis.listIterator();
    i=1;
    capture_times = cell(ids.size(),1);
    capture_times_millis =zeros(ids.size(),1);

    while (time_li.hasNext())
        capture_times{i} = time_li.next();
        capture_times_millis(i) = time_millis_li.next();
        
        i = i + 1;
    end    
    
    
    
    %% calculate NDVI
    red_band = wvl == 680;
    nir_band = wvl == 800;
    
    NDVI = (vectors(:,nir_band) - vectors(:,red_band)) ./ (vectors(:,nir_band) + vectors(:,red_band));
    
    
    %% plot
    
    figure
    plot(wvl, vectors(:,:));
    
    % time series plot
    figure
    NDVI_ts = timeseries(NDVI, capture_times);
    plot(NDVI_ts);
    
    title('NDVI');
    xlabel('time')
    ylabel('NDVI');    
    
%     
%     dim = size(vectors,1);
% 
%     x = 1:dim;
    
    % 3d plot
    
    %ts = timeseries(vectors, capture_times);

    figure
    surfc(wvl, capture_times_millis, vectors);
    zlim([0 1]);
    colormap hsv
    shading interp
    xlabel('wvl [nm]')
    ylabel('time');
    zlabel('Reflectance');
    
    


end