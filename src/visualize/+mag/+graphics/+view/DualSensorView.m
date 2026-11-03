classdef (Abstract) DualSensorView < mag.graphics.view.View
% DUALSENSORVIEW Abstract base class for views of instruments with
% outboard and inboard sensors.

    properties (SetAccess = protected)
        % SENSORNAMES Names of outboard and inboard sensors.
        SensorNames (1, 2) string = ["Outboard", "Inboard"]
        % TITLEPREFIX Prefix of figure title. If empty, the mode of the
        % first sensor with data is used.
        TitlePrefix string {mustBeScalarOrEmpty} = string.empty()
    end

    methods (Access = protected)

        function [science, names, axisLocations] = getSensorsWithData(this)
        % GETSENSORSWITHDATA Get science data of sensors with data, with
        % their names and the y-axis location of their charts.

            arguments (Input)
                this (1, 1) mag.graphics.view.DualSensorView
            end

            arguments (Output)
                science (1, :) mag.Science
                names (1, :) string
                axisLocations (1, :) string
            end

            sensors = {this.Results.Outboard, this.Results.Inboard};
            hasData = cellfun(@(s) ~isempty(s) && s.HasData, sensors);

            science = [mag.Science.empty(), sensors{hasData}];
            names = this.SensorNames(hasData);

            axisLocations = ["left", "right"];
            axisLocations = axisLocations(hasData);
        end

        function value = getFigureTitle(this, science)
        % GETFIGURETITLE Get title of figure, with data frequency of each
        % sensor.

            arguments
                this (1, 1) mag.graphics.view.DualSensorView
                science (1, :) mag.Science {mustBeNonempty}
            end

            if isempty(this.TitlePrefix)
                prefix = science(1).Metadata.getDisplay("Mode");
            else
                prefix = this.TitlePrefix;
            end

            frequencies = arrayfun(@(s) string(this.getDataFrequency(s.Metadata)), science);
            value = compose("%s (%s)", prefix, join(frequencies, ", "));
        end

        function value = getFigureName(this, science, type)
        % GETFIGURENAME Get name of figure, with its type and the timestamp
        % of the first sensor.

            arguments
                this (1, 1) mag.graphics.view.DualSensorView
                science (1, :) mag.Science {mustBeNonempty}
                type (1, 1) string
            end

            value = this.getFigureTitle(science) + compose(" %s (%s)", type, this.date2str(science(1).Metadata.Timestamp));
        end
    end
end
