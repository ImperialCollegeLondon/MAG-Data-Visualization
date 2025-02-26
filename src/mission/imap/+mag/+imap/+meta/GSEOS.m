classdef GSEOS < mag.imap.meta.Provider
% GSEOS Load metadata from GSEOS log files.

    properties (Constant, Access = private)
        % EXTENSIONS Extensions supported.
        Extensions = [".msg", ".log"]
        % NAMES Variable names to use to load data.
        Names (1, :) string = ["Type", "Date", "Time", "Source", "A", "B", "Message"]
        % FORMATS Formats to use to load data.
        Formats (1, :) string = ["%C", "%{MM/dd/yy}D", "%{hh:mm:ss.SSS}T", "%C", "%f", "%f", "%q"]
        % METADATAPATTERN Regex pattern to extract metadata from log.
        MetadataPattern (:, 1) string = ["^Test Name: (?<name>.*)$", ...
            "^Operators: (?<operator>.*)$", ...
            "^(?<cpt>.*)$", ...
            "^.*$", ...
            "^BSW:\s*(?<bsw>.*)$", ...
            "^ASW:\s*(?<asw>.*)$", ...
            "^GSE:\s*(?<gse>.*)$", ...
            "^GSEOS:\s*(?<gseos>.*)$"]
    end

    methods

        function supported = isSupported(this, fileName)

            arguments
                this (1, 1) mag.imap.meta.GSEOS
                fileName (1, 1) string
            end

            [~, ~, extension] = fileparts(fileName);

            supported = isfile(fileName) && ismember(extension, this.Extensions);
        end

        function [instrumentMetadata, primarySetup, secondarySetup] = load(this, fileName, instrumentMetadata, primarySetup, secondarySetup)

            arguments
                this (1, 1) mag.imap.meta.GSEOS
                fileName (1, 1) string {mustBeFile}
                instrumentMetadata (1, 1) mag.meta.Instrument
                primarySetup (1, 1) mag.meta.Setup
                secondarySetup (1, 1) mag.meta.Setup
            end

            dataStore = tabularTextDatastore(fileName, FileExtensions = this.Extensions, TextType = "string", VariableNames = this.Names, TextscanFormats = this.Formats);
            rawData = dataStore.readall(UseParallel = mag.internal.useParallel());

            if isempty(rawData)
                return;
            end

            timestamp = datetime(rawData.Date(1) + rawData.Time(1), TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format);
            messages = join(rawData.Message, newline);

            % Extract number of activation attempts.
            fobAttempts = regexp(messages, "^MAG_HSK_SID15 ISV_FOB_ACTTRIES = (\d+). DN", "once", "tokens", "dotexceptnewline", "lineanchors");
            fibAttempts = regexp(messages, "^MAG_HSK_SID15 ISV_FIB_ACTTRIES = (\d+). DN", "once", "tokens", "dotexceptnewline", "lineanchors");

            if ~isempty(fobAttempts) && ~isempty(fibAttempts)
                instrumentMetadata.Attemps = [fobAttempts, fibAttempts];
            end

            % Assign instrument metadata.
            instrumentMetadata.Timestamp = timestamp;

            if contains(messages, "CPT", IgnoreCase = true)

                model = regexp(messages, "^MAG_PROG_BTSUCC HW_MODEL = (.*)$", "tokens", "once", "dotexceptnewline", "lineanchors");
                genericData = regexp(messages, join(this.MetadataPattern, "\s*"), "names", "dotexceptnewline", "lineanchors");

                if isempty(genericData)
                    return;
                end

                instrumentMetadata.Model = model;
                instrumentMetadata.BSW = genericData.bsw;
                instrumentMetadata.ASW = genericData.asw;
                instrumentMetadata.Operator = genericData.operator;
                instrumentMetadata.Description = genericData.name;
            end
        end
    end
end
