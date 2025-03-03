classdef (Abstract, Hidden) Science < mag.graphics.view.View
% SCIENCE Base class for science data views.

    properties
        % NAME Figure name.
        Name string {mustBeScalarOrEmpty} = missing()
        % TITLE Figure title.
        Title string {mustBeScalarOrEmpty} = missing()
    end

    methods (Access = protected)

        function value = getFigureTitle(this, primary, secondary)

            if ismissing(this.Title)
                value = compose("%s (%s, %s)", primary.Metadata.getDisplay("Mode"), this.getDataFrequency(primary.Metadata), this.getDataFrequency(secondary.Metadata));
            else
                value = this.Title;
            end
        end

        function value = getFigureName(this, primary, secondary)

            if ismissing(this.Name)
                value = compose("%s (%s, %s) Time Series (%s)", primary.Metadata.getDisplay("Mode"), this.getDataFrequency(primary.Metadata), this.getDataFrequency(secondary.Metadata), this.date2str(primary.Metadata.Timestamp));
            else
                value = this.Name;
            end
        end
    end

    methods (Static, Access = protected)

        function value = getFieldTitle(data)

            if isempty(data.Metadata.Setup) || isempty(string(data.Metadata.Setup))
                value = data.Metadata.getDisplay("Sensor");
            else
                value = compose("%s (%s)", data.Metadata.Sensor, string(data.Metadata.Setup));
            end
        end
    end
end
