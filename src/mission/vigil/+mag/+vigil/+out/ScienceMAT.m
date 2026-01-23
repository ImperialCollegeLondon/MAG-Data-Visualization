classdef ScienceMAT < mag.io.out.MAT
% SCIENCEMAT Format Vigil science data for MAT export.

    methods

        function fileName = getExportFileName(this, data)

            arguments (Input)
                this (1, 1) mag.vigil.out.ScienceMAT
                data (1, 1) mag.vigil.Instrument
            end

            arguments (Output)
                fileName (1, 1) string
            end

            % Determine timestamp and frequency from available data.
            if ~isempty(data.Outboard) && data.Outboard.HasData
                outboardFreq = data.Outboard.Metadata.DataFrequency;
            else
                outboardFreq = 0;
            end

            if ~isempty(data.Inboard) && data.Inboard.HasData
                inboardFreq = data.Inboard.Metadata.DataFrequency;
            else
                inboardFreq = 0;
            end

            % Determine timestamp and mode from available data.
            if ~isempty(data.Outboard) && data.Outboard.HasData

                timestamp = data.Outboard.Metadata.Timestamp;
                mode = data.Outboard.Metadata.Mode;
            else

                timestamp = data.Inboard.Metadata.Timestamp;
                mode = data.Inboard.Metadata.Mode;
            end

            fileName = compose("%s %s (%d, %d)", datestr(timestamp, "ddmmyy-hhMM"), ...
                mode, outboardFreq, inboardFreq) + this.Extension; %#ok<DATST>
        end

        function exportData = convertToExportFormat(this, data)

            arguments (Input)
                this (1, 1) mag.vigil.out.ScienceMAT
                data (1, 1) mag.vigil.Instrument
            end

            arguments (Output)
                exportData (1, 1) struct
            end

            exportData = struct();

            % Export outboard data.
            if ~isempty(data.Outboard) && data.Outboard.HasData

                exportData.B.FOB.Time = data.Outboard.Time;
                exportData.B.FOB.Data = data.Outboard.XYZ;
                exportData.B.FOB.Range = data.Outboard.Range;
                exportData.B.FOB.Metadata = this.flattenStruct(data.Outboard.Metadata);
            end

            % Export inboard data.
            if ~isempty(data.Inboard) && data.Inboard.HasData

                exportData.B.FIB.Time = data.Inboard.Time;
                exportData.B.FIB.Data = data.Inboard.XYZ;
                exportData.B.FIB.Range = data.Inboard.Range;
                exportData.B.FIB.Metadata = this.flattenStruct(data.Inboard.Metadata);
            end
        end
    end
end
