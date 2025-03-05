classdef PSD < mag.graphics.view.View
% PSD Show PSD of magnetic field.

    properties
        % START Start date of PSD plot.
        Start (1, 1) datetime = NaT(TimeZone = "UTC")
        % DURATION Duration of PSD plot.
        Duration (1, 1) duration = hours(1)
        % SYNCYAXES Sync y-axes.
        SyncYAxes (1, 1) logical = false
    end

    methods

        function this = PSD(results, options)

            arguments
                results
                options.?mag.hs.view.PSD
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            science = this.Results.Science;

            % PSD.
            if ismissing(this.Start) || ~isbetween(this.Start, science.Time(1), science.Time(end))
                psdStart = science.Time(1);
            else
                psdStart = this.Start;
            end

            if (this.Duration > (science.Time(end) - psdStart))
                psdDuration = science.Time(end) - psdStart;
            else
                psdDuration = this.Duration;
            end

            psd = mag.psd(science, Start = psdStart, Duration = psdDuration);
            yLine = mag.graphics.chart.Line(Axis = "y", Value = 0.01, Style = "--", Label = "10 pT Hz^{-0.5}");

            this.Figures = this.Factory.assemble( ...
                psd, mag.graphics.style.Default(Title = compose("%s PSD", science.Metadata.getDisplay("Sensor")), XLabel = this.FLabel, YLabel = this.PSDLabel, XScale = "log", YScale = "log", Legend = ["x", "y", "z"], Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine]), ...
                Title = this.getPSDFigureTitle(science, psdStart, psdDuration), ...
                Name = this.getPSDFigureName(science, psdStart), ...
                LinkYAxes = this.SyncYAxes, ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function value = getPSDFigureTitle(this, science, psdStart, psdDuration)
            value = compose("Start: %s - Duration: %s - (%s Hz)", this.date2str(psdStart), psdDuration, this.getDataFrequency(science.Metadata));
        end

        function value = getPSDFigureName(this, science, psdStart)
            value = compose("%s (%s Hz) PSD (%s)", science.Metadata.getDisplay("Mode"), this.getDataFrequency(science.Metadata), this.date2str(psdStart));
        end
    end
end
