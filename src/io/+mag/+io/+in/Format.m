classdef (Abstract) Format < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% FORMAT Interface for data format providers for import.

    properties (Abstract, Constant)
        % EXTENSION Extension supported for file format.
        Extension (1, 1) string
    end

    methods (Abstract)

        % LOAD Load raw data from file.
        rawData = load(this, fileName)

        % PROCESS Process raw data and convert to common data
        % format.
        data = process(this, rawData, details)
    end
end
