classdef AllZero < mag.process.Step
% ALLZERO Remove vectors where timestamp and data is all zero.

    properties
        % VARIABLES Variables to check for all-zero.
        Variables (1, :) {mustBeA(Variables, ["string", "pattern"])} = string.empty()
        % REPLACE Whether to replace data with NaNs or to remove it.
        Replace (1, 1) logical = false
    end

    methods

        function this = AllZero(options)

            arguments
                options.?mag.process.AllZero
            end

            this.assignProperties(options);
        end

        function data = apply(this, data, ~)

            arguments
                this (1, 1) mag.process.AllZero
                data tabular
                ~
            end

            if isa(this.Variables, "pattern") && ~isscalar(this.Variables)
                error("mag:process:NonScalarPattern", "Filtering variable defined as a pattern must be a scalar.");
            end

            locData = all(data{:, this.Variables} == 0, 2);

            if this.Replace
                data(locData, this.Variables) = convertvars(data(locData, this.Variables), @mag.internal.isMissingCompatible, @(x) repmat(missing(), size(x)));
            else
                data(locData, :) = [];
            end
        end
    end
end
