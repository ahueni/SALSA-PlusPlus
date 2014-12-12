function h=defineInstrumentCoefficients()


    % create new window
    user_data.window_h = figure('Units', 'normalized', 'Position', [0 0 0.6 0.5], 'Name', 'SALSA++ : Instrument Wavelengths Cal Coeff Definition', 'Color', [0.9 0.9 0.9]);

    set(user_data.window_h,'Toolbar','figure');

    font_size = 13;


    tmp = load('SalsaInstrumentCoefficients.mat');
    user_data.Instruments = tmp.Instruments;

    user_data.current_instrument_index = 1;


    %% build GUI
    
    col1_pos = 0.55;
    axes_width = 0.3;
    axes_height = 0.35;
    row1_pos = 0.95 - axes_height;
    row2_pos = 0.47 - axes_height;
    
    user_data.channel_a_wvls = axes('Parent',user_data.window_h,'Position',[col1_pos row1_pos axes_width axes_height]);      
    user_data.channel_b_wvls = axes('Parent',user_data.window_h,'Position',[col1_pos row2_pos axes_width axes_height]);      



    % instrument combo box
    user_data.instrument_combo = uicontrol('Style', 'popup',...
        'Units', 'normalized',...
        'FontSize', font_size, ...
        'Position', [0.01 0.95 0.3 0.04], 'Callback', @InstrumentSelection);

    
    
    
    user_data = build_instr_combo_content(user_data);

    
    
    % GUI layout constants
    box_height = 0.06;
    box_width = 0.2;
    box_x_pos(1) = 0.25;
    box_x_pos(2) = 0.5;
    box_y_pos(1) = 0.85;
    
    for i=2:5
        
        box_y_pos(i) = box_y_pos(i-1)  - box_height*2;
        
    end
     
    
    
    % instrument name
    i = 1;
    user_data.instrument_name_text = uicontrol(user_data.window_h,'Style','text',...
                'String','Instrument Name:',...
                'Units', 'normalized','FontSize', font_size,...
                'Position',[0.01 box_y_pos(i) 0.2 box_height], 'BackgroundColor', [0.9 0.9 0.9]);   
    
    
    user_data.instrument_name = uicontrol(user_data.window_h,'Style','edit',...
            'Units', 'normalized','FontSize', font_size,...
            'Position',[box_x_pos(1) box_y_pos(i) box_width box_height], 'BackgroundColor', [0.8 0.9 0.9]);   
     
    set(user_data.instrument_name, 'Callback', @NameNumberChange);  
    
    % instrument serial number (to be matched with the one stored in
    % SPECCHIO)
    
    i = 2;
    user_data.instrument_number_text = uicontrol(user_data.window_h,'Style','text',...
                'String','Instrument Serial Number:',...
                'Units', 'normalized','FontSize', font_size,...
                'Position',[0.01 box_y_pos(i) 0.2 box_height], 'BackgroundColor', [0.9 0.9 0.9]);   
    
    
    user_data.instrument_number = uicontrol(user_data.window_h,'Style','edit',...
            'String','<NIL>',...
            'Units', 'normalized','FontSize', font_size,...
            'Position',[box_x_pos(1) box_y_pos(i) box_width box_height], 'BackgroundColor', [0.8 0.9 0.9]);   
    
    set(user_data.instrument_number, 'Callback', @NameNumberChange);  
    
    
    % coefficient fields for channels A and B
    user_data.coeff_panel_data_a = get_coefficient_panel(user_data.window_h, 0.01, 0.2, 'Channel A Coeffs.');
    
    user_data.coeff_panel_data_b = get_coefficient_panel(user_data.window_h, 0.25, 0.2, 'Channel B Coeffs.');
    

    
    % populate for first instrument
    user_data.current_instrument_index = 1;
    user_data = load_instrument_into_GUI(user_data);
    
    
    
    % buttons
    button_x_pos = 0.03;
    button_y_pos = 0.05;
    gbutton=jcontrol(user_data.window_h, javax.swing.JButton('New'), 'Position', [button_x_pos button_y_pos 0.1 0.06]);
    set(gbutton, 'MouseClickedCallback', @New); 
    
    button_x_pos_2 = 0.14;

    gbutton=jcontrol(user_data.window_h, javax.swing.JButton('Delete current instr.'), 'Position', [button_x_pos_2 button_y_pos 0.2 0.06]);
    set(gbutton, 'MouseClickedCallback', @Delete);   
    
    button_x_pos_3 = 0.35;

    gbutton=jcontrol(user_data.window_h, javax.swing.JButton('Save to File'), 'Position', [button_x_pos_3 button_y_pos 0.1 0.06]);
    set(gbutton, 'MouseClickedCallback', @Save);        

    
    % store data in figure    
    set(user_data.window_h, 'UserData', user_data);       
    
    h = user_data.window_h;

