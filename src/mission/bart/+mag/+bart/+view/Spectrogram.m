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
                options.?mag.bart.view.Spectrogram
                options.Results (1, 1) mag.bart.Instrument
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            input1 = this.Results.Input1;
            input2 = this.Results.Input2;

            % Spectrogram.
            imput1Spectrum = mag.spectrogram(input1, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

            input2Spectrum = mag.spectrogram(input2, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                Normalize = this.Normalize, Window = this.Window, Overlap = this.Overlap);

            % Field and spectrogram.
            input1Charts = this.getFrequencyCharts(input1, imput1Spectrum, "Input 1", "left");
            input2Charts = this.getFrequencyCharts(input2, input2Spectrum, "Input 2", "right");

            this.Figures = this.Factory.assemble( ...
                input1Charts{:}, ...
                input2Charts{:}, ...
                Title = this.getFrequencyFigureTitle(input1.MetaData, input2.MetaData), ...
                Name = this.getFrequencyFigureName(input1.MetaData, input2.MetaData), ...
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

        function value = getFrequencyFigureTitle(~, input1MetaData, input2MetaData)
            value = compose("Bartington (%d, %d)", input1MetaData.getDisplay("DataFrequency"), input2MetaData.getDisplay("DataFrequency"));
        end

        function value = getFrequencyFigureName(this, input1MetaData, input2MetaData)
            value = this.getFrequencyFigureTitle(input1MetaData, input2MetaData) + compose(" Frequency (%s)", this.date2str(input1MetaData.Timestamp));
        end
    end
end
