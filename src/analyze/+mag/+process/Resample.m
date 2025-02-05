classdef Resample < mag.process.Step
% RESAMPLE Resample data to new fixed rate.

    properties
        % RATE Rate to resample to.
        Rate (1, 1) double
    end

    methods

        function this = Resample(options)

            arguments
                options.?mag.process.Resample
            end

            this.assignProperties(options);
        end

        function data = apply(this, data, ~)

            arguments
                this (1, 1) mag.process.Resample
                data timetable
                ~
            end

            data = resample(data, this.Rate);
        end
    end
end
