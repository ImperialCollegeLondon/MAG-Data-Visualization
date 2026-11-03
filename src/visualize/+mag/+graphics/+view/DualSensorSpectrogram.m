classdef DualSensorSpectrogram < mag.graphics.view.DualSensorView
% DUALSENSORSPECTROGRAM Show spectrogram of magnetic field of instrument
% with outboard and inboard sensors.

    properties
        % NORMALIZE Normalize data before computing spectrum to highlight
        % spikes.
        Normalize (1, 1) logical = true
        % FREQUENCYLIMITS Specifies the frequency band limits.
        FrequencyLimits (1, 2) double = [missing(), missing()]
        % FREQUENCYPOINTS Number of frequency samples.
        FrequencyPoints (1, 1) double = 256
        % WINDOW Length of window.
        Window (1, 1) double = missing()
        % OVERLAP Number of overlapped samples.
        Overlap (1, 1) double = missing()
    end

    methods

        function this = DualSensorSpectrogram(results, options)

            arguments
                results (1, 1) mag.DualSensorInstrument
                options.?mag.graphics.view.DualSensorSpectrogram
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            [science, names, axisLocations] = this.getSensorsWithData();

            if isempty(science)
                return;
            end

            spectrogramData = {};

            for i = 1:numel(science)

                spectrum = mag.spectrogram(science(i), FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                    Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

                spectrogramData = [spectrogramData, this.getSpectrogramCharts(science(i), spectrum, names(i), axisLocations(i))]; %#ok<AGROW>
            end

            this.Figures = this.Factory.assemble( ...
                spectrogramData{:}, ...
                Title = this.getFigureTitle(science), ...
                Name = this.getFigureName(science, "Spectrogram"), ...
                Arrangement = [9, numel(science)], ...
                LinkXAxes = true, ...
                TileIndexing = "columnmajor", ...
                WindowState = "maximized");
        end
    end
end
