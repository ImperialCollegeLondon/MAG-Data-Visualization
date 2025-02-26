classdef JSON < mag.imap.meta.Type
% JSON Load meta data from JSON files.

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

        function [instrumentMetaData, primarySetup, secondarySetup] = load(this, instrumentMetaData, primarySetup, secondarySetup)

            arguments
                this (1, 1) mag.imap.meta.JSON
                instrumentMetaData (1, 1) mag.meta.Instrument
                primarySetup (1, 1) mag.meta.Setup
                secondarySetup (1, 1) mag.meta.Setup
            end

            data = readstruct(this.FileName, FileType = "json", AllowComments = true, AllowTrailingCommas = true);

            this.applyMetaData(instrumentMetaData, data.Instrument);
            this.applyMetaData(primarySetup, data.Primary);
            this.applyMetaData(secondarySetup, data.Secondary);
        end
    end

    methods (Access = private)

        function applyMetaData(this, metaData, data)

            fields = string(fieldnames(data))';

            for field = fields

                if ~isprop(metaData, field)
                    error("Invalid field ""%s"" in JSON file ""%s"".", field, this.FileName);
                end

                if isstruct(data.(field))
                    this.applyMetaData(metaData.(field), data.(field));
                else
                    metaData.(field) = data.(field);
                end
            end
        end
    end
end
