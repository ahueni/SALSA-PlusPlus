function ids = getArrayList(id_array)

    ids = java.util.ArrayList();
    
    for i=1:length(id_array)
        ids.add(java.lang.Integer(id_array(i)));
    end


end
