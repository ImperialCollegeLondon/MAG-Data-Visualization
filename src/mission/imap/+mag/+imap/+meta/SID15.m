classdef SID15 < mag.imap.meta.Provider
% SID15 Load metadata from SID15 HK files.

    properties (Constant, Access = private)
        % EXTENSIONS Extensions supported.
        Extensions = ".csv"
    end

    properties
        % PROCESSINGSTEPS Steps needed to process imported data.
        ProcessingSteps (1, :) mag.process.Step = [ ...
            mag.process.Spice(TimeVariable = "SHCOARSE", Mission = "IMAP")]
    end

    methods

        function this = SID15(options)

            arguments
                options.?mag.imap.meta.SID15
            end

            this.assignProperties(options);
        end

        function supported = isSupported(this, fileName)

            arguments
                this (1, 1) mag.imap.meta.SID15
                fileName (1, 1) string
            end

            [~, ~, extension] = fileparts(fileName);

            supported = isfile(fileName) && ismember(extension, this.Extensions);
        end

        function [instrumentMetadata, primarySetup, secondarySetup] = load(this, fileName, instrumentMetadata, primarySetup, secondarySetup)

            arguments
                this (1, 1) mag.imap.meta.SID15
                fileName (1, 1) string {mustBeFile}
                instrumentMetadata (1, 1) mag.meta.Instrument
                primarySetup (1, 1) mag.meta.Setup
                secondarySetup (1, 1) mag.meta.Setup
            end

            % Load data.
            dataStore = tabularTextDatastore(fileName, TextType = "string", FileExtensions = this.Extensions, SelectedVariableNames = ["SHCOARSE", "ISV_FOB_ACTTRIES", "ISV_FIB_ACTTRIES"]);
            rawData = dataStore.readall(UseParallel = mag.internal.useParallel());

            rawData = sortrows(rawData, "SHCOARSE");

            % Process data.
            for ps = this.ProcessingSteps
                rawData = ps.apply(rawData, mag.meta.Data.empty());
            end

            % Extract attempts.
            fobAttempts = median(rawData{rawData.ISV_FOB_ACTTRIES ~= 0, "ISV_FOB_ACTTRIES"});
            fibAttempts = median(rawData{rawData.ISV_FIB_ACTTRIES ~= 0, "ISV_FIB_ACTTRIES"});

            instrumentMetadata.Attempts = [fobAttempts, fibAttempts];

            instrumentMetadata.Timestamp = rawData{1, "SHCOARSE"};
            instrumentMetadata.Timestamp.TimeZone = mag.time.Constant.TimeZone;
            instrumentMetadata.Timestamp.Format = mag.time.Constant.Format;
        end
    end
end
