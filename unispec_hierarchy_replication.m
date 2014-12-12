function unispec_hierarchy_replication()


    top_dir = '/Volumes/SPECCHIO/SkyOaks_1-3_MyBookBlack';


    rep_top_dir = '/Volumes/SPECCHIO/SkyOaks_1-3_MyBookBlack_UniSpec';
    
    %top_dir = '/Volumes/SPECCHIO/SkyOaks_1-3_MyBookBlack/sky_oaks#1/001021/DC data';
    

    replicate(top_dir, rep_top_dir);


end




function replicate(source_dir, dest_dir)

    disp(source_dir);

    % get all directories
    d = dir(source_dir);
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';

    nameFolds(ismember(nameFolds,{'.','..'})) = [];


    for i=1:length(nameFolds)
        
        replicate([source_dir '/' nameFolds{i}], [dest_dir '/' nameFolds{i}]);
        
    end
    
    
    
    % check if there are SPU, spu or SPT, spt files
    
    
    f = [dir([source_dir '/*.SPU']) ; dir([source_dir '/*.spu']) ; dir([source_dir '/*.SPT']) ; dir([source_dir '/*.spt'])];
    
    if ~isempty(f)
        
       % replicate folder
       mkdir(dest_dir);
       
       for i=1:length(f)
           
           copyfile([source_dir '/' f(i).name], [dest_dir '/' f(i).name]);
        
       end
        
    end


end