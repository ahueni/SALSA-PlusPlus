%%
%   SALSA++
%
%   Interactive software for the processing of Unispec dual channel data to
%   reflectance factors. 
%   Direct connection to the SPECCHIO spectral database V3.1 or higher required.
%   Assumes that a static defintion of the SPECCHIO jar file exists in
%   classpath.txt
%
%   The browse and flag feature still requires a class implemented in the
%   old version of SPECCHIO, therefore also add the V2.2 jar file to the
%   classpath, e.g. /Users/andyhueni/Desktop/SPECCHIO_App_V2.2.0/SPECCHIO_App_V2.2.2_zeta.jar
%
%
%   For more details see also: http://www.geo.uzh.ch/en/units/rsl/news/2013/130218
%
%   (c) 2012-2014 ahueni
%
%

function SalsaPlusPlus()

    import ch.specchio.client.*;
    import ch.specchio.queries.*;
    import ch.specchio.gui.*;

    % create new window
    user_data.window_h = figure('Units', 'normalized', 'Position', [0 0 1 1], 'Name', 'SALSA++ on SPECCHIO V3', 'Color', [0.9 0.9 0.9]);

    set(user_data.window_h,'Toolbar','figure');
    
    % connect to server  
    user_data.cf = SPECCHIOClientFactory.getInstance();
    user_data.db_descriptor_list = user_data.cf.getAllServerDescriptors();    
    user_data.specchio_client = user_data.cf.createClient(user_data.db_descriptor_list.get(0)); % connect to first connection description  

    % get spectral data browser and place in window

    user_data.sdb = SpectralDataBrowser(user_data.specchio_client, true);
    user_data.sdb.build_tree();
    %user_data.qb.sdb.set_view_restriction(1); % restrict view to current user (other data cannot be processed anyway)
    
    user_data.scrollpane=jcontrol(user_data.window_h, 'javax.swing.JScrollPane', 'Position', [0 0.5 0.3 0.45]);
    user_data.scrollpane.setViewportView(user_data.sdb);
    
    set(user_data.sdb.tree, 'MouseClickedCallback', @DataBrowserAction); % there are maybe better options. Ideally, addTreeSelectionListener should be called
    set(user_data.sdb.tree, 'UserData', user_data.window_h); % ensure that we got a link from the event to the figure
    
    
%     user_data.sdb.tree.addTreeSelectionListener(user_data.qb); % this
    %raises the event in the query builder; For some reason it needs
    %redefining here (actually already set in Java ...)
    
    
    font_size = 13;
    
    
    % buttons
    user_data.LoadRawButton=jcontrol(user_data.window_h, javax.swing.JButton('Load & Process'), 'Position', [0.57 0.96 0.1 0.03]);
    set(user_data.LoadRawButton, 'MouseClickedCallback', @LoadingDialog); 
    
    gbutton=jcontrol(user_data.window_h, javax.swing.JButton('Inspect&Modify Data'), 'Position', [0.69 0.96 0.1 0.03]);
    %set(gbutton, 'MouseClickedCallback', @RefinePanelSpectra);  
    set(gbutton, 'MouseClickedCallback', @ModifyData);  
    
    gbutton=jcontrol(user_data.window_h, javax.swing.JButton('Store in DB'), 'Position', [0.57 0.93 0.1 0.03]);
    set(gbutton, 'MouseClickedCallback', @StoreInDB);     
    
    
