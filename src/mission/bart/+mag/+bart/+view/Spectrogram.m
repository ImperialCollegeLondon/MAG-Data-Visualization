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
                results (1, 1) mag.bart.Instrument
                options.?mag.bart.view.Spectrogram
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            input1 = this.Results.Input1;
            input2 = this.Results.Input2;

            [numSpectrogram, spectrogramData] = this.getSpectrogramData(input1, input2);

            if isempty(spectrogramData)
                return;
            end

            this.Figures = this.Factory.assemble( ...
                spectrogramData{:}, ...
                Title = this.getFrequencyFigureTitle(input1, input2), ...
                Name = this.getFrequencyFigureName(input1, input2), ...
                Arrangement = [9, numSpectrogram], ...
                LinkXAxes = true, ...
                TileIndexing = "columnmajor", ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function [numSpectrogram, spectrogramData] = getSpectrogramData(this, input1, input2)

            numSpectrogram = 0;
            spectrogramData = {};

            if ~isempty(input1) && input1.HasData

                input1Spectrum = mag.spectrogram(input1, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                    Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

                numSpectrogram = numSpectrogram + 1;
                spectrogramData = [spectrogramData, this.getFrequencyCharts(input1, input1Spectrum, "Input 1", "left")];
            end

            if ~isempty(input2) && input2.HasData
    
                input2Spectrum = mag.spectrogram(input2, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                    Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

                numSpectrogram = numSpectrogram + 1;
                spectrogramData = [spectrogramData, this.getFrequencyCharts(input2, input2Spectrum, "Input 2", "right")];
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

        function value = getFrequencyFigureTitle(~, input1, input2)

            if isempty(input1)
                value = compose("Bartington (%s Hz)", this.getDataFrequency(input2.MetaData));
            elseif isempty(input2)
                value = compose("Bartington (%s Hz)", this.getDataFrequency(input1.MetaData));
            else
                value = compose("Bartington (%s, %s)", this.getDataFrequency(input1.MetaData), this.getDataFrequency(input2.MetaData));
            end
        end

        function value = getFrequencyFigureName(this, input1, input2)

            value = this.getFrequencyFigureTitle(input1, input2);

            if isempty(input1)
                value = value + compose(" Frequency (%s)", this.date2str(input2.MetaData.Timestamp));
            else
                value = value + compose(" Frequency (%s)", this.date2str(input1.MetaData.Timestamp));;
            end
        end
    end
end
