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

    properties (Hidden)
        % TRANSFORMATION Transformation for calculating spectrogram.
        Transformation (1, 1) mag.transform.Spectrogram = mag.transform.Spectrogram()
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

                primarySpectrum = this.computeSpectrogram(primary);
                primaryCharts = this.getSpectrogramCharts(primary, primarySpectrum, primarySensor, "left");
            else
                primaryCharts = {};
            end

            % Secondary.
            if ~isempty(secondary) && secondary.HasData

                numSpectra = numSpectra + 1;

                secondarySpectrum = this.computeSpectrogram(secondary);
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

        function spectrum = computeSpectrogram(this, science)

            transformation = this.Transformation;

            transformation.FrequencyLimits = this.FrequencyLimits;
            transformation.FrequencyPoints = this.FrequencyPoints;
            transformation.Normalize = this.Normalize;
            transformation.Window = this.Window;
            transformation.Overlap = this.Overlap;

            spectrum = transformation.apply(science);
        end

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
            value = compose("%s (%s, %s)", primary.Metadata.getDisplay("Mode"), this.getDataFrequency(primary.Metadata), this.getDataFrequency(secondary.Metadata));
        end

        function value = getSpectrogramFigureName(this, primary, secondary)
            value = this.getSpectrogramFigureTitle(primary, secondary) + compose(" Spectrogram (%s)", this.date2str(primary.Metadata.Timestamp));
        end
    end
end