%     gbutton=jcontrol(user_data.window_h, javax.swing.JButton('Browse&Flag Spectra'), 'Position', [0.69 0.93 0.1 0.03]);
%     set(gbutton, 'MouseClickedCallback', @BrowseAndFlag);     
    
    gbutton=jcontrol(user_data.window_h, javax.swing.JButton('Report'), 'Position', [0.82 0.93 0.1 0.03]);
    set(gbutton, 'MouseClickedCallback', @Report);      


    
        
    
    % menus
    f = uimenu('Label','SALSA++');
    uimenu(f,'Label','Instrument Definition','Callback',@InstrumentDefinition); 
    uimenu(f,'Label','Flag DC Spectra','Callback',@FlagDCSpectra);
    uimenu(f,'Label','Instrument Time Line','Callback',@InstrumentTimeLine);
    uimenu(f,'Label','Time Check','Callback',@TimeCheck);
    %uimenu(f,'Label','Time Clustering','Callback',@TimeClustering);
    uimenu(f,'Label','Browse & Flag All Spectra','Callback',@BrowseAndFlagAllSpectra);
    
    
    
    % data display axes and panels
    col1_pos = 0.35;
    col2_pos = 0.68;
    axes_width = 0.3;
    axes_height = 0.2;
    row1_pos = 0.9 - axes_height;
    row2_pos = 0.59 - axes_height;
    
    user_data.raw_A_axes = axes('Parent',user_data.window_h,'Position',[col1_pos row1_pos axes_width axes_height]);  
    user_data.raw_B_axes = axes('Parent',user_data.window_h,'Position',[col2_pos row1_pos axes_width axes_height]);  
    
    user_data.A_time_axes = axes('Parent',user_data.window_h,'Position',[col1_pos row2_pos axes_width axes_height]);  
    user_data.B_time_axes = axes('Parent',user_data.window_h,'Position',[col2_pos row2_pos axes_width axes_height]);  
    
    
    
    tgt_ref_panel = uipanel('BorderType','etchedin','Title','TGT-REF Spectra',...
		'BackgroundColor',[0.9 0.9 0.9],'Units','normalized',...
		'Position',[0 0 0.66 0.35],'Parent',user_data.window_h);
    
    
    axes_width = 0.44;
    axes_height = 0.8;  
    
    user_data.TGT_axes = axes('Parent',tgt_ref_panel,'Position',[0.05 0.95-axes_height axes_width axes_height]);  
    user_data.REF_axes = axes('Parent',tgt_ref_panel,'Position',[0.54 0.95-axes_height axes_width axes_height]);
    
    hcrf_panel = uipanel('BorderType','etchedin','Title','HCRF Spectra',...
		'BackgroundColor',[0.9 0.9 0.9],'Units','normalized',...
		'Position',[0.68 0 0.32 0.35],'Parent',user_data.window_h);
        
    axes_width = 0.9;
    user_data.wvl_int_R_axes = axes('Parent',hcrf_panel,'Position',[0.07 0.95-axes_height axes_width axes_height]);  
    
    % sliders
    user_data.spectral_pos_slider = javax.swing.JSlider(javax.swing.SwingConstants.HORIZONTAL, 1, 100, 1);
    %user_data.spectral_pos_slider.setInverted(1);
    slider = jcontrol(user_data.window_h, user_data.spectral_pos_slider, 'Position', [col1_pos row1_pos-0.05 0.3 0.02 ]);
    set(slider, 'StateChangedCallback', @PlotVersusTime);
    
    
    
    % combo boxes
    user_data.instrument_combo = uicontrol('Style', 'popup',...
           'Units', 'normalized',...
           'FontSize', font_size, ...
           'Position', [0.15 0.45 0.15 0.04]);        
       
       
    user_data.db_conn_combo = uicontrol('Style', 'popup',...
           'Units', 'normalized',...
           'FontSize', font_size, ...
           'Position', [0 0.93 0.3 0.06],  'Callback', @DBConn);        
       
       
       for i=0:user_data.db_descriptor_list.size()-1
           
           con_string{i+1} = char(user_data.db_descriptor_list.get(i).toString());
       end
       
       set(user_data.db_conn_combo,'String',con_string);
     
    
    % text boxes
    
    no_box_height = 0.02;
    no_box_x_pos = 0.51;
    no_box_y_pos_1 = 0.97;
    no_box_y_pos_2 = no_box_y_pos_1 - no_box_height*1.1;
    no_box_y_pos_3 = no_box_y_pos_2 - no_box_height*1.1;
    txt_y_offset_from_axis = 0.08;
    
    InstrumentCalFactors = uicontrol(user_data.window_h,'Style','text',...
                'String','Wavelength Cal Coeffs:',...
                'Units', 'normalized','FontSize', font_size,...
                'Position',[0 0.465 0.15 no_box_height], 'BackgroundColor', [0.9 0.9 0.9]);   
 
    InstrumentInDBText = uicontrol(user_data.window_h,'Style','text',...
                'String','SPECCHIO Instrument Name:',...
                'Units', 'normalized','FontSize', font_size,...
                'Position',[0 0.43 0.15 no_box_height], 'BackgroundColor', [0.9 0.9 0.9]);   
 
    user_data.InstrumentInDB = uicontrol(user_data.window_h,'Style','text',...
                'String','',...
                'Units', 'normalized','FontSize', font_size,...
                'Position',[0.15 0.43 0.15 no_box_height], 'BackgroundColor', [0.8 0.9 0.9]);              
            
            
    user_data.TotalSpectraText = uicontrol(user_data.window_h,'Style','text',...
                'String','Total # of selected spectra:',...
                'Units', 'normalized','FontSize', font_size,...
                'Position',[0.31 no_box_y_pos_1 0.18 no_box_height], 'BackgroundColor', [0.9 0.9 0.9]);   
    
    
    user_data.TotalSpectra = uicontrol(user_data.window_h,'Style','text',...
            'String','0',...
            'Units', 'normalized','FontSize', font_size,...
            'Position',[no_box_x_pos no_box_y_pos_1 0.05 no_box_height], 'BackgroundColor', [0.8 0.9 0.9]);   
        
        
        
    user_data.RAWSpectraText = uicontrol(user_data.window_h,'Style','text',...
                'String','# of selected RAW spectra:',...
                'Units', 'normalized','FontSize', font_size,...
                'Position',[0.31 no_box_y_pos_2 0.18 no_box_height], 'BackgroundColor', [0.9 0.9 0.9]);   
    
    
    user_data.RAWSpectra = uicontrol(user_data.window_h,'Style','text',...
            'String','0',...
            'Units', 'normalized','FontSize', font_size,...
            'Position',[no_box_x_pos no_box_y_pos_2 0.05 no_box_height], 'BackgroundColor', [0.8 0.9 0.9]);           

    
    user_data.ProcessedSpectraText = uicontrol(user_data.window_h,'Style','text',...
                'String','# of selected processed spectra:',...
                'Units', 'normalized','FontSize', font_size,...
                'Position',[0.31 no_box_y_pos_3 0.2 no_box_height], 'BackgroundColor', [0.9 0.9 0.9]);   
    
    
    user_data.ProcessedSpectra = uicontrol(user_data.window_h,'Style','text',...
            'String','0',...
            'Units', 'normalized','FontSize', font_size,...
            'Position',[no_box_x_pos no_box_y_pos_3 0.05 no_box_height], 'BackgroundColor', [0.8 0.9 0.9]);     
 
        
        
    user_data.Channel_A_content = uicontrol(user_data.window_h,'Style','text',...
            'String','',...
            'Units', 'normalized','FontSize', font_size,...
            'Position',[col1_pos row1_pos-txt_y_offset_from_axis 0.3 no_box_height], 'BackgroundColor', [0.8 0.8 0.8]);     
        
        
    user_data.Channel_B_content = uicontrol(user_data.window_h,'Style','text',...
            'String','',...
            'Units', 'normalized','FontSize', font_size,...
            'Position',[col2_pos row1_pos-txt_y_offset_from_axis 0.3 no_box_height], 'BackgroundColor', [0.8 0.8 0.8]);     
        
   
        
    user_data.current_instrument_index = 1;
    user_data=read_instrument_metadata(user_data);
        

    % store data in figure    
    set(user_data.window_h, 'UserData', user_data);   


