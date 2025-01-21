classdef (Abstract) Provider < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% PROVIDER Interface for data format providers for export.

    properties (Abstract, Constant)
        % WRITER Writer supported by provider.
        Writer (1, 1) mag.io.out.write.Writer
    end
end
