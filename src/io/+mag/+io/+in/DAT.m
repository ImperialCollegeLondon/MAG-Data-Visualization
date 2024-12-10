classdef (Abstract) DAT < mag.io.in.Format
% DAT Interface for DAT input format providers.

    properties (Constant)
        Extension = ".Dat"
    end

    methods

        function [rawData, fileName] = load(~, fileName)
            rawData = readtable(fileName, VariableNamingRule = "preserve", TextType = "string");
        end
    end
end
