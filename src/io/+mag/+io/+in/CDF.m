classdef (Abstract) CDF < mag.io.in.Format
% CDF Interface for CDF input format providers.

    properties (Constant)
        Extension = ".cdf"
    end

    properties
        % KEEPEPOCHASIS Boolean denoting whether to keep CDF epoch data
        % values as is.
        KeepEpochAsIs (1, 1) logical = true
    end

    methods

        function [rawData, cdfInfo] = load(this, fileName)

            assert(exist("spdfcdfinfo", "file"), "SPDF CDF Toolbox needs to be installed.");

            cdfInfo = spdfcdfinfo(fileName);
            rawData = spdfcdfread(fileName, 'KeepEpochAsIs', this.KeepEpochAsIs);
        end
    end
end
