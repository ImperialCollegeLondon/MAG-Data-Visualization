classdef GSEOS < mag.meta.log.Type
% GSEOS Load meta data from GSEOS log files.

    properties (Constant)
        Extensions = [".msg", ".log"]
        % NAMES Variable names to use to load data.
        Names (1, :) string = ["Type", "Date", "Time", "Source", "A", "B", "Message"]
        % FORMATS Formats to use to load data.
        Formats (1, :) string = ["%C", "%{MM/dd/yy}D", "%{hh:mm:ss.SSS}T", "%C", "%f", "%f", "%q"]
        % METADATAPATTERN Regex pattern to extract meta data from log.
        MetaDataPattern (:, 1) string = ["^Test Name: (?<name>.*)$", ...
            "^Operators: (?<operator>.*)$", ...
            "^(?<cpt>.*)$", ...
            "^.*$", ...
            "^BSW:\s*(?<bsw>.*)$", ...
            "^ASW:\s*(?<asw>.*)$", ...
            "^GSE:\s*(?<gse>.*)$", ...
            "^GSEOS:\s*(?<gseos>.*)$"]
    end

    methods

        function this = GSEOS(options)

            arguments
                options.?mag.meta.log.GSEOS
            end

            this.assignProperties(options);
        end
    end

    methods (Hidden)

        function [instrumentMetaData, primaryMetaData, secondaryMetaData] = load(this, instrumentMetaData, primaryMetaData, secondaryMetaData)

            arguments (Input)
                this
                instrumentMetaData (1, 1) mag.meta.Instrument
                primaryMetaData (1, :) mag.meta.Science
                secondaryMetaData (1, :) mag.meta.Science
            end

            arguments (Output)
                instrumentMetaData (1, 1) mag.meta.Instrument
                primaryMetaData (1, :) mag.meta.Science
                secondaryMetaData (1, :) mag.meta.Science
            end

            dataStore = tabularTextDatastore(this.FileName, FileExtensions = this.Extensions, TextType = "string", VariableNames = this.Names, TextscanFormats = this.Formats);
            rawData = dataStore.readall(UseParallel = ~isempty(gcp("nocreate")));

            if isempty(rawData)
                return;
            end

            timestamp = datetime(rawData.Date(1) + rawData.Time(1), TimeZone = mag.process.DateTime.TimeZone, Format = mag.process.DateTime.Format);
            messages = join(rawData.Message, newline);

            % Extract number of activation attempts.
            fobAttempts = regexp(messages, "^MAG_HSK_SID15 ISV_FOB_ACTTRIES = (\d+). DN", "once", "tokens", "dotexceptnewline", "lineanchors");
            fibAttempts = regexp(messages, "^MAG_HSK_SID15 ISV_FIB_ACTTRIES = (\d+). DN", "once", "tokens", "dotexceptnewline", "lineanchors");

            if ~isempty(fobAttempts) && ~isempty(fibAttempts)
                instrumentMetaData.Attemps = [fobAttempts, fibAttempts];
            end

            % Assign instrument meta data.
            if contains(messages, "CPT", IgnoreCase = true)

                model = regexp(messages, "^MAG_PROG_BTSUCC HW_MODEL = (.*)$", "tokens", "once", "dotexceptnewline", "lineanchors");
                genericData = regexp(messages, join(this.MetaDataPattern, "\s*"), "names", "dotexceptnewline", "lineanchors");

                assert(~isempty(genericData), "No generic meta data detected.");

                instrumentMetaData.Model = model;
                instrumentMetaData.BSW = genericData.bsw;
                instrumentMetaData.ASW = genericData.asw;
                instrumentMetaData.Operator = genericData.operator;
                instrumentMetaData.Description = genericData.name;
                instrumentMetaData.Timestamp = timestamp;
            else

                instrumentMetaData.Timestamp = timestamp;
            end
        end
    end
end
