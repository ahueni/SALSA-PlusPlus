function sorted_ids = sort_ids_by_time(specchio_client, ids)


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


    sorted_ids = specchio_client.getSpectrumIdsMatchingQuery(query);    



end