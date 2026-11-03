classdef DualSensorField < mag.graphics.view.DualSensorView
% DUALSENSORFIELD Show magnetic field of instrument with outboard and
% inboard sensors.

    methods

        function this = DualSensorField(results, options)

            arguments
                results (1, 1) mag.DualSensorInstrument
                options.?mag.graphics.view.DualSensorField
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            [science, names, axisLocations] = this.getSensorsWithData();

            if isempty(science)
                return;
            end

            scienceData = {};

            for i = 1:numel(science)

                scienceData = [scienceData, {science(i), ...
                    mag.graphics.style.Stackedplot(Title = names(i), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], YAxisLocation = axisLocations(i), ...
                    Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"]))}]; %#ok<AGROW>
            end

            this.Figures = this.Factory.assemble( ...
                scienceData{:}, ...
                Title = this.getFigureTitle(science), ...
                Name = this.getFigureName(science, "Time Series"), ...
                Arrangement = [1, numel(science)], ...
                LinkXAxes = true, ...
                WindowState = "maximized");
        end
    end
end
