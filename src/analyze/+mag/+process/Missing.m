classdef Missing < mag.process.Step
% MISSING Remove rows where all the values in the columns of interest are
% missing.

    properties
        % VARIABLES Variables to be used as reference to detect missing
        % values.
        Variables (1, :) string
    end

    methods

        function this = Missing(options)

            arguments
                options.?mag.process.Missing
            end

            this.assignProperties(options);
        end

        function data = apply(this, data, ~)
            data = rmmissing(data, DataVariables = this.Variables, MinNumMissing = numel(this.Variables));
        end
    end
end
