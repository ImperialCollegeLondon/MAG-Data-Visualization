classdef (Abstract) GraphicsTestCase < matlab.unittest.TestCase
% GRAPHICSTESTCASE Base class for all MAG graphics tests.

    methods (TestClassSetup)

        % Disable visibility for figures while testing.
        function disableFigureVisibility(testCase)

            currentValue = get(groot(), "DefaultFigureVisible");
            testCase.addTeardown(@() set(groot(), DefaultFigureVisible = currentValue));

            set(groot(), DefaultFigureVisible = "off");
        end

        % Close all figures opened by test.
        function closeTestFigures(testCase)
            testCase.applyFixture(mag.test.fixture.CleanupFigures());
        end
    end
end