end



function DataBrowserAction(hObject, EventData)
    
    window_h = get(hObject, 'UserData');
    user_data = get(window_h, 'UserData');
        
    SelectDataFromDB(user_data);

end






function Report(hObject, EventData)

    import ch.specchio.types.*;
    
    % get user data
    fh = ancestor(hObject.hghandle, 'figure');    
    user_data = get(fh, 'UserData');
    
    % create new window
    window_h = figure('Units', 'normalized', 'Position', [0 0 0.4 0.4], 'Name', 'SALSA++ Report', 'Color', [0.9 0.9 0.9]);
       

    create_report_table(user_data, window_h, [0 0 0.5 0.5]);
    
    
    
end






function DBConn(hObject, EventData)

    import ch.specchio.gui.*;

    
    % get user data
    fh = ancestor(hObject, 'figure');    
    user_data = get(fh, 'UserData');
    
    index = get(hObject,'Value');
    
    user_data.specchio_client = user_data.cf.createClient(user_data.db_descriptor_list.get(index-1));   
    
    %user_data.scrollpane.removeAll();
    
    user_data.sdb = SpectralDataBrowser(user_data.specchio_client, true);
    user_data.sdb.build_tree();
    %user_data.qb.sdb.set_view_restriction(1); % restrict view to current user (other data cannot be processed anyway)
    
    user_data.scrollpane.setViewportView(user_data.sdb);
    
    set(user_data.sdb.tree, 'MouseClickedCallback', @DataBrowserAction); % there are maybe better options. Ideally, addTreeSelectionListener should be called
    set(user_data.sdb.tree, 'UserData', user_data.window_h); % ensure that we got a link from the event to the figure
    
    
    % show connection panel
