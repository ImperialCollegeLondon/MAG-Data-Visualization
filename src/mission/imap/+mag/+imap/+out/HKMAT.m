classdef HKMAT < mag.io.out.MAT
% HKMAT Format IMAP HK data for MAT export.

    methods

        function fileName = getExportFileName(this, data)

            arguments (Input)
                this (1, 1) mag.imap.out.HKMAT
                data (1, :) mag.HK
            end

            arguments (Output)
                fileName (1, 1) string
            end

            metadata = [data.Metadata];
            fileName = compose("%s HK", datestr(min([metadata.Timestamp]), "ddmmyy-hhMM")) + this.Extension; %#ok<DATST>
        end

        function exportData = convertToExportFormat(this, data)

            arguments (Input)
                this (1, 1) mag.imap.out.HKMAT
                data (1, :) mag.HK
            end

            arguments (Output)
                exportData (1, 1) struct
            end

            exportData = struct();

            exportData = this.addHKData(exportData, data.getHKType(mag.meta.HKType.Power), "PWR");
            exportData = this.addHKData(exportData, data.getHKType(mag.meta.HKType.SID15), "SID15");
            exportData = this.addHKData(exportData, data.getHKType(mag.meta.HKType.Status), "STATUS");
            exportData = this.addHKData(exportData, data.getHKType(mag.meta.HKType.Processor), "PROCSTAT");
        end
    end

    methods (Static, Access = private)

        function exportData = addHKData(exportData, data, matTypeName)

            arguments
                exportData (1, 1) struct
                data mag.HK {mustBeScalarOrEmpty}
                matTypeName (1, 1) string
            end

            if isempty(data)
                return;
            end

            exportData.HK.(matTypeName).Time = data.Time;

            for p = string(data.Data.Properties.VariableNames)

                if (~isequal(p, "t") && ~isequal(p, "timestamp"))
                    exportData.HK.(matTypeName).(p) = data.Data.(p);
                end
            end
        end
    end
end
