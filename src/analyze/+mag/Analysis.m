classdef (Abstract) Analysis < matlab.mixin.Copyable & mag.mixin.SetGet & mag.mixin.SaveLoad
% ANALYSIS Abstract base class for mission data analysis.

    properties
        % LOCATION Location of data to load.
        Location (1, 1) string {mustBeFolder} = pwd()
        % PROCESSING Processing steps for each phase.
        Processing (1, 1) mag.Processing
        % HEALTHCHECKS Health checks to perform on results.
        HealthChecks (1, :) mag.health.Check = mag.health.Check.empty()
    end

    properties (SetAccess = protected)
        % RESULTS Results collected during analysis.
        Results mag.Instrument {mustBeScalarOrEmpty}
    end

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

    methods

        function check(this)
        % CHECK Check health of results.

            assert(~isempty(this.Results), "Results must be loaded first.");

            if isempty(this.HealthChecks)
                return;
            end

            this.HealthChecks.runAll(this.Results);
            results = [this.HealthChecks.Results];

            if ~isempty(results)
                results.print();
            end
        end
    end
end
