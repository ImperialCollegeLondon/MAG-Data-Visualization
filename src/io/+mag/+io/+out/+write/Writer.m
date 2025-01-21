classdef (Abstract) Writer < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% FORMAT Interface for data writers for export.

    properties (Abstract, Constant)
        % EXTENSION Extension supported for file format.
        Extension (1, 1) string
    end

    methods (Abstract)

        % WRITE Export file to format.
        write(this, data, provider)
    end
end
