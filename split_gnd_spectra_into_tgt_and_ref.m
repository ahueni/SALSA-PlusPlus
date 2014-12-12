function user_data = split_gnd_spectra_into_tgt_and_ref(user_data)

% PCA approach
%     X_t=user_data.wvl_int.spectra.gnd.vectors';
% 
%     eigv=pcafunc(user_data.wvl_int.spectra.gnd.vectors, 2);
% 
%     for i=1:size(user_data.wvl_int.spectra.gnd.vectors, 1)
% 
%        X_red(i,:) =  eigv' * X_t(:,i);
%         
%     end
%     plot(X_red(:,1), X_red(:,2), 'o'); % plots the clusters

    X_t = user_data.wvl_int.gnd.vectors';
    
    % kmeans classification with 2 clusters
    [L,C] = kmeans(X_t,2);
    
    
    
    % compile new spectrum id lists based on the clustering result
    class_1_list = java.util.ArrayList();
    class_2_list = java.util.ArrayList();
    
    for i=1:length(L)
        
        if L(i) == 1
            class_1_list.add(java.lang.Integer(user_data.wvl_int.gnd.ids.get(i-1)));           
        else
            class_2_list.add(java.lang.Integer(user_data.wvl_int.gnd.ids.get(i-1)));             
        end
                
    end
    
    
    % check what are the references and what the targets, depending on the
    % count per class
    class_1_cnt = sum(L == 1);   
    class_2_cnt = sum(L == 2);    

    
    if class_1_cnt > class_2_cnt
        % class 1 are the targets
        user_data.wvl_int.tgt.vectors = (X_t(:,L == 1))';
        user_data.wvl_int.ref.vectors = (X_t(:,L == 2))';
        user_data.tgt_index = L == 1;
        user_data.ref_index = L == 2; 
        user_data.wvl_int.tgt.ids = class_1_list;
        user_data.wvl_int.ref.ids = class_2_list;                
    else
        % class 2 are the targets
        user_data.wvl_int.tgt.vectors = (X_t(:,L == 2))';
        user_data.wvl_int.ref.vectors = (X_t(:,L == 1))'; 
        user_data.tgt_index = L == 2;
        user_data.ref_index = L == 1; 
        user_data.wvl_int.tgt.ids = class_2_list;
        user_data.wvl_int.ref.ids = class_1_list;                        
    end
    
    user_data.wvl_int.tgt.wvl = user_data.wvl_int.gnd.wvl;
    user_data.wvl_int.ref.wvl = user_data.wvl_int.gnd.wvl;
    
    user_data.wvl_int.tgt.unit = user_data.wvl_int.gnd.unit;
    user_data.wvl_int.ref.unit = user_data.wvl_int.gnd.unit;  
    
    
    % create inital indices for the selected and disabled panel spectra
    tmp = zeros(user_data.wvl_int.ref.ids.size(), 1);
    user_data.wvl_int.ref.selected_index = tmp == 0;
    user_data.wvl_int.ref.disabled_index = ~user_data.wvl_int.ref.selected_index;
    
    % create index for all panel spectra to speed up plotting during panel
    % refinement
    user_data.wvl_int.ref.all_index = user_data.wvl_int.ref.selected_index;       
    
end


