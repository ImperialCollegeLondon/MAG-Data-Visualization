classdef Field < mag.graphics.view.View
% FIELD Show Bartington magnetic field.

    methods

        function this = Field(results, options)

            arguments
                results (1, 1) mag.bart.Instrument
                options.?mag.bart.view.Field
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            input1 = this.Results.Input1;
            input2 = this.Results.Input2;

            [numScience, scienceData] = this.getScienceData(input1, input2);

            if isempty(scienceData)
                return;
            end

            this.Figures = this.Factory.assemble( ...
                scienceData{:}, ...
                Title = this.getFigureTitle(input1, input2), ...
                Name = this.getFigureName(input1, input2), ...
                Arrangement = [1, numScience], ...
                LinkXAxes = true, ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function value = getFigureTitle(this, input1, input2)

            if isempty(input1)
                value = compose("Bartington (%s Hz)", this.getDataFrequency(input2.MetaData));
            elseif isempty(input2)
                value = compose("Bartington (%s Hz)", this.getDataFrequency(input1.MetaData));
            else
                value = compose("Bartington (%s, %s)", this.getDataFrequency(input1.MetaData), this.getDataFrequency(input2.MetaData));
            end
        end

        function value = getFigureName(this, input1, input2)

            if isempty(input1)
                value = compose("Bartington (%s Hz) Time Series (%s)", this.getDataFrequency(input2.MetaData), this.date2str(input2.MetaData.Timestamp));
            elseif isempty(input2)
                value = compose("Bartington (%s Hz) Time Series (%s)", this.getDataFrequency(input1.MetaData), this.date2str(input1.MetaData.Timestamp));
            else

                value = compose("Bartington (%s, %s) Time Series (%s)", this.getDataFrequency(input1.MetaData), this.getDataFrequency(input2.MetaData), ...
                    this.date2str(input1.MetaData.Timestamp));
            end
        end
    end

    methods (Static, Access = private)

        function [numScience, scienceData] = getScienceData(input1, input2)

            numScience = 0;
            scienceData = {};

            if ~isempty(input1) && input1.HasData

                numScience = numScience + 1;
                scienceData = [scienceData, {input1, ...
                    mag.graphics.style.Stackedplot(Title = "Input 1", YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], ...
                    Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"]))}];
            end

            if ~isempty(input2) && input2.HasData

                numScience = numScience + 1;
                scienceData = [scienceData, {input2, ...
                    mag.graphics.style.Stackedplot(Title = "Input 2", YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], YAxisLocation = "right", ...
                    Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"]))}];
            end
        end
    end
end
