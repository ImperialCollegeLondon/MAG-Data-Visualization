classdef PSD < mag.graphics.view.View
% PSD Show PSD of magnetic field.

    properties
        % START Start date of PSD plot.
        Start (1, 1) datetime = NaT(TimeZone = "UTC")
        % DURATION Duration of PSD plot.
        Duration (1, 1) duration = hours(1)
    end

    methods

        function this = PSD(results, options)

            arguments
                results
                options.?mag.bart.view.PSD
                options.Results (1, 1) mag.bart.Instrument
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            input1 = this.Results.Input1;
            input2 = this.Results.Input2;

            % PSD.
            if ismissing(this.Start) || ~isbetween(this.Start, input1.Time(1), input1.Time(end))
                psdStart = input1.Time(1);
            else
                psdStart = this.Start;
            end

            if (this.Duration > (input1.Time(end) - psdStart))
                psdDuration = input1.Time(end) - psdStart;
            else
                psdDuration = this.Duration;
            end

            psdInput1 = mag.psd(input1, Start = psdStart, Duration = psdDuration);
            psdInput2 = mag.psd(input2, Start = psdStart, Duration = psdDuration);

            yLine = mag.graphics.chart.Line(Axis = "y", Value = 0.01, Style = "--", Label = "10 pT Hz^{-0.5}");

            this.Figures = this.Factory.assemble( ...
                psdInput1, mag.graphics.style.Default(Title = "Input 1 PSD", XLabel = this.FLabel, YLabel = this.PSDLabel, XScale = "log", YScale = "log", Legend = ["x", "y", "z"], Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine]), ...
                psdInput2, mag.graphics.style.Default(Title = "Input 2 PSD", XLabel = this.FLabel, YLabel = this.PSDLabel, XScale = "log", YScale = "log", Legend = ["x", "y", "z"], Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine]), ...
                Title = this.getPSDFigureTitle(input1.MetaData, input2.MetaData, psdStart, psdDuration), ...
                Name = this.getPSDFigureName(input1.MetaData, input2.MetaData, psdStart), ...
                Arrangement = [2, 1], ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function value = getPSDFigureTitle(this, input1MetaData, input2MetaData, psdStart, psdDuration)
            value = compose("Start: %s - Duration: %s - (%d, %d)", this.date2str(psdStart), psdDuration, input1MetaData.getDisplay("DataFrequency"), input2MetaData.getDisplay("DataFrequency"));
        end

        function value = getPSDFigureName(this, input1MetaData, input2MetaData, psdStart)
            value = compose("Bartington (%d, %d) PSD (%s)", input1MetaData.getDisplay("DataFrequency"), input2MetaData.getDisplay("DataFrequency"), this.date2str(psdStart));
        end
    end
end
