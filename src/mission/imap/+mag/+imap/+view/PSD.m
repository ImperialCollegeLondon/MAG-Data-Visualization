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
                results (1, 1) mag.imap.Instrument
                options.?mag.imap.view.PSD
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            [primarySensor, secondarySensor] = this.getSensorNames();

            primary = this.Results.Primary;
            secondary = this.Results.Secondary;

            numPSDs = 0;

            yLine = mag.graphics.chart.Line(Axis = "y", Value = 0.01, Style = "--", Label = "10 pT Hz^{-0.5}");

            % Start and duration.
            if ismissing(this.Start) || ~isbetween(this.Start, primary.Time(1), primary.Time(end))
                psdStart = primary.Time(1);
            else
                psdStart = this.Start;
            end

            if (this.Duration > (primary.Time(end) - psdStart))
                psdDuration = primary.Time(end) - psdStart;
            else
                psdDuration = this.Duration;
            end

            % Primary.
            if ~isempty(primary) && primary.HasData

                numPSDs = numPSDs + 1;

                primaryPSD = mag.psd(primary, Start = psdStart, Duration = psdDuration);
                primaryCharts = this.getPSDCharts(primaryPSD, primarySensor, yLine);
            else
                primaryCharts = {};
            end

            % Secondary.
            if ~isempty(secondary) && secondary.HasData

                numPSDs = numPSDs + 1;

                secondaryPSD = mag.psd(secondary, Start = psdStart, Duration = psdDuration);
                secondaryCharts = this.getPSDCharts(secondaryPSD, secondarySensor, yLine);
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
                Title = this.getPSDFigureTitle(primary, secondary, psdStart, psdDuration), ...
                Name = this.getPSDFigureName(primary, secondary, psdStart), ...
                Arrangement = [numPSDs, 1], ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function charts = getPSDCharts(this, psd, sensor, yLine)

            charts = {psd, ...
                mag.graphics.style.Default(Title = compose("%s PSD", sensor), XLabel = this.FLabel, YLabel = this.PSDLabel, XScale = "log", YScale = "log", Legend = ["x", "y", "z"], ...
                Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine])};
        end

        function value = getPSDFigureTitle(this, primary, secondary, psdStart, psdDuration)
            value = compose("Start: %s - Duration: %s - (%s, %s)", this.date2str(psdStart), psdDuration, this.getDataFrequency(primary.MetaData), this.getDataFrequency(secondary.MetaData));
        end

        function value = getPSDFigureName(this, primary, secondary, psdStart)
            value = compose("%s (%s, %s) PSD (%s)", primary.MetaData.getDisplay("Mode"), this.getDataFrequency(primary.MetaData), this.getDataFrequency(secondary.MetaData), this.date2str(psdStart));
        end
    end
end
