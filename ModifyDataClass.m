classdef ModifyDataClass < handle
    
    properties
        
        parent_user_data;
        window_h;
        raw_A_axes;
        raw_B_axes;
        A_time_axes;
        B_time_axes;
        TGT_axes;
        REF_axes;
        wvl_int_R_axes;
        
        spectral_pos_slider;
        cluster_combo;
        current_cluster_index;
        
        runs; % all runs
        run; % the current run
        
    end
    
    
    methods
        
        
        function this=ModifyDataClass()
        

            
        end
        
        
        function this=startFromSalsaMainWindow(this, parent_user_data)
            
            this.parent_user_data = parent_user_data;
            
            this.runs = parent_user_data.runs;
            
            this.createWindow();
            
        end
        
        
        function this=setRuns(this, runs)
            
            this.runs = runs;
            this.current_cluster_index = 1;
            this.run = this.runs(this.current_cluster_index);
            
        end
        
        
        function this=createWindow(this)
            
            % create new window
            this.window_h = figure('Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'Name', 'SALSA++ - Cluster Based Data Modification', 'Color', [0.9 0.9 0.9]);
            
            set(this.window_h,'Toolbar','figure');
            
            
            % data display axes and panels
            font_size = 13;
            col1_pos = 0.03;
            col2_pos = 0.35;
            axes_width = 0.3;
            axes_height = 0.2;
            row1_pos = 0.9 - axes_height;
            row2_pos = 0.59 - axes_height;
            
            this.raw_A_axes = axes('Parent',this.window_h,'Position',[col1_pos row1_pos axes_width axes_height]);
            this.raw_B_axes = axes('Parent',this.window_h,'Position',[col2_pos row1_pos axes_width axes_height]);
            
            this.A_time_axes = axes('Parent',this.window_h,'Position',[col1_pos row2_pos axes_width axes_height]);
            this.B_time_axes = axes('Parent',this.window_h,'Position',[col2_pos row2_pos axes_width axes_height]);
            
            
            
            tgt_ref_panel = uipanel('BorderType','etchedin','Title','TGT-REF Spectra',...
                'BackgroundColor',[0.9 0.9 0.9],'Units','normalized',...
                'Position',[0 0 0.66 0.35],'Parent',this.window_h);
            
            
            axes_width = 0.44;
            axes_height = 0.8;
            
            this.TGT_axes = axes('Parent',tgt_ref_panel,'Position',[0.05 0.95-axes_height axes_width axes_height]);
            this.REF_axes = axes('Parent',tgt_ref_panel,'Position',[0.54 0.95-axes_height axes_width axes_height]);
            
            hcrf_panel = uipanel('BorderType','etchedin','Title','HCRF Spectra',...
                'BackgroundColor',[0.9 0.9 0.9],'Units','normalized',...
                'Position',[0.68 0 0.32 0.35],'Parent',this.window_h);
            
            axes_width = 0.9;
            this.wvl_int_R_axes = axes('Parent',hcrf_panel,'Position',[0.07 0.95-axes_height axes_width axes_height]);
            
            % buttons
            gbutton=jcontrol(this.window_h, javax.swing.JButton('Refine Panel Spectra'), 'Position', [0.69 0.96 0.1 0.03]);
            set(gbutton, 'MouseClickedCallback', @RefinePanelSpectra);
            
            
            gbutton=jcontrol(this.window_h, javax.swing.JButton('Browse&Flag Spectra'), 'Position', [0.69 0.93 0.1 0.03]);
            set(gbutton, 'MouseClickedCallback', @BrowseAndFlag);
            
            
            
            
            % sliders
            this.spectral_pos_slider = javax.swing.JSlider(javax.swing.SwingConstants.HORIZONTAL, 1, 100, 1);
            %user_data.spectral_pos_slider.setInverted(1);
            slider = jcontrol(this.window_h, this.spectral_pos_slider, 'Position', [col1_pos row1_pos-0.05 0.3 0.02 ]);
            set(slider, 'StateChangedCallback', @this.bandChange);
            
            % cluster combo box
            this.cluster_combo = uicontrol('Style', 'popup',...
                'Units', 'normalized',...
                'FontSize', font_size, ...
                'Position', [0 0.93 0.3 0.06],  'Callback', @this.clusterSelection);
            
            
            for i=1:length(this.runs)
                
                cluster_string{i} = ['Cluster No ' num2str(i)];
            end
            
            set(this.cluster_combo,'String',cluster_string);
            this.current_cluster_index = 1;
            this.run = this.runs(this.current_cluster_index);
            
            this.spectral_pos_slider.setMaximum(length(this.run.raw.a.wvl));
            this.spectral_pos_slider.setValue(40); % set to band 40 for the time line to be meaningful for a start
            
            this.plot_data()
            
            % store data in figure           
            setappdata(this.window_h,'ModifyDataClass',this);                     
            
        end
        
        
        function plot_data(this)
                        
            this.run.plot_raw(this.raw_A_axes, this.raw_B_axes);            
            
            this.plotTimeLines();
            
            this.run.plotTGTs(this.TGT_axes);
            this.run.plotREFs(this.REF_axes);
            
            
            this.run.plotHCRFs(this.wvl_int_R_axes);
                      
        end
        
        
        function plotTimeLines(this)
            
            band = this.spectral_pos_slider.getValue();
            
            this.run.plot_raw_band_versus_time(this.A_time_axes, this.B_time_axes, band, '*');
            hold(this.A_time_axes);
            hold(this.B_time_axes);
            
            this.run.plot_raw_band_versus_time(this.A_time_axes, this.B_time_axes, band, '-', 'b');
            
            hold(this.A_time_axes);
            hold(this.B_time_axes);
            
            datetick(this.A_time_axes, 'x','HH:MM');
            xlabel(this.A_time_axes, 'Time');
            ylabel(this.A_time_axes, 'DN');
            
            datetick(this.B_time_axes, 'x','HH:MM');
            xlabel(this.B_time_axes, 'Time');
            ylabel(this.B_time_axes, 'DN');
            
        end
        
        
        function bandChange(this, hObject, EventData)


            if (~this.spectral_pos_slider.getValueIsAdjusting())        

                this.plotTimeLines();

            end

        end
        
        
        function clusterSelection(this, hObject, EventData)
            
            import ch.specchio.gui.*;
            
            this.current_cluster_index = get(this.cluster_combo,'Value');
            this.run = this.runs(this.current_cluster_index);
            
            
            % clear plots
            cla(this.raw_A_axes)
            cla(this.raw_B_axes)
            cla(this.A_time_axes)
            cla(this.B_time_axes)
            cla(this.TGT_axes)
            cla(this.REF_axes)
            cla(this.wvl_int_R_axes)
            
            
            this.plot_data();
            
            
        end
        
        
        
        
    end
    
    
end