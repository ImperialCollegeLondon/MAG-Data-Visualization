classdef Spectrogram < mag.graphics.view.View
% SPECTROGRAM Show spectrogram of HENON magnetic field.

    properties
        % NORMALIZE Normalize data before computing spectrum to highlight spikes.
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
                results (1, 1) mag.henon.Instrument
                options.?mag.henon.view.Spectrogram
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            outboard = this.Results.Outboard;
            inboard = this.Results.Inboard;

            [numSpectrogram, spectrogramData] = this.getSpectrogramData(outboard, inboard);

            if isempty(spectrogramData)
                return;
            end

            this.Figures = this.Factory.assemble( ...
                spectrogramData{:}, ...
                Title = this.getFrequencyFigureTitle(outboard, inboard), ...
                Name = this.getFrequencyFigureName(outboard, inboard), ...
                Arrangement = [9, numSpectrogram], ...
                LinkXAxes = true, ...
                TileIndexing = "columnmajor", ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function [numSpectrogram, spectrogramData] = getSpectrogramData(this, outboard, inboard)

            numSpectrogram = 0;
            spectrogramData = {};

            if ~isempty(outboard) && outboard.HasData

                outboardSpectrum = mag.spectrogram(outboard, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                    Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

                numSpectrogram = numSpectrogram + 1;
                spectrogramData = [spectrogramData, this.getFrequencyCharts(outboard, outboardSpectrum, "Outboard", "left")];
            end

            if ~isempty(inboard) && inboard.HasData

                inboardSpectrum = mag.spectrogram(inboard, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                    Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

                numSpectrogram = numSpectrogram + 1;
                spectrogramData = [spectrogramData, this.getFrequencyCharts(inboard, inboardSpectrum, "Inboard", "right")];
            end
        end

        function charts = getFrequencyCharts(this, science, spectrum, name, axisLocation)

            charts = { ...
                science, mag.graphics.style.Default(Title = compose("%s x", name), YLabel = "[nT]", YAxisLocation = axisLocation, Charts = mag.graphics.chart.Plot(YVariables = "X")), ...
                spectrum, mag.graphics.style.Colormap(YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [2, 1], Charts = mag.graphics.chart.Spectrogram(YVariables = "X")), ...
                science, mag.graphics.style.Default(Title = compose("%s y", name), YLabel = "[nT]", YAxisLocation = axisLocation, Charts = mag.graphics.chart.Plot(YVariables = "Y")), ...
                spectrum, mag.graphics.style.Colormap(YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [2, 1], Charts = mag.graphics.chart.Spectrogram(YVariables = "Y")), ...
                science, mag.graphics.style.Default(Title = compose("%s z", name), YLabel = "[nT]", YAxisLocation = axisLocation, Charts = mag.graphics.chart.Plot(YVariables = "Z")), ...
                spectrum, mag.graphics.style.Colormap(YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [2, 1], Charts = mag.graphics.chart.Spectrogram(YVariables = "Z"))};
        end

        function value = getFrequencyFigureTitle(this, outboard, inboard)

            hasOutboard = ~isempty(outboard) && outboard.HasData;
            hasInboard = ~isempty(inboard) && inboard.HasData;

            if hasOutboard && hasInboard
                value = compose("%s (%s, %s)", outboard.Metadata.getDisplay("Mode"), this.getDataFrequency(outboard.Metadata), this.getDataFrequency(inboard.Metadata));
            elseif hasOutboard
                value = compose("%s (%s)", outboard.Metadata.getDisplay("Mode"), this.getDataFrequency(outboard.Metadata));
            elseif hasInboard
                value = compose("%s (%s)", inboard.Metadata.getDisplay("Mode"), this.getDataFrequency(inboard.Metadata));
            end
        end

        function value = getFrequencyFigureName(this, outboard, inboard)

            hasOutboard = ~isempty(outboard) && outboard.HasData;
            hasInboard = ~isempty(inboard) && inboard.HasData;

            if hasOutboard && hasInboard
                value = compose("%s (%s, %s) Spectrogram (%s)", outboard.Metadata.getDisplay("Mode"), this.getDataFrequency(outboard.Metadata), this.getDataFrequency(inboard.Metadata), this.date2str(outboard.Metadata.Timestamp));
            elseif hasOutboard
                value = compose("%s (%s) Spectrogram (%s)", outboard.Metadata.getDisplay("Mode"), this.getDataFrequency(outboard.Metadata), this.date2str(outboard.Metadata.Timestamp));
            elseif hasInboard
                value = compose("%s (%s) Spectrogram (%s)", inboard.Metadata.getDisplay("Mode"), this.getDataFrequency(inboard.Metadata), this.date2str(inboard.Metadata.Timestamp));
            end
        end
    end
end
