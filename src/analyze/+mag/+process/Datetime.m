classdef Datetime < mag.process.Step
% DATETIME Convert timestamp to datetime.

    properties
        % TIMEVARIABLE Name of time variable.
        TimeVariable (1, 1) string = "t"
        % EPOCH Time offset to account for POSIX time starting on 1st Jan
        % 1970.
        Epoch (1, 1) double = mag.time.Constant.Epoch
        % FORMAT Time format.
        Format (1, 1) string = mag.time.Constant.Format
        % TIMEZONE Time zone of input data.
        TimeZone (1, 1) string = mag.time.Constant.TimeZone
    end

    methods

        function this = Datetime(options)

            arguments
                options.?mag.process.Datetime
            end

            this.assignProperties(options);
        end

        function data = apply(this, data, ~)

            data.(this.TimeVariable) = datetime(this.Epoch + data.(this.TimeVariable), ConvertFrom = "posixtime", ...
                Format = this.Format, TimeZone = this.TimeZone);
        end
    end
end