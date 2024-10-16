classdef HKMAT < mag.io.out.MAT
% HKMAT Format HelioSwarm HK data for MAT export.

    methods

        function fileName = getExportFileName(this, data)

            arguments (Input)
                this (1, 1) mag.hs.out.HKMAT
                data (1, 1) mag.HK
            end

            arguments (Output)
                fileName (1, 1) string
            end

            metaData = [data.MetaData];
            fileName = compose("%s HK", datestr(min([metaData.Timestamp]), "ddmmyy-hhMM")) + this.Extension; %#ok<DATST>
        end

        function exportData = convertToExportFormat(~, data)

            arguments (Input)
                ~
                data (1, :) mag.HK
            end

            arguments (Output)
                exportData (1, 1) struct
            end

            exportData = struct();
            exportData.HK.Time = data.Time;

            for p = string(data.Data.Properties.VariableNames)
                exportData.HK.(p) = data.Data.(p);
            end
        end
    end
end
