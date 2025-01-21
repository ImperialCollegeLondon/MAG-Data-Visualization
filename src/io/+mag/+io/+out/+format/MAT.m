classdef MAT < mag.io.out.format.SimpleProvider
% MAT Interface for MAT export format providers.

    properties (Constant)
        Writer = mag.io.out.write.MAT()
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
