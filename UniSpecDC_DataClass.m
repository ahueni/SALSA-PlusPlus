classdef UniSpecDC_DataClass < handle
    
    properties
        
        specchio_client;
        original_spectrum_ids; % level 0 ids as set when initialising this class; allows easy refining of spectra via the flagging tool
        spectrum_ids; % level 0 ids
        resampled_spectrum_ids; % 
        R_spectrum_ids; % 
        unispec_spectral_resampling; % 'OFF' or 'ON'
        raw; % raw data
        wvl_cal; % wavelength calibrated data
        wvl_int; % 1nm interpolated data
        
        ids_per_channel; % spectrum ids per channel
        original_ids_per_channel; % spectrum ids per channel but for the original ids
        
        channel_a_content;
        channel_b_content;
        
        colour; % plotting colour assigned to this instance
        
        wvls_coeffs = []; % wavelength calibration coefficients
        
        tgt_index; % indexing the spectra that are targets
        ref_index; % indexing the spectra that are references
        DC_index; % dark current index per channel (a and b)
        
        DC_stdev_threshold = 10; % used for DC detection at 1ms integration time
        
        run_no; % tram run number
        
    end
    
    
    methods
        
        function this=UniSpecDC_DataClass(specchio_client, spectrum_ids, colour)
            
            this.specchio_client = specchio_client;
            this.spectrum_ids = spectrum_ids; 
            this.original_spectrum_ids = spectrum_ids;
            this.colour = colour;
            
            this.split_into_channels()
            
        end
        
        
        function this=load_from_db(this)
            
            %this.split_into_channels();
            
            
            % get information about spectral resampling from database (only channel B)
            this.resampled_spectrum_ids = this.specchio_client.filterSpectrumIdsByHavingAttributeValue(this.ids_per_channel.b, 'UniSpec Spectral Resampling', 'ON');

            if(this.resampled_spectrum_ids.size() == 0)
                this.unispec_spectral_resampling = 'OFF';
            else
                this.unispec_spectral_resampling = 'ON';
            end

            % load data
            this.raw.a = load_spectra(this.specchio_client, this.ids_per_channel.a);
            this.raw.b = load_spectra(this.specchio_client, this.ids_per_channel.b);    
            
            this.raw.a.channel_name = 'Channel A';
            this.raw.b.channel_name = 'Channel B';
            
            this.assign_sky_or_gnd();
            
            
            % saturation detection (do it before normalisation by IT)
            
            
            % normalise to 1ms integration time
            IT_matrix = repmat(this.raw.a.IT', 1, this.raw.a.no_of_bands);
            
            this.raw.a.vectors = this.raw.a.vectors ./ IT_matrix;
            this.raw.b.vectors = this.raw.b.vectors ./ IT_matrix;
            
        end
        
        
        % this can be a bit slow ..., better option is to use the
        % apply_dataselection_index method if the new data are a subset of
        % the already loaded ones
        function this=reload(this)
            
            
            % carry out database selection again using original ids
            [x, this.spectrum_ids, x] = select_ids_from_db(this.specchio_client, this.original_spectrum_ids);
            
            [this.ids_per_channel.a, this.ids_per_channel.b] = this.splitSpectrumIdsIntoChannels(this.spectrum_ids);
            
            this.load_from_db();
            this.wvlCalibration();
            this.wvlInterpolation();
            this.splitGndSpectraIntoTgtAndRef();            
            this.calcReflectances();
            
        end
        
        
        function this=appply_dataselection_index(this, index)
            
            
            
        end
        
        

        function this=split_into_channels(this)
            
            [this.ids_per_channel.a, this.ids_per_channel.b] = this.splitSpectrumIdsIntoChannels(this.spectrum_ids);
            [this.original_ids_per_channel.a, this.original_ids_per_channel.b] = this.splitSpectrumIdsIntoChannels(this.original_spectrum_ids);
            
        end
        
        
        function [a_ids, b_ids] = splitSpectrumIdsIntoChannels(this, ids)
            
            groups = this.specchio_client.sortByAttributes(ids, 'Instrument Channel');
            channel_lists = groups.getSpectrum_id_lists();
            
            if(channel_lists.get(0).get_properties_summary().equals('Instrument Channel:A'))
                
                a_ids = channel_lists.get(0).getSpectrumIds();
                b_ids = channel_lists.get(1).getSpectrumIds();
                
            else
                
                b_ids = channel_lists.get(0).getSpectrumIds();
                a_ids = channel_lists.get(1).getSpectrumIds();
                
            end      
            
            % attention: the ids are not longer sorted after the
            % sortByAttributes call! Sort them again by doing a select in
            % the DB ... not very clean, but does the trick
            
            a_ids = sort_ids_by_time(this.specchio_client, a_ids);
            b_ids = sort_ids_by_time(this.specchio_client, b_ids);
            
        end
        
        
        function this=identifyDCSpectra(this)

            this.DC_index.a = this.identifyDCSpectraInChannel(this.raw.a);   
            this.DC_index.b = this.identifyDCSpectraInChannel(this.raw.b);    
            
        end
        
        function DC_spectra_index=identifyDCSpectraInChannel(this, channel)
            
            % standard deviations per spectrum
            stdevs = zeros(size(channel.vectors,1),1);
            for i=1:size(channel.vectors,1)

                stdevs(i) = std(channel.vectors(i,:));

            end

            DC_spectra_index = stdevs < this.DC_stdev_threshold;            
            
        end
        
        
        function flatDCSpectra(this)
            
            
            
            
        end
        
        
        function this=setWvlsCoeffs(this, coeffs)
           
            this.wvls_coeffs = coeffs;
            
        end
        
        % wavelength calibration: calibrates channel B if needed. Puts data
        % into next level container      
        function this=wvlCalibration(this)
            
            if (strcmp(this.unispec_spectral_resampling, 'OFF'))
                % need to calibrate the wvl of channel B
                
                bands=1:length(this.raw.b.wvl);
                
                
                b =  this.raw.b; % inital copy
                b.wvl  = bands.^2*this.wvls_coeffs(1) + bands * this.wvls_coeffs(2) + this.wvls_coeffs(3); % replace wvl vector
                
            else
                % already calibrated by UniSpec
                b =  this.raw.b; % just a copy for channel B
            end
            
            
            % put into correct container (sky or ground)
            if (strcmp(this.channel_a_content, 'Sky'))
                this.wvl_cal.sky = this.raw.a; % just a copy for channel A
                this.wvl_cal.gnd = b;
            else
                this.wvl_cal.sky = b;
                this.wvl_cal.gnd = this.raw.a; % just a copy for channel A
            end          

            
        end
        
        
        function this=wvlInterpolation(this)
            
            start_wvl = 305;
            end_wvl = 1105; % some unispec devices put housekeeping data in the last 8 bands of channel B, therefore we cut those, resulting in a max wavelength of 1105nm

            new_wvl =(start_wvl:end_wvl);
            
            % copy data structures, a bit redundant but easier to maintain
            % as it holds metadata like the acquisition timings as well
            this.wvl_int.sky = this.wvl_cal.sky;
            this.wvl_int.gnd = this.wvl_cal.gnd;

            % create empty matrices
            this.wvl_int.sky.vectors = zeros(size(this.wvl_cal.sky.vectors,1), length(new_wvl));
            this.wvl_int.gnd.vectors = zeros(size(this.wvl_cal.gnd.vectors,1), length(new_wvl));

            % interpolate
            for i=1:size(this.wvl_cal.sky.vectors,1)

                this.wvl_int.sky.vectors(i,:) = interp1(this.wvl_cal.sky.wvl, this.wvl_cal.sky.vectors(i,:), new_wvl, 'linear','extrap');
                this.wvl_int.gnd.vectors(i,:) = interp1(this.wvl_cal.gnd.wvl, this.wvl_cal.gnd.vectors(i,:), new_wvl, 'linear','extrap');

            end

            this.wvl_int.sky.wvl = new_wvl;
            this.wvl_int.gnd.wvl = new_wvl;
            
        end
        
        
        
        % adapted from SALSA V3
        % channel A contains sky if values are on average greater than channel B
        function this=assign_sky_or_gnd(this)
            
            decisionIndexRange = 25:200;

            decision_matrix = this.raw.a.vectors(:, decisionIndexRange) > this.raw.b.vectors(:, decisionIndexRange);
            mean_decision = mean(mean(decision_matrix));

            if(mean_decision > 0.5)       
                this.channel_a_content = 'Sky';
                this.channel_b_content = 'Ground';
            else
                this.channel_b_content = 'Sky';
                this.channel_a_content = 'Ground'; 
            end
            
        end
        
        
        function this = splitGndSpectraIntoTgtAndRef(this)

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
            
            
            % irradiance slope normalisation to get the irradiance drift
            % out of the ground data
            
            irrad_norm = true;
            
            if (irrad_norm)
                tgt_irr_norm = this.wvl_int.gnd.vectors ./ this.wvl_int.sky.vectors;
                
                tgt_irr_norm(isinf(tgt_irr_norm)) = 0; % set infinity values to zero (happens when the irradiance channel has zeros, which is actually an error in the data itself)
                tgt_irr_norm(isnan(tgt_irr_norm)) = 0; % same for NaN

    %             figure
    %             plot(this.wvl_int.gnd.capture_times_in_matlab_datenum , this.wvl_int.gnd.vectors(:, 40))
    %             hold
    %             plot(this.wvl_int.gnd.capture_times_in_matlab_datenum , tgt_irr_norm(:, 40), 'r')
    %             plot(this.wvl_int.gnd.capture_times_in_matlab_datenum , this.wvl_int.sky.vectors(:, 40), 'g')

                X_t = tgt_irr_norm';
                
            else

                X_t = this.wvl_int.gnd.vectors'; % without irradiance slope correction
            
            end

            % kmeans classification with 2 clusters
            [L,C] = kmeans(X_t,2);



            % compile new spectrum id lists based on the clustering result
            class_list(1) = java.util.ArrayList();
            class_list(2) = java.util.ArrayList();

            for i=1:length(L)
                class_list(L(i)).add(java.lang.Integer(this.wvl_int.gnd.ids.get(i-1)));
            end


            % check what are the references and what the targets, depending on the
            % count per class
            class_1_cnt = sum(L == 1);   
            class_2_cnt = sum(L == 2);   
            
            if class_1_cnt > class_2_cnt
                % class 1 are the targets
                tgt_class_no = 1;
                ref_class_no = 2;               
            else
                % class 2 are the targets
                tgt_class_no = 2;
                ref_class_no = 1;   
            end
            
            this.tgt_index = L == tgt_class_no;
            this.ref_index = L == ref_class_no;
            
            if (irrad_norm)
                this.wvl_int.tgt.vectors = (this.wvl_int.gnd.vectors(this.tgt_index, :));
                this.wvl_int.ref.vectors = (this.wvl_int.gnd.vectors(this.ref_index, :));                
            else
                this.wvl_int.tgt.vectors = (X_t(:,this.tgt_index))';
                this.wvl_int.ref.vectors = (X_t(:,this.ref_index))';
            end
            
            this.wvl_int.tgt.ids = class_list(tgt_class_no);
            this.wvl_int.ref.ids = class_list(ref_class_no);


            this.wvl_int.tgt.wvl = this.wvl_int.gnd.wvl;
            this.wvl_int.ref.wvl = this.wvl_int.gnd.wvl;

            this.wvl_int.tgt.unit = this.wvl_int.gnd.unit;
            this.wvl_int.ref.unit = this.wvl_int.gnd.unit;  
            
            this.wvl_int.tgt.name = 'Targets';
            this.wvl_int.ref.name = 'Reference Panel';
            
            this.wvl_int.tgt.processing_level = '1nm interp.';
            this.wvl_int.ref.processing_level = '1nm interp.';

            % create inital indices for the selected and disabled panel spectra
            tmp = zeros(this.wvl_int.ref.ids.size(), 1);
            this.wvl_int.ref.selected_index = tmp == 0;
            this.wvl_int.ref.disabled_index = ~this.wvl_int.ref.selected_index;

            % create index for all panel spectra to speed up plotting during panel
            % refinement
            this.wvl_int.ref.all_index = this.wvl_int.ref.selected_index;       

        end    
        
        
        function this=calcReflectances(this)
            
            if this.wvl_int.tgt.ids.size() >= 1 && this.wvl_int.ref.ids.size() >= 1

                % get sky spectra based on the target index / ref index (equivalent to the sky
                % spectrum matching the target or reference respectively)
                sky_tgt = this.wvl_int.sky.vectors(this.tgt_index, :);
                sky_ref = this.wvl_int.sky.vectors(this.ref_index, :);

                % calculate the average of the panel factor, the used entries depend
                % on the selected reference panel settings
                % The panel factors are a cross-calibration between upward and downward looking sensor, calibrating to the white reference panel 
                panel_factors = this.wvl_int.ref.vectors(this.wvl_int.ref.selected_index,:) ./ sky_ref(this.wvl_int.ref.selected_index,:);

                panel_avg = mean(panel_factors, 1);

                % replicate average to allow matrix operations
                panel_avg_matrix = repmat(panel_avg, size(this.wvl_int.tgt.vectors, 1), 1);    

                this.wvl_int.R.vectors = this.wvl_int.tgt.vectors ./ (sky_tgt .* panel_avg_matrix);
                
                
                this.wvl_int.R.ids = this.wvl_int.tgt.ids;

                this.R_spectrum_ids = java.util.ArrayList();

            else
                
                this.wvl_int.R.vectors = [];
                
            end
            
            this.wvl_int.R.name = 'Target Reflectance Factors';
            this.wvl_int.R.processing_level = '1nm interp.';
            this.wvl_int.R.unit = 'HCRF';
            this.wvl_int.R.wvl = this.wvl_int.tgt.wvl;
            
        end
        
        
        function plot_raw(this, axis_h_a, axis_h_b, datapoint_index)
            
            if nargin == 3
               datapoint_index = ones(size(this.raw.a.vectors,1),1) == 1;
            end
            
            this.plot_channel(axis_h_a, this.raw.a, datapoint_index);
            this.plot_channel(axis_h_b, this.raw.b, datapoint_index);

        end
        
        function  plot_channel(this, axis_h, channel, datapoint_index)
            
            plot(axis_h, channel.wvl, channel.vectors(datapoint_index,:), 'Color', this.colour);
            
            title_string = [channel.channel_name '-' channel.processing_level];

            title(axis_h, title_string);
            xlabel(axis_h, 'Wavelength [nm]');
            ylabel(axis_h, channel.unit);                    
        
        
        end   
        
        
        function plot_raw_band_versus_time(this, axis_h_a, axis_h_b, band, linestyle, colour)
            
            if nargin == 5
               
                colour = this.colour;
                
            end
            
            wvl = this.raw.a.wvl(band);
            
            this.plot_band_versus_time(axis_h_a, this.raw.a, band, [this.channel_a_content ' over time @ ' num2str(wvl) 'nm'], linestyle, colour);
            this.plot_band_versus_time(axis_h_b, this.raw.b, band, [this.channel_b_content ' over time @ ' num2str(wvl) 'nm'], linestyle, colour);            
            
        end
        
        
        function  plot_band_versus_time(this, axis_h, channel, band, title_str, linestyle, colour)
            
           
            plot(axis_h, channel.capture_times_in_matlab_datenum, channel.vectors(:, band), linestyle, 'Color', colour);
            
%             datetick('x','HH:mm')
%             xlabel('Time');
%             ylabel('DN');
            title(axis_h, title_str);
        end
        
        
        function plot_marker_on_time_lines(this, axis_h_a, axis_h_b, band, index)
            
            this.plot_marker_on_time_line(axis_h_a, this.raw.a, band, index);
            this.plot_marker_on_time_line(axis_h_b, this.raw.b, band, index);
            
        end
        
        function plot_marker_on_time_line(this, axis_h, channel, band, index)
            hold(axis_h)
            plot(axis_h, channel.capture_times_in_matlab_datenum(index), channel.vectors(index, band), '*r', 'MarkerFaceColor', 'r', 'MarkerSize', 15);
            hold(axis_h)
        end
        
        
        function  plotTGTs(this, axis_h)
           
            plotTGTorREF(this, axis_h, this.wvl_int.tgt);                         
        
        end   
        
        function  plotREFs(this, axis_h)
            
            plotTGTorREF(this, axis_h, this.wvl_int.ref);
        
        end    
        
        function plotTGTorREF(this, axis_h, data)
            
            if ~isempty(data.vectors)
            
                plot(axis_h, data.wvl, data.vectors, 'Color', this.colour);

                title_string = [data.name '-' data.processing_level];

                title(axis_h, title_string);
                xlabel(axis_h, 'Wavelength [nm]');
                ylabel(axis_h, data.unit);                           
            
            end
            
        end
        
        function  plotHCRFs(this, axis_h)
           
            plotTGTorREF(this, axis_h, this.wvl_int.R);                         
        
        end      
        
        
        % uses dynamic structure field names: http://blogs.mathworks.com/loren/2005/12/13/use-dynamic-field-references/
        function plotDCSpectra(this, axis_h, channel)
            
            this.identifyDCSpectra();
                    
            if sum(this.DC_index.(channel)) > 0
                this.plot_channel(axis_h, this.raw.(channel), this.DC_index.(channel));
            end
            

            
        end
        
        
    end
    
        
    methods(Static)
        

    end
    
end