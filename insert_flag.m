function insert_flag(user_data, ids, flag)

    import ch.specchio.types.MetaParameter;

    flag_attribute = user_data.specchio_client.getAttributesNameHash().get(flag);
    e = MetaParameter.newInstance(flag_attribute);
    e.setValue(1);
    
    user_data.specchio_client.updateEavMetadata(e, ids);

end
