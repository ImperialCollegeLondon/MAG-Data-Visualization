classdef Convert < mag.process.Step
% CONVERT Convert variables to type.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % TYPE Type to convert variables to.
        Type (1, 1) string
        % VARIABLES Variables to be set to missing.
        Variables (1, :) string
    end

    methods

        function this = Convert(options)

            arguments
                options.?mag.process.Convert
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Convert to Type";
        end

        function value = get.Description(this)
            value = "Convert " + join(compose("""%s""", this.Variables), ", ") + " to """ + this.Type + """.";
        end

        function value = get.DetailedDescription(this)
            value = this.Description;
        end

        function data = apply(this, data, ~)

            arguments
                this (1, 1) mag.process.Convert
                data tabular
                ~
            end

            if isempty(data)
                return;
            end

            data = convertvars(data, this.Variables, this.Type);
        end
    end
end