end



function InstrumentSelection(hObject, EventData)

    % get user data
    fh = ancestor(hObject, 'figure');   
    user_data = get(fh, 'UserData');    
    
    
    user_data.current_instrument_index = get(user_data.instrument_combo,'Value');
    
    user_data = load_instrument_into_GUI(user_data);

     % store data in figure    
    set(user_data.window_h, 'UserData', user_data);       
   

end



function user_data = load_instrument_into_GUI(user_data)

    if ~isempty(user_data.Instruments)

        set(user_data.instrument_name, 'String', user_data.Instruments(user_data.current_instrument_index).name);
        set(user_data.instrument_number, 'String', user_data.Instruments(user_data.current_instrument_index).serial_number);
        
        set_instr_coeffs(user_data.coeff_panel_data_a, user_data.Instruments(user_data.current_instrument_index).coeffs_a);
        set_instr_coeffs(user_data.coeff_panel_data_b, user_data.Instruments(user_data.current_instrument_index).coeffs_b);

        plot_current_wvl_cal(user_data);
        
    else
        
        user_data = GUI_init(user_data);
        
        cla(user_data.channel_a_wvls);
        cla(user_data.channel_b_wvls);
    
    end

end


function user_data = GUI_init(user_data)

    set(user_data.instrument_name, 'String','<NIL>');
    set(user_data.instrument_number, 'String','<NIL>');
    
    init_instr_coeffs(user_data.coeff_panel_data_a);
    init_instr_coeffs(user_data.coeff_panel_data_b);

end



function plot_current_wvl_cal(user_data)

    calculate_and_plot_wvl(user_data.channel_a_wvls, user_data.Instruments(user_data.current_instrument_index).coeffs_a, 'Channel A');
    calculate_and_plot_wvl(user_data.channel_b_wvls, user_data.Instruments(user_data.current_instrument_index).coeffs_b, 'Channel B');

end


function calculate_and_plot_wvl(axis_h, coeffs, title_str)

    bands=1:256;

    wvl  = bands.^2*coeffs(1) + bands * coeffs(2) + coeffs(3);
    
    plot(axis_h, bands, wvl);
    xlabel(axis_h, 'band number');
    ylabel(axis_h, 'wvl [nm]');
    title(axis_h, title_str);

end



function coeff_panel_data = get_coefficient_panel(parent, panel_x, panel_y, title_str)

font_size = 13;


    hp = uipanel(parent, 'Title', title_str,'FontSize',12,...
                 'BackgroundColor','white',...
                 'Position',[panel_x panel_y .25 .4]);
             
             
             
    order_strings{1} = 'a*x^2';
    order_strings{2} = 'b*x';
    order_strings{3} = 'c';

    % populate with fields for coefficients          

    % GUI layout constants
    box_height = 0.12;
    box_width = 0.37;
    box_x_pos = 0.55;
    box_y_pos = 0.8;
    
    
    for i=1:3
        
        coeff_panel_data.coeff_text{i} = uicontrol(hp,'Style','text',...
                    'String',['Coeff ' num2str(i) ' (' order_strings{i} '):'],...
                    'Units', 'normalized','FontSize', font_size,...
                    'Position',[0.01 box_y_pos 0.5 box_height], 'BackgroundColor', [0.9 0.9 0.9]);   


        coeff_panel_data.coeff(i) = uicontrol(hp,'Style','edit',...
                'String','0',...
                'Units', 'normalized','FontSize', font_size,...
                'Position',[box_x_pos box_y_pos box_width box_height], 'BackgroundColor', [0.8 0.9 0.9]);   

        
        set(coeff_panel_data.coeff(i), 'Callback', @CoeffChange);  
        
        
        box_y_pos = box_y_pos  - box_height*2;
        
    end
    
