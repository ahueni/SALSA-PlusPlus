function [all_level0_ids, level0_ids, level1_ids] = select_ids_from_db(specchio_client, ids)

    import ch.specchio.client.*;
    import ch.specchio.queries.*;


    % Query based on pasted query from SPECCHIO Query builder:
    % >>>>>>>>>>>>>>>>>>>>>>
    query = ch.specchio.queries.Query('spectrum');
    query.setQueryType(Query.SELECT_QUERY);

    query.setOrderBy('Acquisition Time');

    query.addColumn('spectrum_id')

    cond = ch.specchio.queries.QueryConditionObject('spectrum', 'spectrum_id');
    cond.setValue(ids);
    cond.setOperator('in');
    query.add_condition(cond);

    cond = EAVQueryConditionObject('eav', 'spectrum_x_eav', 'Processing Level', 'double_val');
    cond.setValue('0.0');
    cond.setOperator('=');
    query.add_condition(cond);

    all_level0_ids = specchio_client.getSpectrumIdsMatchingQuery(query);

    %<<<<<<<<<<<<<<<<<<<<<<<<<<<

    % remove any garbage objects
    tmp_ids_2 = specchio_client.filterSpectrumIdsByNotHavingAttribute(all_level0_ids, 'Garbage Flag');


    % remove any DC objects
    level0_ids = specchio_client.filterSpectrumIdsByNotHavingAttribute(tmp_ids_2, 'DC Flag');

    % get the Level 1.0 spectra
    % as we still got the condition object, we just replace the value

    cond.setValue('1.0');
    level1_ids = specchio_client.getSpectrumIdsMatchingQuery(query);
        
        
end