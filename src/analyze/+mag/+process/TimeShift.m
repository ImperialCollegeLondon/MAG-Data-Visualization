classdef TimeShift < mag.process.Step
% TIMESHIFT Apply time shift to data.

    properties
        % TIMEVARIABLE Variable to apply time shift to.
        TimeVariable string {mustBeScalarOrEmpty}
        % TIMESHIFTS Time shifts to apply to sensors.
        TimeShifts (1, 1) dictionary = configureDictionary("mag.meta.Sensor", "duration")
    end

    methods

        function this = TimeShift(options)

            arguments
                options.?mag.process.TimeShift
            end

            this.assignProperties(options);
        end

        function data = apply(this, data, metaData)

            arguments
                this (1, 1) mag.process.TimeShift
                data timetable
                metaData (1, 1) mag.meta.Science
            end

            if isempty(this.TimeVariable)
                timeVariable = data.Properties.DimensionNames{1};
            else
                timeVariable = this.TimeVariable;
            end

            if this.TimeShifts.isKey(metaData.Sensor)
                timeShift = this.TimeShifts(metaData.Sensor);
            else
                timeShift = 0;
            end

            data.(timeVariable) = data.(timeVariable) + timeShift;
        end
    end
end
