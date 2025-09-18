classdef (Abstract) Check < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% CHECK Abstract base class for all health checks.

    properties (SetAccess = protected)
        % RESULTS Health check results.
        Results (1, :) mag.health.Result
    end

    methods (Sealed)

        function runAll(this, results)
        % RUNALL Run all checks.

            if isempty(this)
                return;
            end

            [this.Results] = deal(mag.health.Result.empty());
            arrayfun(@(c) c.run(results), this);
        end
    end

    methods (Abstract)

        % RUN Run checks on specified results.
        run(this, results)
    end
end
