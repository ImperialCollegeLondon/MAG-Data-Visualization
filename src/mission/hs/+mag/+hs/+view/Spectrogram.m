classdef Spectrogram < mag.graphics.view.View
% SPECTROGRAM Show spectrogram of magnetic field.

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

        function this = Spectrogram(results, options)

            arguments
                results
                options.?mag.imap.view.Spectrogram
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            science = this.Results.Science;

            % Spectrogram.
            spectrum = mag.spectrogram(science, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

            % Field and spectrogram.
            charts = this.getFrequencyCharts(science, spectrum, science.MetaData.getDisplay("Sensor"), "left");

            this.Figures = this.Factory.assemble( ...
                charts{:}, ...
                Title = this.getFrequencyFigureTitle(science), ...
                Name = this.getFrequencyFigureName(science), ...
                Arrangement = [9, 1], ...
                LinkXAxes = true, ...
                TileIndexing = "columnmajor", ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function charts = getFrequencyCharts(this, science, spectrum, name, axisLocation)

            charts = { ...
                science, mag.graphics.style.Default(Title = compose("%s x", name), YLabel = "[nT]", YAxisLocation = axisLocation, Charts = mag.graphics.chart.Plot(YVariables = "X")), ...
                spectrum, mag.graphics.style.Colormap(YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [2, 1], Charts = mag.graphics.chart.Spectrogram(YVariables = "X")), ...
                science, mag.graphics.style.Default(Title = compose("%s y", name), YLabel = "[nT]", YAxisLocation = axisLocation, Charts = mag.graphics.chart.Plot(YVariables = "Y")), ...
                spectrum, mag.graphics.style.Colormap(YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [2, 1], Charts = mag.graphics.chart.Spectrogram(YVariables = "Y")), ...
                science, mag.graphics.style.Default(Title = compose("%s z", name), YLabel = "[nT]", YAxisLocation = axisLocation, Charts = mag.graphics.chart.Plot(YVariables = "Z")), ...
                spectrum, mag.graphics.style.Colormap(YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [2, 1], Charts = mag.graphics.chart.Spectrogram(YVariables = "Z"))};
        end

        function value = getFrequencyFigureTitle(~, science)
            value = compose("%s (%d)", science.MetaData.getDisplay("Mode"), science.MetaData.getDisplay("DataFrequency"));
        end

        function value = getFrequencyFigureName(this, science)
            value = this.getFrequencyFigureTitle(science) + compose(" Frequency (%s)", this.date2str(science.MetaData.Timestamp));
        end
    end
end
