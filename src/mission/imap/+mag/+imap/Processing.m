classdef Processing < mag.Processing
% PROCESSING Capture IMAP processing steps for each phase.

    properties
        % IALIRTSTEPS Steps needed to process only I-ALiRT data.
        IALiRTSteps (1, :) mag.process.Step
        % RAMPSTEPS Steps needed to process only ramp mode data.
        RampSteps (1, :) mag.process.Step
    end

    methods (Static)

        function processing = getStepsForLevel(level)

            arguments
                level (1, 1) mag.imap.meta.Level
            end

            switch level
                case mag.imap.meta.Level.L1a
                    processing = mag.imap.Processing.getL1aSteps();
                case mag.imap.meta.Level.L1b
                    processing = mag.imap.Processing.getL1bSteps();
                otherwise
                    error("mag:processing:InvalidLevel", "Level ""%s"" not supported for IMAP processing.", string(level));
            end
        end

        function processing = getL1aSteps()

            processing = mag.imap.Processing();

            processing.PerFileSteps = [ ...
                mag.process.AllZero(Variables = ["coarse", "fine", "x", "y", "z"]), ...
                mag.process.SignedInteger(CompressionVariable = "compression", Variables = ["x", "y", "z"]), ...
                mag.process.Separate(DiscriminationVariable = "t", LargeDiscriminateThreshold = minutes(1), QualityVariable = "quality", Variables = ["x", "y", "z"])];

            processing.WholeDataSteps = [ ...
                mag.process.Sort(), ...
                mag.process.Duplicates()];

            processing.ScienceSteps = [
                mag.process.EventFilter(OnModeChange = [0, 1], OnRangeChange = [-1, 5]), ...
                mag.process.Range(RangeVariable = "range", Variables = ["x", "y", "z"]), ...
                mag.process.Calibration(RangeVariable = "range", Variables = ["x", "y", "z"]), ...
                mag.process.Compression(CompressionVariable = "compression", CompressionWidthVariable = "compression_width", Variables = ["x", "y", "z"])];

            processing.IALiRTSteps = [
                mag.process.EventFilter(OnRangeChange = [0, 1]), ...
                mag.process.Range(RangeVariable = "range", Variables = ["x", "y", "z"]), ...
                mag.process.Calibration(RangeVariable = "range", Variables = ["x", "y", "z"])];

            processing.RampSteps = [ ...
                mag.process.Unwrap(Variables = ["x", "y", "z"]), ...
                mag.process.Ramp()];

            processing.HKSteps = [ ...
                mag.process.Units(), ...
                mag.process.Duplicates(), ...
                mag.process.Separate(DiscriminationVariable = "t", LargeDiscriminateThreshold = minutes(5), QualityVariable = string.empty(), Variables = "*"), ...
                mag.process.Sort()];
        end

        function processing = getL1bSteps()

            processing = mag.imap.Processing.getL1aSteps();

            processing.PerFileSteps = [mag.process.AllZero(Variables = ["x", "y", "z"]), ...
                mag.process.Convert(Variables = ["x", "y", "z"], DataType = "double"), ...
                mag.process.Separate(DiscriminationVariable = "timestamps", LargeDiscriminateThreshold = minutes(1), QualityVariable = "quality", Variables = ["x", "y", "z"])];

            processing.WholeDataSteps = [mag.process.Sort(), mag.process.Duplicates()];
            processing.ScienceSteps = [mag.process.Filter(OnModeChange = [0, 1], OnRangeChange = [-1, 5])];
        end
    end
end
