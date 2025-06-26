classdef (Abstract) MAGChartTestCase < mag.test.case.GraphicsTestCase
% MAGCHARTTESTCASE Base class for all MAG chart tests.

    properties (Constant)
        % DATA Test data.
        Data timetable = timetable(datetime("now") + (1:10)', (1:10)', categorical(randi(3, [10, 1]) - 1), "a" + (1:10)', VariableNames = ["Number", "Categorical", "Letter"])
    end

    properties (Abstract, Constant)
        % CLASSNAME Fully qualified name of class under test.
        ClassName
        % GRAPHCLASSNAME Fully qualified name of graph generated.
        GraphClassName
    end

    methods (Access = protected)

        function args = getExtraArguments(~)
        % GETEXTRAARGUMENTS Retrieve extra arguments needed to construct a
        % chart. Can be overridden by subclasses for customization.

            args = {"YVariables", "Number"};
        end
    end
end
