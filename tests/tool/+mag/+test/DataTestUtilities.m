classdef DataTestUtilities
% DATATESTUTILITIES Utilities for data tests.

    properties (Constant)
        % TIME Definition of timetable time.
        Time (:, 1) datetime = datetime("today", TimeZone = "UTC") + minutes(1:10)'
    end

    methods (Static)

        function scienceTT = getScienceTimetable()
        % GETSCIENCETIMETABLE Get timetable of science data.

            scienceTT = timetable(mag.test.DataTestUtilities.Time, (1:10)', (11:20)', (21:30)', 3 * ones(10, 1), (1:10)', false(10, 1), repmat(mag.meta.Quality.Regular, 10, 1), ...
                VariableNames = ["x", "y", "z", "range", "sequence", "compression", "quality"]);
            scienceTT.Properties.VariableContinuity = ["continuous", "continuous", "continuous", "step", "step", "step", "event"];
        end

        function pwrTT = getPowerTimetable()
        % GETPOWERTIMETABLE Get timetable of power HK data.

            pwrTT = timetable(mag.test.DataTestUtilities.Time, (21:30)', (22:31)', (23:32)', ...
                VariableNames = ["ICU_TEMP", "FOB_TEMP", "FIB_TEMP"]);
        end

        function procstatTT = getProcessorTimetable()
        % GETPROCESSORTIMETABLE Get timetable of processor HK data.

            procstatTT = timetable(mag.test.DataTestUtilities.Time, (0:9)', (9:-1:0)', ...
                VariableNames = ["OBNQ_NUM_MSG", "IBNQ_NUM_MSG"]);
        end
    end
end
