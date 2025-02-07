classdef AllZero < mag.process.Step
% ALLZERO Remove vectors where timestamp and data is all zero.

    properties
        % VARIABLES Variables to check for all-zero.
        Variables (1, :) string
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

            locData = all(data{:, this.Variables} == 0, 2);
            data(locData, :) = [];
        end
    end
end
