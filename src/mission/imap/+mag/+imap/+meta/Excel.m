classdef Excel < mag.imap.meta.Type
% EXCEL Load meta data from Excel files.

    properties (Constant)
        Extensions = ".xlsx"
        % ACTIVATIONPATTERN Regex pattern to extract number of attempts to
        % start up the sensors.
        ActivationPattern (1, 1) string = "^\s*FOB:\s*(?<fob>\d+)?.*?FIB:\s*(?<fib>\d+)?.*?Repeat activation\?:\s*(:?y\/n)?\s*(?<repeat>.*?)?\s*$"
        % SENSORPATTERN Regex pattern to extract sensor meta data.
        SensorPattern (1, 1) string = "(?<fee>FEE\d).*?,\s*(?<harness>.+?)\s*,.*?(?<model>[LEF]M\d)\s*(?<can>\(.*?\))?"
    end

    methods

        function this = Excel(options)

            arguments
                options.?mag.imap.meta.Excel
            end

            this.assignProperties(options);
        end
    end

    methods

        function [instrumentMetaData, primarySetup, secondarySetup] = load(this, instrumentMetaData, primarySetup, secondarySetup)

            arguments
                this (1, 1) mag.imap.meta.Excel
                instrumentMetaData (1, 1) mag.meta.Instrument
                primarySetup (1, 1) mag.meta.Setup
                secondarySetup (1, 1) mag.meta.Setup
            end

            % Read meta data file.
            importOptions = spreadsheetImportOptions(NumVariables = 9, VariableTypes = repmat("string", 1, 9), Sheet = "Sheet1");

            rawData = readtable(this.FileName, importOptions);
            rawData = rmmissing(rawData, 1, MinNumMissing = size(rawData, 2));
            rawData = rmmissing(rawData, 2, MinNumMissing = size(rawData, 1));

            % Extract sensor meta data.
            primaryDetails = regexp(rawData{3, "Var6"}, this.SensorPattern, "once", "names");
            secondaryDetails = regexp(rawData{4, "Var6"}, this.SensorPattern, "once", "names");

            assert(~isempty(primaryDetails), "No meta data detected for FOB.");
            assert(~isempty(secondaryDetails), "No meta data detected for FIB.");

            % Extract activation meta data.
            data = join(rmmissing(rawData{:, "Var1"}), newline);

            if contains(data, "SFT", IgnoreCase = true)

                attempts.fob = NaN;
                attempts.fib = NaN;
            else

                attempts = regexp(data, this.ActivationPattern, "once", "names", "dotexceptnewline", "lineanchors");
                assert(~isempty(attempts), "No meta data detected for activation attempts.");

                if ~contains(attempts.repeat, "n", IgnoreCase = true)

                    warning("Manual intervention required. Cannot determine number of activation attemps. Detected values are: FOB ""%s"", FIB ""%s"", Repeat ""%s"".", attempts.fob, attempts.fib, attempts.repeat);
                    attempts.fob = NaN;
                    attempts.fib = NaN;
                end
            end

            % Assign instrument meta data.
            instrumentMetaData.Model = extract(rawData{4, "Var3"}, regexpPattern("[LEF]M"));
            instrumentMetaData.BSW = rawData{5, "Var3"};
            instrumentMetaData.ASW = rawData{5, "Var7"};
            instrumentMetaData.Attemps = [attempts.fob, attempts.fib];
            instrumentMetaData.Operator = rawData{3, "Var3"};
            instrumentMetaData.Description = rawData{6, "Var7"};
            instrumentMetaData.Timestamp = datetime(rawData{6, "Var3"}, TimeZone = "UTC", Format = mag.time.Constant.Format) + ...
                duration(regexp(data, "^Time: (\d+\:\d+)", "once", "tokens", "dotexceptnewline", "lineanchors"), InputFormat = "hh:mm");

            % Enhance primary and secondary meta data.
            primarySetup.Model = primaryDetails.model;
            primarySetup.FEE = primaryDetails.fee;
            primarySetup.Harness = primaryDetails.harness;

            if isfield(primaryDetails, "can")
                primarySetup.Can = extractBetween(primaryDetails.can, "(", ")");
            end

            secondarySetup.Model = secondaryDetails.model;
            secondarySetup.FEE = secondaryDetails.fee;
            secondarySetup.Harness = secondaryDetails.harness;

            if isfield(secondaryDetails, "can")
                secondarySetup.Can = extractBetween(secondaryDetails.can, "(", ")");
            end
        end
    end
end
