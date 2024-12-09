classdef Smooth < mag.process.Step
% SMOOTH Smooth noisy data with moving average.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % VARIABLES Variables to smooth.
        Variables (1, :) string
        % WINDOW Window for moving average.
        Window (1, 1) duration
    end

    methods

        function this = Smooth(options)

            arguments
                options.?mag.process.Smooth
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Smooth";
        end

        function value = get.Description(~)
            value = "Smooth data with moving average.";
        end

        function value = get.DetailedDescription(this)
            value = this.Description;
        end

        function data = apply(this, data, ~)

            arguments
                this (1, 1) mag.process.Smooth
                data timetable
                ~
            end

            data(:, this.Variables) = smoothdata(data(:, this.Variables), "movmean", this.Window);
        end
    end
end
