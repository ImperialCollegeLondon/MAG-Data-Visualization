classdef Convert < mag.process.Step
% CONVERT Convert variables to type.

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
