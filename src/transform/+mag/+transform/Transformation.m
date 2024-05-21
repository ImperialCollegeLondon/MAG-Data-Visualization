classdef (Abstract) Transformation < mag.mixin.SetGet
% TRANSFORMATION Abstract interface for all MAG transformations.

    methods (Abstract)

        % APPLY Apply transformation to data.
        transformedData = apply(this, originalData)
    end
end
