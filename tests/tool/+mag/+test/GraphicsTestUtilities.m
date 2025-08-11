classdef GraphicsTestUtilities
% GRAPHICSTESTUTILITIES Utilities for graphics tests.

    methods (Static)

        function [tl, ax] = createFigure(testCase)
        % CREATEFIGURE Create figure axes for test.

            arguments
                testCase (1, 1) matlab.unittest.TestCase
            end

            f = figure(Visible = "off");
            testCase.addTeardown(@() close(f));

            tl = tiledlayout(f, "flow");
            ax = nexttile(tl);
        end


        function panel = createPanel(testCase, options)
        % CREATETESTPANEL Create "uipanel" to add test components to.

            arguments
                testCase
                options.VisibleOverride (1, 1) matlab.lang.OnOffSwitchState = "off"
            end

            f = uifigure(Visible = options.VisibleOverride);
            panel = uipanel(f, Position = [1, 1, f.InnerPosition(3:4)]);

            testCase.addTeardown(@() close(f));
        end

        function graph = getChildrenGraph(testCase, layout, axes, type)
        % GETCHILDRENGRAPH Get graph from axes and verify its type.

            arguments
                testCase (1, 1) matlab.unittest.TestCase
                layout (1, 1) matlab.graphics.layout.TiledChartLayout
                axes (1, 1) matlab.graphics.axis.Axes
                type (1, 1) string
            end

            if isvalid(axes)
                axes = unique([axes; mag.test.getAllAxes(layout)]);
            else
                axes = unique(mag.test.getAllAxes(layout));
            end

            graph = vertcat(axes.Children);

            testCase.assertNumElements(graph, 1, "One and only one graph should exist.");
            testCase.assertClass(graph, type, "Graph type should match expectation.");
        end

        function [name, value] = getVerifiables(properties)
        % GETVERIFIABLES Extract values to be used for verification
        % statement.

            arguments
                properties (1, 1) struct
            end

            if isfield(properties, "VerifiableName")
                name = properties.VerifiableName;
            else
                name = properties.Name;
            end

            if isfield(properties, "VerifiableValue")
                value = properties.VerifiableValue;
            else
                value = properties.Value;
            end
        end
    end
end
