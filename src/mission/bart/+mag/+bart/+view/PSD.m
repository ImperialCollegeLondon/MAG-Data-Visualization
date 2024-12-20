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

            if isempty(input1)

                startTime = input2.Time(1);
                endTime = input2.Time(end);
            else

                startTime = input1.Time(1);
                endTime = input1.Time(end);
            end

            if ismissing(this.Start) || ~isbetween(this.Start, startTime, endTime)
                psdStart = startTime;
            else
                psdStart = this.Start;
            end

            if (this.Duration > (endTime - psdStart))
                psdDuration = startTime - psdStart;
            else
                psdDuration = this.Duration;
            end

            [numPSD, psdData] = this.getPSDData(input1, input2, psdStart, psdDuration);

            if isempty(psdData)
                return;
            end

            this.Figures = this.Factory.assemble( ...
                psdData{:}, ...
                Title = this.getPSDFigureTitle(input1, input2, psdStart, psdDuration), ...
                Name = this.getPSDFigureName(input1, input2, psdStart), ...
                Arrangement = [numPSD, 1], ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function [numPSD, psdData] = getPSDData(this, input1, input2, psdStart, psdDuration)

            numPSD = 0;
            psdData = {};

            yLine = mag.graphics.chart.Line(Axis = "y", Value = 0.01, Style = "--", Label = "10 pT Hz^{-0.5}");

            if ~isempty(input1) && input1.HasData

                psdInput1 = mag.psd(input1, Start = psdStart, Duration = psdDuration);

                numPSD = numPSD + 1;
                psdData = [psdData, {psdInput1, ...
                    mag.graphics.style.Default(Title = "Input 1 PSD", XLabel = this.FLabel, YLabel = this.PSDLabel, XScale = "log", YScale = "log", Legend = ["x", "y", "z"], ...
                    Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine])}];
            end

            if ~isempty(input2) && input2.HasData

                psdInput2 = mag.psd(input2, Start = psdStart, Duration = psdDuration);

                numPSD = numPSD + 1;
                psdData = [psdData, {psdInput2, ...
                    mag.graphics.style.Default(Title = "Input 2 PSD", XLabel = this.FLabel, YLabel = this.PSDLabel, XScale = "log", YScale = "log", Legend = ["x", "y", "z"], ...
                    Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine])}];
            end
        end

        function value = getPSDFigureTitle(this, input1, input2, psdStart, psdDuration)

            if isempty(input1)
                value = compose("Start: %s - Duration: %s - (%d Hz)", this.date2str(psdStart), psdDuration, input2.MetaData.getDisplay("DataFrequency"));
            elseif isempty(input2)
                value = compose("Start: %s - Duration: %s - (%d Hz)", this.date2str(psdStart), psdDuration, input1.MetaData.getDisplay("DataFrequency"));
            else
                value = compose("Start: %s - Duration: %s - (%d, %d)", this.date2str(psdStart), psdDuration, input1.MetaData.getDisplay("DataFrequency"), input2.MetaData.getDisplay("DataFrequency"));
            end
        end

        function value = getPSDFigureName(this, input1, input2, psdStart)

            if isempty(input1)
                value = compose("Bartington (%d Hz) PSD (%s)", input2.MetaData.getDisplay("DataFrequency"), this.date2str(psdStart));
            elseif isempty(input2)
                value = compose("Bartington (%d Hz) PSD (%s)", input1.MetaData.getDisplay("DataFrequency"), this.date2str(psdStart));
            else
                value = compose("Bartington (%d, %d) PSD (%s)", input1.MetaData.getDisplay("DataFrequency"), input2.MetaData.getDisplay("DataFrequency"), this.date2str(psdStart));
            end
        end
    end
end
