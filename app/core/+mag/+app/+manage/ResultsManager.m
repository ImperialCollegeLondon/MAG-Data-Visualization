classdef (Abstract) ResultsManager < mag.app.manage.Manager
% RESULTSMANAGER Manager for results components.

    properties (SetAccess = protected)
        SciencePreviewPanel matlab.ui.container.Panel
        StackedChartPreview matlab.graphics.chart.StackedLineChart
    end

    methods (Access = protected)

        function instantiateSciencePreview(this, parent, options)

            arguments
                this (1, 1) mag.app.manage.ResultsManager
                parent
                options.Row = 1
                options.Column = 1
            end

            this.SciencePreviewPanel = uipanel(parent);
            this.SciencePreviewPanel.Enable = "off";
            this.SciencePreviewPanel.Title = "Science Preview";
            this.SciencePreviewPanel.Layout.Row = options.Row;
            this.SciencePreviewPanel.Layout.Column = options.Column;
        end

        function resetSciencePreview(this)

            this.SciencePreviewPanel.Enable = "off";

            if ~isempty(this.StackedChartPreview)
                this.StackedChartPreview.delete();
            end
        end

        function plotSensorPreview(this, sensors, options)

            arguments
                this (1, 1) mag.app.manage.ResultsManager
            end

            arguments (Repeating)
                sensors timetable
            end

            arguments
                options.LegendLabels (1, :) string
            end

            this.SciencePreviewPanel.Enable = "on";

            this.StackedChartPreview = stackedplot(this.SciencePreviewPanel, sensors{:}, ["x", "y", "z"], EventsVisible = false);
            this.StackedChartPreview.LegendLabels = options.LegendLabels;
            this.StackedChartPreview.GridVisible = "on";
        end
    end
end
