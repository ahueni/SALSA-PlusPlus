classdef CosinePanelXCalFactorsClass < handle
    
    properties
        
        parent_user_data;
        window_h;
        
        factors_axes;
        factors_time_axes;

        
        spectral_pos_slider;
        cluster_combo;
        current_cluster_index;
        
        runs; % all runs
        run; % the current run
        
    end
    
    
    methods
        
        
        function this=CosinePanelXCalFactorsClass(parent_user_data)
        
            this.parent_user_data = parent_user_data;
            
            this.setRuns(parent_user_data.runs);
            
            this.createWindow();            
            
        end
        
        
        
        function this=setRuns(this, runs)
            
            this.runs = runs;
            this.current_cluster_index = 1;
            this.run = this.runs(this.current_cluster_index);
            
        end
        
        
        function this=createWindow(this)
            
            % create new window
            this.window_h = figure('Units', 'normalized', 'Position', [0.1 0.1 0.6 0.4], 'Name', 'SALSA++   Cosine - Panel XCal Factors', 'Color', [0.9 0.9 0.9]);
            
            set(this.window_h,'Toolbar','figure');
            
            
            % data display axes and panels
            font_size = 13;
            col1_pos = 0.03;
            col2_pos = 0.5;
            axes_width = 0.4;
            axes_height = 0.5;
            row1_pos = 0.9 - axes_height;
            row2_pos = 0.59 - axes_height;
            
            this.factors_axes = axes('Parent',this.window_h,'Position',[col1_pos row1_pos axes_width axes_height]);
            this.factors_time_axes = axes('Parent',this.window_h,'Position',[col2_pos row1_pos axes_width axes_height]);
            
                        
            
            
            % sliders
            this.spectral_pos_slider = javax.swing.JSlider(javax.swing.SwingConstants.HORIZONTAL, 1, 100, 1);
            %user_data.spectral_pos_slider.setInverted(1);
            slider = jcontrol(this.window_h, this.spectral_pos_slider, 'Position', [col1_pos row1_pos-0.1 0.3 0.02 ]);
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
            
            this.run.plotCosinePanelXCalFactors(this.factors_axes);
            
            this.plotTimeLines();
                   
        end
        
        
        function plotTimeLines(this)
            
            
            band = this.spectral_pos_slider.getValue();
            
            
            this.run.plotCosinePanelXCalFactors_versus_time(this.factors_time_axes, band, '*', 'g');
            hold(this.factors_time_axes);
            this.run.plotCosinePanelXCalFactors_versus_time(this.factors_time_axes, band, '-', 'b');
            hold(this.factors_time_axes);
            
            datetick(this.factors_time_axes, 'x','HH:MM:ss')
            
            
            
%             this.run.plot_raw_band_versus_time(this.A_time_axes, this.B_time_axes, band, '*');
%             hold(this.A_time_axes);
%             hold(this.B_time_axes);
%             
%             this.run.plot_raw_band_versus_time(this.A_time_axes, this.B_time_axes, band, '-', 'b');
%             
%             hold(this.A_time_axes);
%             hold(this.B_time_axes);
%             
%             datetick(this.A_time_axes, 'x','HH:mm');
%             xlabel(this.A_time_axes, 'Time');
%             ylabel(this.A_time_axes, 'DN');
%             
%             datetick(this.B_time_axes, 'x','HH:mm');
%             xlabel(this.B_time_axes, 'Time');
%             ylabel(this.B_time_axes, 'DN');
            
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
            cla(this.factors_axes)
            cla(this.factors_time_axes)
            
            
            this.plot_data();
            
            
        end
        
        
        
        
    end
    
    
end