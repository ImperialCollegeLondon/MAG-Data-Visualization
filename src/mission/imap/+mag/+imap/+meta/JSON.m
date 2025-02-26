classdef JSON < mag.imap.meta.Type
% JSON Load metadata from JSON files.

    properties (Constant)
        Extensions = ".json"
    end

    methods

        function this = JSON(options)

            arguments
                options.?mag.imap.meta.JSON
            end

            this.assignProperties(options);
        end
    end

    methods

        function [instrumentMetadata, primarySetup, secondarySetup] = load(this, instrumentMetadata, primarySetup, secondarySetup)

            arguments
                this (1, 1) mag.imap.meta.JSON
                instrumentMetadata (1, 1) mag.meta.Instrument
                primarySetup (1, 1) mag.meta.Setup
                secondarySetup (1, 1) mag.meta.Setup
            end

            data = readstruct(this.FileName, FileType = "json", AllowComments = true, AllowTrailingCommas = true);

            this.applyMetadata(instrumentMetadata, data.Instrument);
            this.applyMetadata(primarySetup, data.Primary);
            this.applyMetadata(secondarySetup, data.Secondary);
        end
    end

    methods (Access = private)

        function applyMetadata(this, metadata, data)

            fields = string(fieldnames(data))';

            for field = fields

                if ~isprop(metadata, field)
                    error("Invalid field ""%s"" in JSON file ""%s"".", field, this.FileName);
                end

                if isstruct(data.(field))
                    this.applyMetadata(metadata.(field), data.(field));
                else
                    metadata.(field) = data.(field);
                end
            end
        end
    end
end
