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

            [primarySensor, secondarySensor] = this.getSensorNames();

            primary = this.Results.Primary;
            secondary = this.Results.Secondary;

            % Spectrogram.
            primarySpectrum = mag.spectrogram(primary, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

            secondarySpectrum = mag.spectrogram(secondary, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

            % Field and spectrogram.
            primaryCharts = this.getFrequencyCharts(primary, primarySpectrum, primarySensor, "left");
            secondaryCharts = this.getFrequencyCharts(secondary, secondarySpectrum, secondarySensor, "right");

            this.Figures = this.Factory.assemble( ...
                primaryCharts{:}, ...
                secondaryCharts{:}, ...
                Title = this.getFrequencyFigureTitle(primary, secondary), ...
                Name = this.getFrequencyFigureName(primary, secondary), ...
                Arrangement = [9, 2], ...
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

        function value = getFrequencyFigureTitle(~, primary, secondary)
            value = compose("%s (%d, %d)", primary.MetaData.getDisplay("Mode"), primary.MetaData.getDisplay("DataFrequency"), secondary.MetaData.getDisplay("DataFrequency"));
        end

        function value = getFrequencyFigureName(this, primary, secondary)
            value = this.getFrequencyFigureTitle(primary, secondary) + compose(" Frequency (%s)", this.date2str(primary.MetaData.Timestamp));
        end
    end
end
