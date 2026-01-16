classdef Field < mag.graphics.view.View
% FIELD Show Vigil magnetic field.

    methods

        function this = Field(results, options)

            arguments
                results (1, 1) mag.vigil.Instrument
                options.?mag.vigil.view.Field
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            outboard = this.Results.Outboard;
            inboard = this.Results.Inboard;

            [numScience, scienceData] = this.getScienceData(outboard, inboard);

            if isempty(scienceData)
                return;
            end

            this.Figures = this.Factory.assemble( ...
                scienceData{:}, ...
                Title = this.getFigureTitle(outboard, inboard), ...
                Name = this.getFigureName(outboard, inboard), ...
                Arrangement = [1, numScience], ...
                LinkXAxes = true, ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function value = getFigureTitle(this, outboard, inboard)

            hasOutboard = ~isempty(outboard) && outboard.HasData;
            hasInboard = ~isempty(inboard) && inboard.HasData;

            if hasOutboard && hasInboard
                value = compose("%s (%s, %s)", outboard.Metadata.getDisplay("Mode"), this.getDataFrequency(outboard.Metadata), this.getDataFrequency(inboard.Metadata));
            elseif hasOutboard
                value = compose("%s (%s)", outboard.Metadata.getDisplay("Mode"), this.getDataFrequency(outboard.Metadata));
            elseif hasInboard
                value = compose("%s (%s)", inboard.Metadata.getDisplay("Mode"), this.getDataFrequency(inboard.Metadata));
            end
        end

        function value = getFigureName(this, outboard, inboard)

            hasOutboard = ~isempty(outboard) && outboard.HasData;
            hasInboard = ~isempty(inboard) && inboard.HasData;

            if hasOutboard && hasInboard
                value = compose("%s (%s, %s) Time Series (%s)", outboard.Metadata.getDisplay("Mode"), this.getDataFrequency(outboard.Metadata), this.getDataFrequency(inboard.Metadata), this.date2str(outboard.Metadata.Timestamp));
            elseif hasOutboard
                value = compose("%s (%s) Time Series (%s)", outboard.Metadata.getDisplay("Mode"), this.getDataFrequency(outboard.Metadata), this.date2str(outboard.Metadata.Timestamp));
            elseif hasInboard
                value = compose("%s (%s) Time Series (%s)", inboard.Metadata.getDisplay("Mode"), this.getDataFrequency(inboard.Metadata), this.date2str(inboard.Metadata.Timestamp));
            end
        end
    end

    methods (Static, Access = private)

        function [numScience, scienceData] = getScienceData(outboard, inboard)

            numScience = 0;
            scienceData = {};

            if ~isempty(outboard) && outboard.HasData

                numScience = numScience + 1;
                scienceData = [scienceData, {outboard, ...
                    mag.graphics.style.Stackedplot(Title = "Outboard", YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], ...
                    Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"]))}];
            end

            if ~isempty(inboard) && inboard.HasData

                numScience = numScience + 1;
                scienceData = [scienceData, {inboard, ...
                    mag.graphics.style.Stackedplot(Title = "Inboard", YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], YAxisLocation = "right", ...
                    Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"]))}];
            end
        end
    end
end
