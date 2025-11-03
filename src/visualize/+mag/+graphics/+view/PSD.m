classdef PSD < mag.graphics.view.View
% PSD Show PSD of magnetic field.

    properties
        % START Start date of PSD plot.
        Start (1, 1) datetime = NaT(TimeZone = "UTC")
        % DURATION Duration of PSD plot.
        Duration (1, 1) duration = hours(1)
        % NOISETHRESHOLD Noise threshold line.
        NoiseThreshold (1, :) mag.graphics.chart.Chart = mag.graphics.chart.Line(Axis = "y", Value = 0.01, Style = "--", Label = "10 pT Hz^{-0.5}")
        % SYNCYAXES Sync y-axes.
        SyncYAxes (1, 1) logical = false
    end

    properties (Hidden)
        % TRANSFORMATION Transformation for calculating PSD.
        Transformation (1, 1) mag.transform.PSD = mag.transform.PSD()
    end

    methods

        function this = PSD(results, options)

            arguments
                results (1, 1) mag.Instrument
                options.?mag.graphics.view.PSD
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            science = this.Results.Science;

            % Reorder science, such that primary is first.
            primary = science.select(Primary = true);

            if ~isempty(primary)

                science(science == primary) = [];
                science = [primary, science];
            end

            numPSDs = 0;
            charts = {};

            % PSDs.
            for s = science

                if ~s.HasData
                    continue;
                end

                if ~isempty(s.Metadata)
                    sensor = s.Metadata.getDisplay("Sensor");
                else
                    sensor = "";
                end

                psd = this.computePSD(s);
                c = this.getPSDCharts(psd, sensor);

                numPSDs = numPSDs + 1;
                charts = [charts, c]; %#ok<AGROW>
            end

            % Plot.
            if isempty(charts)
                return;
            end

            this.Figures = this.Factory.assemble( ...
                charts{:}, ...
                Title = this.getPSDFigureTitle(science), ...
                Name = this.getPSDFigureName(science), ...
                Arrangement = [numPSDs, 1], ...
                LinkYAxes = this.SyncYAxes, ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function psd = computePSD(this, science)

            transformation = this.Transformation;

            if ismissing(this.Start) || ~isbetween(this.Start, science.Time(1), science.Time(end))
                transformation.Start = science.Time(1);
            else
                transformation.Start = this.Start;
            end

            if (this.Duration > (science.Time(end) - transformation.Start))
                transformation.Duration = science.Time(end) - transformation.Start;
            else
                transformation.Duration = this.Duration;
            end

            psd = transformation.apply(science);
        end

        function charts = getPSDCharts(this, psd, sensor)

            charts = {psd, ...
                mag.graphics.style.Default(Title = compose("%s PSD", sensor), XLabel = this.FLabel, YLabel = this.PSDLabel, XScale = "log", YScale = "log", Legend = ["x", "y", "z"], ...
                Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), this.NoiseThreshold])};
        end

        function value = getPSDFigureTitle(this, science)

            dataFrequencies = this.getDataFrequencies(science);
            value = compose("Start: %s - Duration: %s - %s", this.date2str(this.Transformation.Start), this.Transformation.Duration, dataFrequencies);
        end

        function value = getPSDFigureName(this, science)

            metadata = [science.Metadata];
            dataFrequencies = this.getDataFrequencies(science);

            value = compose("%s %s PSD (%s)", metadata.getDisplay("Mode"), dataFrequencies, this.date2str(this.Transformation.Start));
        end

        function dataFrequencies = getDataFrequencies(this, science)

            dataFrequencies = string.empty();

            for s = science

                if ~s.HasData
                    continue;
                elseif isempty(s.Metadata)
                    df = string(missing());
                else
                    df = this.getDataFrequency(s.Metadata);
                end

                dataFrequencies(end + 1) = df; %#ok<AGROW>
            end

            if isscalar(dataFrequencies)
                dataFrequencies = compose("(%s Hz)", dataFrequencies);
            else
                dataFrequencies = compose("(%s)", join(dataFrequencies, ", "));
            end
        end
    end
end
