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

            fob = this.Results.FOB;
            fib = this.Results.FIB;

            [numScience, scienceData] = this.getScienceData(fob, fib);

            if isempty(scienceData)
                return;
            end

            this.Figures = this.Factory.assemble( ...
                scienceData{:}, ...
                Title = this.getFigureTitle(fob, fib), ...
                Name = this.getFigureName(fob, fib), ...
                Arrangement = [1, numScience], ...
                LinkXAxes = true, ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function value = getFigureTitle(this, fob, fib)

            hasFob = ~isempty(fob) && fob.HasData;
            hasFib = ~isempty(fib) && fib.HasData;

            if hasFob && hasFib
                value = compose("%s (%s, %s)", fob.Metadata.getDisplay("Mode"), this.getDataFrequency(fob.Metadata), this.getDataFrequency(fib.Metadata));
            elseif hasFob
                value = compose("%s (%s)", fob.Metadata.getDisplay("Mode"), this.getDataFrequency(fob.Metadata));
            elseif hasFib
                value = compose("%s (%s)", fib.Metadata.getDisplay("Mode"), this.getDataFrequency(fib.Metadata));
            end
        end

        function value = getFigureName(this, fob, fib)

            hasFob = ~isempty(fob) && fob.HasData;
            hasFib = ~isempty(fib) && fib.HasData;

            if hasFob && hasFib
                value = compose("%s (%s, %s) Time Series (%s)", fob.Metadata.getDisplay("Mode"), this.getDataFrequency(fob.Metadata), this.getDataFrequency(fib.Metadata), this.date2str(fob.Metadata.Timestamp));
            elseif hasFob
                value = compose("%s (%s) Time Series (%s)", fob.Metadata.getDisplay("Mode"), this.getDataFrequency(fob.Metadata), this.date2str(fob.Metadata.Timestamp));
            elseif hasFib
                value = compose("%s (%s) Time Series (%s)", fib.Metadata.getDisplay("Mode"), this.getDataFrequency(fib.Metadata), this.date2str(fib.Metadata.Timestamp));
            end
        end
    end

    methods (Static, Access = private)

        function [numScience, scienceData] = getScienceData(fob, fib)

            numScience = 0;
            scienceData = {};

            if ~isempty(fob) && fob.HasData

                numScience = numScience + 1;
                scienceData = [scienceData, {fob, ...
                    mag.graphics.style.Stackedplot(Title = "FOB", YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], ...
                    Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"]))}];
            end

            if ~isempty(fib) && fib.HasData

                numScience = numScience + 1;
                scienceData = [scienceData, {fib, ...
                    mag.graphics.style.Stackedplot(Title = "FIB", YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], YAxisLocation = "right", ...
                    Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"]))}];
            end
        end
    end
end
