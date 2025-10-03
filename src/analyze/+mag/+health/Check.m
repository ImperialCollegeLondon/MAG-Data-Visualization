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

            for c = this(:)'

                if c.isSupported(results)
                    c.run(results);
                end
            end
        end
    end

    methods (Abstract)

        % ISSUPPORTED Determine whether results are supported.
        supported = isSupported(this, results)

        % RUN Run checks on specified results.
        run(this, results)
    end
end
