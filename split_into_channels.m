


function channel_info = split_into_channels(user_data)

    groups = user_data.specchio_client.sortByAttributes(user_data.level0_ids, 'Instrument Channel');
    channel_lists = groups.getSpectrum_id_lists();

    if(channel_lists.get(0).get_properties_summary().equals('Instrument Channel:A'))

        channel_info.raw.a.ids = channel_lists.get(0).getSpectrumIds();
        channel_info.raw.b.ids = channel_lists.get(1).getSpectrumIds();

    else

        channel_info.raw.b.ids = channel_lists.get(0).getSpectrumIds();
        channel_info.raw.a.ids = channel_lists.get(1).getSpectrumIds();

    end
    
end

