classdef CleanupParallelPool < matlab.unittest.fixtures.Fixture
% CLEANUPPARALLELPOOL Delete parallel pool started by a test, if any.

    properties (Access = private)
        % PRETESTPOOL Parallel pool running before test. Should not be
        % deleted by fixture.
        PreTestPool parallel.Pool {mustBeScalarOrEmpty}
    end

    methods

        function setup(fixture)

            if canUseParallelPool()
                fixture.PreTestPool = gcp("nocreate");
            end
        end

        function teardown(fixture)

            if ~canUseParallelPool()
                return;
            end

            postTestPool = gcp("nocreate");

            if ~isempty(postTestPool) && ~isequal(postTestPool, fixture.PreTestPool)
                delete(postTestPool);
            end
        end
    end

    methods (Access = protected)

        function bool = isCompatible(~, ~)
            bool = false;
        end
    end
end