%     d = ch.specchio.gui.DatabaseConnectionDialog();
%     d.setVisible(true);
%     
%     
%     specchio = ch.specchio.gui.SPECCHIOApplication.getInstance();
%     
%     client=specchio.getClient()
%     
%     client.getServerDescriptor()
%     
%     user_data.specchio_client.getServerDescriptor()

    % store data in figure
    set(user_data.window_h, 'UserData', user_data);

    
end













function subset = get_subset_data_structure(data, index)

    % compile new spectrum id lists based on the clustering result
    class_1_list = java.util.ArrayList();
    
    for i=1:length(index)
        
        if index(i) == 1
            class_1_list.add(java.lang.Integer(data.ids.get(i-1)));                       
        end
                
    end
    
    
    subset.vectors = (data.vectors(index == 1, :));
    
    subset.ids = class_1_list;
    
    subset.wvl = data.wvl;
    
    subset.unit = data.unit;
    



end


function DC_spectra_index = get_dc_index(spectra, threshold)

    % standard deviations per spectrum
    stdevs = zeros(size(spectra,1),1);
    for i=1:size(spectra,1)
        
        stdevs(i) = std(spectra(i,:));
        
    end
    
    DC_spectra_index = stdevs < 100;

end










function user_data=read_instrument_metadata(user_data)

    tmp = load('SalsaInstrumentCoefficients.mat');
    user_data.Instruments = tmp.Instruments;
    
    
    user_data=build_instr_combo_content(user_data);

end




function InstrumentDefinition(hObject, EventData)

    h = defineInstrumentCoefficients();
    
    uiwait(h);
    
    % update the drop down instrument combo with new instrument settings
    fh = ancestor(hObject, 'figure');   
    user_data = get(fh, 'UserData');
    
    user_data=read_instrument_metadata(user_data);
    
    % store data in figure    
    set(user_data.window_h, 'UserData', user_data);    
       
end

% function TimeClustering(hObject, EventData)
% 
%     % get user data
%     fh = ancestor(hObject, 'figure');   
%     user_data = get(fh, 'UserData');
%     
%     determine_number_of_runs(user_data, true);
% 
% end

function ModifyData(hObject, EventData)


    % get user data
    fh = ancestor(hObject.hghandle, 'figure');    
    user_data = get(fh, 'UserData');
    
    
    md=ModifyDataClass();
    md.startFromSalsaMainWindow(user_data);

    
end


function BrowseAndFlagAllSpectra(hObject, EventData)


    % get user data
    fh = ancestor(hObject, 'figure');    
    user_data = get(fh, 'UserData');
    
    msgbox_h = msgbox('Loading data from DB');
    ColorSet = varycolor(1);
    runs(1) = UniSpecDC_DataClass(user_data.specchio_client, user_data.all_level0_ids, ColorSet(1,:));
    runs(1).load_from_db();
    
    md=ModifyDataClass();
    md.setRuns(runs);
    md.parent_user_data = user_data;
    
    close(msgbox_h);
    
    setappdata(fh,'ModifyDataClass',md);
    
    o.hghandle = fh;
    
    BrowseAndFlag(o,0);

end



