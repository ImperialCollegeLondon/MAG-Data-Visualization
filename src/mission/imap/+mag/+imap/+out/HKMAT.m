classdef HKMAT < mag.io.out.MAT
% HKMAT Format HK data for MAT export.

    methods

        function fileName = getExportFileName(this, data)

            arguments (Input)
                this (1, 1) mag.imap.out.HKMAT
                data (1, :) mag.HK
            end

            arguments (Output)
                fileName (1, 1) string
            end

            metaData = [data.MetaData];
            fileName = compose("%s HK", datestr(min([metaData.Timestamp]), "ddmmyy-hhMM")) + this.Extension; %#ok<DATST>
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

            exportData = this.addHKData(exportData, data.getHKType("PW"), "PWR");
            exportData = this.addHKData(exportData, data.getHKType("SID15"), "SID15");
            exportData = this.addHKData(exportData, data.getHKType("STATUS"), "STATUS");
            exportData = this.addHKData(exportData, data.getHKType("PROCSTAT"), "PROCSTAT");
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
