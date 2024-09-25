classdef (Abstract) Analysis < matlab.mixin.Copyable & mag.mixin.SetGet & mag.mixin.SaveLoad
% ANALYSIS Abstract base class for mission data analysis.

    methods (Abstract, Static)

        % START Start automated analysis with options.
        analysis = start(options)
    end

    methods (Abstract)

        % DETECT Detect files based on patterns.
        detect(this)

        % LOAD Load all data stored in selected location.
        load(this)

        % EXPORT Export data to specified format.
        export(this, exportType, options)
    end
end
