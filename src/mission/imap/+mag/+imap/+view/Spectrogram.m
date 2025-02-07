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
                results (1, 1) mag.imap.Instrument
                options.?mag.imap.view.Spectrogram
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            [primarySensor, secondarySensor] = this.getSensorNames();

            primary = this.Results.Primary;
            secondary = this.Results.Secondary;

            numSpectra = 0;

            % Primary.
            if ~isempty(primary) && primary.HasData

                numSpectra = numSpectra + 1;
                primarySpectrum = mag.spectrogram(primary, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                    Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

                primaryCharts = this.getSpectrogramCharts(primary, primarySpectrum, primarySensor, "left");
            else
                primaryCharts = {};
            end

            % Secondary.
            if ~isempty(secondary) && secondary.HasData

                numSpectra = numSpectra + 1;
                secondarySpectrum = mag.spectrogram(secondary, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                    Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

                secondaryCharts = this.getSpectrogramCharts(secondary, secondarySpectrum, secondarySensor, "right");
            else
                secondaryCharts = {};
            end

            % Plot.
            if isempty(primaryCharts) && isempty(secondaryCharts)
                return;
            end

            this.Figures = this.Factory.assemble( ...
                primaryCharts{:}, ...
                secondaryCharts{:}, ...
                Title = this.getSpectrogramFigureTitle(primary, secondary), ...
                Name = this.getSpectrogramFigureName(primary, secondary), ...
                Arrangement = [9, numSpectra], ...
                LinkXAxes = true, ...
                TileIndexing = "columnmajor", ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function charts = getSpectrogramCharts(this, science, spectrum, name, axisLocation)

            charts = { ...
                science, mag.graphics.style.Default(Title = compose("%s x", name), YLabel = "[nT]", YAxisLocation = axisLocation, Charts = mag.graphics.chart.Plot(YVariables = "X")), ...
                spectrum, mag.graphics.style.Colormap(YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [2, 1], Charts = mag.graphics.chart.Spectrogram(YVariables = "X")), ...
                science, mag.graphics.style.Default(Title = compose("%s y", name), YLabel = "[nT]", YAxisLocation = axisLocation, Charts = mag.graphics.chart.Plot(YVariables = "Y")), ...
                spectrum, mag.graphics.style.Colormap(YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [2, 1], Charts = mag.graphics.chart.Spectrogram(YVariables = "Y")), ...
                science, mag.graphics.style.Default(Title = compose("%s z", name), YLabel = "[nT]", YAxisLocation = axisLocation, Charts = mag.graphics.chart.Plot(YVariables = "Z")), ...
                spectrum, mag.graphics.style.Colormap(YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [2, 1], Charts = mag.graphics.chart.Spectrogram(YVariables = "Z"))};
        end

        function value = getSpectrogramFigureTitle(this, primary, secondary)
            value = compose("%s (%s, %s)", primary.MetaData.getDisplay("Mode"), this.getDataFrequency(primary.MetaData), this.getDataFrequency(secondary.MetaData));
        end

        function value = getSpectrogramFigureName(this, primary, secondary)
            value = this.getSpectrogramFigureTitle(primary, secondary) + compose(" Frequency (%s)", this.date2str(primary.MetaData.Timestamp));
        end
    end
end