end



function CoeffChange(hObject,eventdata)

    % get user data
    fh = ancestor(hObject, 'figure');   
    user_data = get(fh, 'UserData');    
    
    % get(hObject, 'String')
    
    if user_data.current_instrument_index > 0    

        % update the current instrument coeffs
        user_data.Instruments(user_data.current_instrument_index).coeffs_a = get_instr_coeffs_as_vector(user_data.coeff_panel_data_a)
        user_data.Instruments(user_data.current_instrument_index).coeffs_b = get_instr_coeffs_as_vector(user_data.coeff_panel_data_b)

        plot_current_wvl_cal(user_data);

        % store data in figure    
        set(user_data.window_h, 'UserData', user_data);   
    
    end

end



function coeffs = get_instr_coeffs_as_vector(panel)


    coeffs = zeros(3,1);

    for i=1:3
                
        string = get(panel.coeff(i), 'String');
        
        coeffs(i) = str2double(string);
        
    end


end

function set_instr_coeffs(panel, coeffs)


    for i=1:3                
        set(panel.coeff(i), 'String', num2str(coeffs(i)));        
    end


end

function init_instr_coeffs(panel)


    for i=1:3                
        set(panel.coeff(i), 'String', '0');        
    end


end


function NameNumberChange(hObject,eventdata)

    % get user data
    fh = ancestor(hObject, 'figure');   
    user_data = get(fh, 'UserData');    
    

    % get name and number from text fields
    user_data.Instruments(user_data.current_instrument_index).serial_number = str2double(get(user_data.instrument_number, 'String'));
    user_data.Instruments(user_data.current_instrument_index).name = get(user_data.instrument_name, 'String');
    
    % update combo box
    user_data = build_instr_combo_content(user_data);        
    
    % store data in figure
    set(user_data.window_h, 'UserData', user_data);


end

function New(hObject,eventdata)

    % get user data
    fh = ancestor(hObject.hghandle, 'figure');    
    user_data = get(fh, 'UserData');
    
    no_of_instruments = length(user_data.Instruments);
    
    user_data.current_instrument_index = no_of_instruments + 1; % add instrument to end of list
    
    user_data.Instruments(user_data.current_instrument_index).coeffs_a = zeros(3,1);
    user_data.Instruments(user_data.current_instrument_index).coeffs_b = zeros(3,1);
    
    
    user_data.Instruments(user_data.current_instrument_index).serial_number = 0;
    user_data.Instruments(user_data.current_instrument_index).name = 'TBD';
    
    
    load_instrument_into_GUI(user_data);
    
    % update combo box and set it new instrument
    user_data = build_instr_combo_content(user_data);
    set(user_data.instrument_combo,'Value',user_data.current_instrument_index);
    
    % store data in figure
    set(user_data.window_h, 'UserData', user_data);
    

end


function Delete(hObject,eventdata)

    % get user data
    fh = ancestor(hObject.hghandle, 'figure');    
    user_data = get(fh, 'UserData');
    
    user_data.Instruments(user_data.current_instrument_index) = [];
    
    % update combo box
    user_data = build_instr_combo_content(user_data);          
    user_data.current_instrument_index = 1;
    
    user_data = load_instrument_into_GUI(user_data);
     
    % store data in figure
    set(user_data.window_h, 'UserData', user_data);
      
    
end






function Save(hObject,eventdata)

    % get user data
    fh = ancestor(hObject.hghandle, 'figure');    
    user_data = get(fh, 'UserData');
    
    Instruments = user_data.Instruments;
    
    save('SalsaInstrumentCoefficients.mat', 'Instruments');
    
end





