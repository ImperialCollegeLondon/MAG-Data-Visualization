classdef Field < mag.graphics.view.View
% FIELD Show magnetic field and optional HK.

    methods

        function this = Field(results, options)

            arguments
                results
                options.?mag.hs.view.Field
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            science = this.Results.Science;
            hk = this.Results.HK;

            if this.Results.HasHK

                this.Figures = this.Factory.assemble( ...
                    science, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(science), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Layout = [3, 1], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = science.Quality.isPlottable())), ...
                    hk, mag.graphics.style.Default(Title = "Sensor Temperatures", YLabel = this.TLabel, Legend = ["Temperature 1", "Temperature 2"], Charts = mag.graphics.chart.Plot(YVariables = "Temperature" + [1, 2])), ...
                    Title = this.getFigureTitle(science), ...
                    Name = this.getFigureName(science), ...
                    Arrangement = [4, 1], ...
                    LinkXAxes = true, ...
                    WindowState = "maximized");
            else

                this.Figures = this.Factory.assemble( ...
                    science, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(science), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Layout = [3, 1], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = science.Quality.isPlottable())), ...
                    Title = this.getFigureTitle(science), ...
                    Name = this.getFigureName(science), ...
                    Arrangement = [3, 1], ...
                    LinkXAxes = true, ...
                    WindowState = "maximized");
            end
        end
    end

    methods (Access = private)

        function value = getFigureTitle(this, data)
            value = compose("%s (%s)", data.MetaData.getDisplay("Mode"), this.getDataFrequency(data.MetaData));
        end

        function value = getFigureName(this, data)
            value = compose("%s (%s) Time Series (%s)", data.MetaData.getDisplay("Mode"), this.getDataFrequency(data.MetaData), this.date2str(data.MetaData.Timestamp));
        end
    end

    methods (Static, Access = private)

        function value = getFieldTitle(data)

            if isempty(data.MetaData.Setup) || isempty(data.MetaData.Setup.FEE) || isempty(data.MetaData.Setup.Model) || isempty(data.MetaData.Setup.Can)
                value = data.MetaData.getDisplay("Sensor");
            else
                value = compose("%s (%s - %s - %s)", data.MetaData.Sensor, data.MetaData.Setup.FEE, data.MetaData.Setup.Model, data.MetaData.Setup.Can);
            end
        end
    end
end
