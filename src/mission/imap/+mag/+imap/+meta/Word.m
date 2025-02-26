classdef Word < mag.imap.meta.Type
% WORD Load metadata from Word files.

    properties (Constant)
        Extensions = ".docx"
    end

    methods

        function this = Word(options)

            arguments
                options.?mag.imap.meta.Word
            end

            this.assignProperties(options);
        end
    end

    methods

        function [instrumentMetadata, primarySetup, secondarySetup] = load(this, instrumentMetadata, primarySetup, secondarySetup)

            arguments
                this (1, 1) mag.imap.meta.Word
                instrumentMetadata (1, 1) mag.meta.Instrument
                primarySetup (1, 1) mag.meta.Setup
                secondarySetup (1, 1) mag.meta.Setup
            end

            % Read metadata file.
            % If Word document does not contain table, ignore it.
            importOptions = wordDocumentImportOptions(TableSelector = "//w:tbl[contains(.,'MAG Operator')]");
            rawData = readtable(this.FileName, importOptions);

            if isempty(rawData)
                return;
            end

            rawData = rows2vars(rawData, VariableNamesSource = 1, VariableNamingRule = "preserve");

            % Check if document is for EM.
            if (width(rawData) == 14) && contains(this.FileName, "IMAP-OPS-TE-ICL-001")

                rawData = renamevars(rawData, 2:14, ["Operator", "Date", "Time", "Name", "BSW", "ASW", "GSE", "FOBModel", "FOBHarness", "FOBCan", "FIBModel", "FIBHarness", "FIBCan"]);

                model = "EM";
                primaryFEE = "FEE1";
                secondaryFEE = "FEE2";

            % Check if it is for FM.
            elseif (width(rawData) == 15) && contains(this.FileName, "IMAP-MAG-TE-ICL-071" | "IMAP-OPS-TE-ICL-002")

                rawData = renamevars(rawData, 2:15, ["Operator", "Controller", "Date", "Time", "Name", "BSW", "ASW", "GSE", "FOBModel", "FOBHarness", "FOBCan", "FIBModel", "FIBHarness", "FIBCan"]);

                model = "FM";
                primaryFEE = "FEE3";
                secondaryFEE = "FEE4";

            % Otherwise, error.
            else
                error("Unrecognized table format.");
            end

            % Assign instrument metadata.
            instrumentMetadata.Model = model;
            instrumentMetadata.BSW = extractAfter(rawData.BSW, optionalPattern(lettersPattern()));
            instrumentMetadata.ASW = extractAfter(rawData.ASW, optionalPattern(lettersPattern()));
            instrumentMetadata.GSE = extractAfter(rawData.GSE, optionalPattern(lettersPattern()));
            instrumentMetadata.Operator = rawData.Operator;
            instrumentMetadata.Description = rawData.Name;
            instrumentMetadata.Timestamp = mag.time.decodeDate(rawData.Date) + mag.time.decodeTime(rawData.Time);

            % Enhance primary and secondary metadata.
            primarySetup.Model = rawData.FOBModel;
            primarySetup.FEE = primaryFEE;
            primarySetup.Harness = rawData.FOBHarness;
            primarySetup.Can = rawData.FOBCan;

            secondarySetup.Model = rawData.FIBModel;
            secondarySetup.FEE = secondaryFEE;
            secondarySetup.Harness = rawData.FIBHarness;
            secondarySetup.Can = rawData.FIBCan;
        end
    end
end
