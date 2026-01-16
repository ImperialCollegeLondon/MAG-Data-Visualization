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
                results (1, 1) mag.vigil.Instrument
                options.?mag.vigil.view.Spectrogram
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            fob = this.Results.FOB;
            fib = this.Results.FIB;

            [numSpectrogram, spectrogramData] = this.getSpectrogramData(fob, fib);

            if isempty(spectrogramData)
                return;
            end

            this.Figures = this.Factory.assemble( ...
                spectrogramData{:}, ...
                Title = this.getFrequencyFigureTitle(fob, fib), ...
                Name = this.getFrequencyFigureName(fob, fib), ...
                Arrangement = [9, numSpectrogram], ...
                LinkXAxes = true, ...
                TileIndexing = "columnmajor", ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function [numSpectrogram, spectrogramData] = getSpectrogramData(this, fob, fib)

            numSpectrogram = 0;
            spectrogramData = {};

            if ~isempty(fob) && fob.HasData

                fobSpectrum = mag.spectrogram(fob, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                    Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

                numSpectrogram = numSpectrogram + 1;
                spectrogramData = [spectrogramData, this.getFrequencyCharts(fob, fobSpectrum, "FOB", "left")];
            end

            if ~isempty(fib) && fib.HasData

                fibSpectrum = mag.spectrogram(fib, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                    Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

                numSpectrogram = numSpectrogram + 1;
                spectrogramData = [spectrogramData, this.getFrequencyCharts(fib, fibSpectrum, "FIB", "right")];
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

        function value = getFrequencyFigureTitle(this, fob, fib)

            hasFob = ~isempty(fob) && fob.HasData;
            hasFib = ~isempty(fib) && fib.HasData;

            if hasFob && hasFib
                value = compose("%s (%s, %s)", fob.Metadata.getDisplay("Mode"), this.getDataFrequency(fob.Metadata), this.getDataFrequency(fib.Metadata));
            elseif hasFob
                value = compose("%s (%s)", fob.Metadata.getDisplay("Mode"), this.getDataFrequency(fob.Metadata));
            elseif hasFib
                value = compose("%s (%s)", fib.Metadata.getDisplay("Mode"), this.getDataFrequency(fib.Metadata));
            end
        end

        function value = getFrequencyFigureName(this, fob, fib)

            hasFob = ~isempty(fob) && fob.HasData;
            hasFib = ~isempty(fib) && fib.HasData;

            if hasFob && hasFib
                value = compose("%s (%s, %s) Spectrogram (%s)", fob.Metadata.getDisplay("Mode"), this.getDataFrequency(fob.Metadata), this.getDataFrequency(fib.Metadata), this.date2str(fob.Metadata.Timestamp));
            elseif hasFob
                value = compose("%s (%s) Spectrogram (%s)", fob.Metadata.getDisplay("Mode"), this.getDataFrequency(fob.Metadata), this.date2str(fob.Metadata.Timestamp));
            elseif hasFib
                value = compose("%s (%s) Spectrogram (%s)", fib.Metadata.getDisplay("Mode"), this.getDataFrequency(fib.Metadata), this.date2str(fib.Metadata.Timestamp));
            end
        end
    end
end
