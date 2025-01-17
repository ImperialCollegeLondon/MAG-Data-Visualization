classdef (Abstract) MATWriter < mag.io.out.Format
% MATWRITER Interface for MAT export format writers.

    properties (Constant)
        Extension = ".mat"
    end

    properties
        % APPEND Append data to existing MAT file.
        Append (1, 1) logical = false
    end

    methods

        function write(this, fileName, exportData)

            arguments
                this (1, 1) mag.io.out.MAT
                fileName (1, 1) string
                exportData (1, 1) struct
            end

            if this.Append && isfile(fileName)
                extraOptions = {"-append"};
            else
                extraOptions = {};
            end

            save(fileName, "-struct", "exportData", "-mat", extraOptions{:});
        end
    end

    methods (Static, Access = protected)

        function structData = flattenStruct(data)
        % FLATTENSTRUCT Convert value to struct and flatten possible
        % sub-structs.

            arguments
                data (1, 1) mag.mixin.Struct
            end

            structData = struct(data);

            locStruct = structfun(@isstruct, structData);

            fields = string(fieldnames(structData)');
            fields = fields(locStruct);

            for f = fields

                subStruct = struct(structData.(f));
                structData = rmfield(structData, f);

                for n = string(fieldnames(subStruct)')
                    structData.(n) = subStruct.(n);
                end
            end
        end
    end
end
