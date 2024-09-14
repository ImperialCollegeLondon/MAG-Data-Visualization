classdef Comparison < mag.graphics.view.View
% COMPARISON Show comparison of all science sources.

    methods

        function this = Comparison(results, options)

            arguments
                results
                options.?mag.imap.view.Comparison
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            [primarySensor, secondarySensor] = this.getSensorNames();
            sid5HK = this.getHKType("SCI");

            primaryScience = this.Results.Primary;
            secondaryScience = this.Results.Secondary;

            hasScience = ~isempty(this.Results.HasData);
            hasIALiRT = ~isempty(this.Results.IALiRT) && this.Results.IALiRT.HasData;
            hasSID5 = ~isempty(sid5HK) && sid5HK.HasData;

            if hasScience && hasIALiRT && hasSID5

                primaryIALiRT = this.Results.IALiRT.Primary;
                secondaryIALiRT = this.Results.IALiRT.Secondary;

                primaryData = this.combineDataSources(primaryScience, primaryIALiRT, sid5HK, "FOB");
                secondaryData = this.combineDataSources(secondaryScience, secondaryIALiRT, sid5HK, "FIB");

                primaryCharts = this.generateOverlayGraph(primarySensor, "left");
                secondaryCharts = this.generateOverlayGraph(secondarySensor, "right");

                this.Figures(end + 1) = this.Factory.assemble( ...
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

            if hasIALiRT

                primaryIALiRT = this.Results.IALiRT.Primary;
                secondaryIALiRT = this.Results.IALiRT.Secondary;

                primaryIALiRTComparison = synchronize(timetable(primaryIALiRT.Time, primaryIALiRT.X, primaryIALiRT.Y, primaryIALiRT.Z, primaryIALiRT.Quality.isPlottable(), VariableNames = ["xc", "yc", "zc", "qc"]), ...
                    timetable(primaryScience.Time, primaryScience.X, primaryScience.Y, primaryScience.Z, primaryScience.Quality.isPlottable(), VariableNames = ["xs", "ys", "zs", "qs"]), "first", "nearest");
                secondaryIALiRTComparison = synchronize(timetable(secondaryIALiRT.Time, secondaryIALiRT.X, secondaryIALiRT.Y, secondaryIALiRT.Z, secondaryIALiRT.Quality.isPlottable(), VariableNames = ["xc", "yc", "zc", "qc"]), ...
                    timetable(secondaryScience.Time, secondaryScience.X, secondaryScience.Y, secondaryScience.Z, secondaryScience.Quality.isPlottable(), VariableNames = ["xs", "ys", "zs", "qs"]), "first", "nearest");

                primaryGraphs = this.generateComparisonGraph(primaryIALiRTComparison, "left");
                secondaryGraphs = this.generateComparisonGraph(secondaryIALiRTComparison, "right");
    
                this.Figures(end + 1) = this.Factory.assemble( ...
                    primaryIALiRTComparison, primaryGraphs, secondaryIALiRTComparison, secondaryGraphs, ...
                    Name = "Science vs. I-ALiRT (Closest Vector)", ...
                    Arrangement = [9, 2], ...
                    GlobalLegend = ["Science", "I-ALiRT"], ...
                    LinkXAxes = true, ...
                    TileIndexing = "columnmajor", ...
                    WindowState = "maximized");
            end

            if hasSID5

                sid5HK.Data(ismissing(sid5HK.FOBT), :) = [];
                sid5HK.Data(ismissing(sid5HK.FIBT), :) = [];

                primarySID5Comparison = synchronize(timetable(sid5HK.FOBT, sid5HK.FOBX, sid5HK.FOBY, sid5HK.FOBZ, true(height(sid5HK.Data), 1), VariableNames = ["xc", "yc", "zc", "qc"]), ...
                    timetable(primaryScience.Time, primaryScience.X, primaryScience.Y, primaryScience.Z, primaryScience.Quality.isPlottable(), VariableNames = ["xs", "ys", "zs", "qs"]), "first", "nearest");
                secondarySID5Comparison = synchronize(timetable(sid5HK.FIBT, sid5HK.FIBX, sid5HK.FIBY, sid5HK.FIBZ, true(height(sid5HK.Data), 1), VariableNames = ["xc", "yc", "zc", "qc"]), ...
                    timetable(secondaryScience.Time, secondaryScience.X, secondaryScience.Y, secondaryScience.Z, secondaryScience.Quality.isPlottable(), VariableNames = ["xs", "ys", "zs", "qs"]), "first", "nearest");

                primaryGraphs = this.generateComparisonGraph(primarySID5Comparison, "left");
                secondaryGraphs = this.generateComparisonGraph(secondarySID5Comparison, "right");
    
                this.Figures(end + 1) = this.Factory.assemble( ...
                    primarySID5Comparison, primaryGraphs, secondarySID5Comparison, secondaryGraphs, ...
                    Name = "Science vs. SID5 (Closest Vector)", ...
                    Arrangement = [9, 2], ...
                    GlobalLegend = ["Science", "SID5"], ...
                    LinkXAxes = true, ...
                    TileIndexing = "columnmajor", ...
                    WindowState = "maximized");
            end
        end
    end

    methods (Static, Access = private)

        function data = combineDataSources(science, iALiRT, sid5, sensor)

            arguments (Input)
                science (1, 1) mag.Science
                iALiRT (1, 1) mag.Science
                sid5 (1, 1) mag.imap.hk.Science
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

        function charts = generateOverlayGraph(sensorName, yAxisLocation)

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

        function charts = generateComparisonGraph(comparisonData, yAxisLocation)

            arguments (Input)
                comparisonData timetable
                yAxisLocation (1, 1) string {mustBeMember(yAxisLocation, ["left", "right"])}
            end

            arguments (Output)
                charts (1, 6) mag.graphics.style.Default
            end

            defaultColors = colororder();

            charts = [ ...
                mag.graphics.style.Default(YLabel = "x [nT]", YAxisLocation = yAxisLocation, Layout = [2, 1], Charts = [mag.graphics.chart.Plot(YVariables = "xs", Marker = "o", Filter = comparisonData.qs), mag.graphics.chart.Plot(YVariables = "xc", Marker = "x", Filter = comparisonData.qc)]), ...
                mag.graphics.style.Default(YLabel = "\Deltax [nT]", YAxisLocation = yAxisLocation, Charts = mag.graphics.chart.Plot(YVariables = mag.graphics.operation.Subtract(Minuend = "xs", Subtrahend = "xc"), Colors = defaultColors(3, :), Filter = comparisonData.qs & comparisonData.qc)), ...
                mag.graphics.style.Default(YLabel = "y [nT]", YAxisLocation = yAxisLocation, Layout = [2, 1], Charts = [mag.graphics.chart.Plot(YVariables = "ys", Marker = "o", Filter = comparisonData.qs), mag.graphics.chart.Plot(YVariables = "yc", Marker = "x", Filter = comparisonData.qc)]), ...
                mag.graphics.style.Default(YLabel = "\Deltay [nT]", YAxisLocation = yAxisLocation, Charts = mag.graphics.chart.Plot(YVariables = mag.graphics.operation.Subtract(Minuend = "ys", Subtrahend = "yc"), Colors = defaultColors(3, :), Filter = comparisonData.qs & comparisonData.qc)), ...
                mag.graphics.style.Default(YLabel = "z [nT]", YAxisLocation = yAxisLocation, Layout = [2, 1], Charts = [mag.graphics.chart.Plot(YVariables = "zs", Marker = "o", Filter = comparisonData.qs), mag.graphics.chart.Plot(YVariables = "zc", Marker = "x", Filter = comparisonData.qc)]), ...
                mag.graphics.style.Default(YLabel = "\Deltaz [nT]", YAxisLocation = yAxisLocation, Charts = mag.graphics.chart.Plot(YVariables = mag.graphics.operation.Subtract(Minuend = "zs", Subtrahend = "zc"), Colors = defaultColors(3, :), Filter = comparisonData.qs & comparisonData.qc))];
        end
    end
end
