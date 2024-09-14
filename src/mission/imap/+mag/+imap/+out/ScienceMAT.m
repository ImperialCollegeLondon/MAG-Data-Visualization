classdef ScienceMAT < mag.io.out.MAT
% SCIENCEMAT Format science data for MAT export.

    methods

        function fileName = getExportFileName(this, data)

            arguments
                this (1, 1) mag.imap.out.ScienceMAT
                data (1, 1) {mustBeA(data, ["mag.Instrument", "mag.IALiRT"])}
            end

            if data.Primary.MetaData.Mode == mag.meta.Mode.IALiRT
                format = "%s %s (%.2f, %.2f)";
            else
                format = "%s %s (%d, %d)";
            end

            fileName = compose(format, datestr(data.Primary.MetaData.Timestamp, "ddmmyy-hhMM"), ...
                data.Primary.MetaData.Mode, data.Primary.MetaData.DataFrequency, data.Secondary.MetaData.DataFrequency) + this.Extension; %#ok<DATST>
        end

        function exportData = convertToExportFormat(this, data)

            arguments
                this (1, 1) mag.imap.out.ScienceMAT
                data (1, 1) {mustBeA(data, ["mag.Instrument", "mag.IALiRT"])}
            end

            exportData.B.P.Time = data.Primary.Time;
            exportData.B.P.Data = data.Primary.XYZ;
            exportData.B.P.Range = data.Primary.Range;
            exportData.B.P.Sequence = data.Primary.Sequence;
            exportData.B.P.Compression = data.Primary.Compression;
            exportData.B.P.Quality = categorical(string(data.Primary.Quality));
            exportData.B.P.MetaData = this.convertToStruct(data.Primary.MetaData);

            exportData.B.S.Time = data.Secondary.Time;
            exportData.B.S.Data = data.Secondary.XYZ;
            exportData.B.S.Range = data.Secondary.Range;
            exportData.B.S.Sequence = data.Secondary.Sequence;
            exportData.B.S.Compression = data.Secondary.Compression;
            exportData.B.S.Quality = categorical(string(data.Secondary.Quality));
            exportData.B.S.MetaData = this.convertToStruct(data.Secondary.MetaData);
        end
    end

    methods (Static, Access = private)

        function structMetaData = convertToStruct(metaData)
        % CONVERTTOSTRUCT Convert meta data to struct, and maintain
        % previous data format.

            structMetaData = struct(metaData);

            setupStruct = structMetaData.Setup;
            structMetaData = rmfield(structMetaData, "Setup");

            for f = fieldnames(setupStruct)'
                structMetaData.(f{:}) = setupStruct.(f{:});
            end
        end
    end
end
