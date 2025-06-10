classdef HK < mag.graphics.view.View
% HK Show housekeeping for HelioSwarm.

    methods

        function this = HK(results, options)

            arguments
                results
                options.?mag.hs.view.HK
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            hk = this.Results.HK;

            this.Figures = this.Factory.assemble( ...
                hk, ...
                [mag.graphics.style.Default(Title = "1.5 V", YLabel = "[V]", Charts = mag.graphics.chart.Plot(YVariables = "P1V5V")), ...
                mag.graphics.style.Default(Title = "2.5 V", YLabel = "[V]", Charts = mag.graphics.chart.Plot(YVariables = "P2V5V")), ...
                mag.graphics.style.LeftRight(Title = "+8.5 V", LeftLabel = "[V]", RightLabel = "[mA]", Charts = [mag.graphics.chart.Plot(YVariables = "P8V5V"), mag.graphics.chart.Plot(YVariables = "P8V5I")]), ...
                mag.graphics.style.LeftRight(Title = "-8.5 V", LeftLabel = "[V]", RightLabel = "[mA]", Charts = [mag.graphics.chart.Plot(YVariables = "N8V5V"), mag.graphics.chart.Plot(YVariables = "N8V5I")]), ...
                mag.graphics.style.Stackedplot(Title = "Temperature", YLabels = ["Board " + this.TLabel, "Sensor " + this.TLabel], Layout = [2, 2], Charts = mag.graphics.chart.Stackedplot(YVariables = ["Board", "Sensor"] + "Temperature"))], ...
                Name = "HK Time Series", ...
                Arrangement = [4, 2], ...
                TileIndexing = "rowmajor", ...
                LinkXAxes = true, ...
                WindowState = "maximized");
        end
    end
end
