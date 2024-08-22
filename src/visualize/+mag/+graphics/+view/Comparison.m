classdef Comparison < mag.graphics.view.View
% COMPARISON Show comparison of all science sources.

    methods

        function this = Comparison(results, options)

            arguments
                results
                options.?mag.graphics.view.Comparison
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            [primarySensor, secondarySensor] = this.getSensorNames();
            sid5HK = this.getHKType("SCI");

            if isempty(this.Results.HasData) || (isempty(this.Results.IALiRT) || ~this.Results.IALiRT.HasData) || (isempty(sid5HK) || ~sid5HK.HasData)
                return;
            end

            primaryScience = this.Results.Primary;
            secondaryScience = this.Results.Secondary;

            primaryIALiRT = this.Results.IALiRT.Primary;
            secondaryIALiRT = this.Results.IALiRT.Secondary;

            primaryData = this.combineDataSources(primaryScience, primaryIALiRT, sid5HK, "FOB");
            secondaryData = this.combineDataSources(secondaryScience, secondaryIALiRT, sid5HK, "FIB");

            primaryCharts = this.generateComparisonGraph(primarySensor, "left");
            secondaryCharts = this.generateComparisonGraph(secondarySensor, "right");

            this.Figures = this.Factory.assemble( ...
                primaryData, ...
                primaryCharts, ...
                secondaryData, ...
                secondaryCharts, ...
                Title = "Science Sources Comparison", ...
                Name = "Science - I-AliRT - SID5 Comparison", ...
                GlobalLegend = ["Science", "I-ALiRT", "SID5"], ...
                Arrangement = [3, 2], ...
                TileIndexing = "columnmajor", ...
                LinkXAxes = true, ...
                WindowState = "maximized");
        end
    end

    methods (Static, Access = private)

        function data = combineDataSources(science, iALiRT, sid5, sensor)

            arguments (Input)
                science (1, 1) mag.Science
                iALiRT (1, 1) mag.Science
                sid5 (1, 1) mag.hk.Science
                sensor (1, 1) string {mustBeMember(sensor, ["FOB", "FIB"])}
            end

            arguments (Output)
                data timetable
            end

            science = science.Data(science.Quality.isPlottable(), ["x", "y", "z", "range"]);
            science = renamevars(science, ["x", "y", "z", "range"], ["x", "y", "z", "range"] + "_sci");

            iALiRT = iALiRT.Data(iALiRT.Quality.isPlottable(), ["x", "y", "z", "range"]);
            iALiRT = renamevars(iALiRT, ["x", "y", "z", "range"], ["x", "y", "z", "range"] + "_ialirt");

            sid5 = timetable(sid5.(sensor + "T"), sid5.(sensor + "X"), sid5.(sensor + "Y"), sid5.(sensor + "Z"), sid5.(sensor + "Range"), ...
                VariableNames = ["x", "y", "z", "range"] + "_sid5");

            data = outerjoin(science, iALiRT);
            data = outerjoin(data, sid5);
        end

        function charts = generateComparisonGraph(sensorName, yAxisLocation)

            arguments (Input)
                sensorName (1, 1) string
                yAxisLocation (1, 1) string {mustBeMember(yAxisLocation, ["left", "right"])}
            end

            arguments (Output)
                charts (1, 3) mag.graphics.style.Default
            end

            charts = mag.graphics.style.Axes.empty();

            for a = ["x", "y", "z"]

                charts(end + 1) = mag.graphics.style.Default(YLabel = a + " [nT]", YAxisLocation = yAxisLocation, Charts = [mag.graphics.chart.Plot(YVariables = a + "_sci"), ...
                    mag.graphics.chart.Plot(YVariables = a + "_ialirt", LineStyle = "none", Marker = "o"), ...
                    mag.graphics.chart.Plot(YVariables = a + "_sid5", LineStyle = "none", Marker = "s")]); %#ok<AGROW>
            end

            charts(1).Title = sensorName;
        end
    end
end
