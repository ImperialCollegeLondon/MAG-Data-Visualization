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
                value = compose("%s (%s, %s)", primary.MetaData.getDisplay("Mode"), this.getDataFrequency(primary.MetaData), this.getDataFrequency(secondary.MetaData));
            else
                value = this.Title;
            end
        end

        function value = getFigureName(this, primary, secondary)

            if ismissing(this.Name)
                value = compose("%s (%s, %s) Time Series (%s)", primary.MetaData.getDisplay("Mode"), this.getDataFrequency(primary.MetaData), this.getDataFrequency(secondary.MetaData), this.date2str(primary.MetaData.Timestamp));
            else
                value = this.Name;
            end
        end
    end

    methods (Static, Access = protected)

        function dataFrequency = getDataFrequency(metaData)

            dataFrequency = metaData.getDisplay("DataFrequency");

            if ~ismissing(dataFrequency) && (dataFrequency < 1)

                [num, den] = rat(dataFrequency);
                dataFrequency = compose("%d/%d", num, den);
            else
                dataFrequency = num2str(dataFrequency);
            end
        end

        function value = getFieldTitle(data)

            if isempty(data.MetaData.Setup) || isempty(data.MetaData.Setup.FEE) || isempty(data.MetaData.Setup.Model) || isempty(data.MetaData.Setup.Can)
                value = data.MetaData.getDisplay("Sensor");
            else
                value = compose("%s (%s - %s - %s)", data.MetaData.Sensor, data.MetaData.Setup.FEE, data.MetaData.Setup.Model, data.MetaData.Setup.Can);
            end
        end
    end
end
