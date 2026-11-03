classdef ResultsManager < mag.app.manage.Manager
% RESULTSMANAGER Manager for results components. By default, shows a
% preview of the science data of the outboard and inboard sensors.

    properties (SetAccess = protected)
        ResultsLayout matlab.ui.container.GridLayout
        SciencePreviewPanel matlab.ui.container.Panel
        StackedChartPreview matlab.graphics.chart.StackedLineChart
    end

    properties (Access = protected)
        % SENSORNAMES Names of outboard and inboard sensors in preview.
        SensorNames (1, 2) string = ["Outboard", "Inboard"]
    end

    methods

        function instantiate(this, parent)

            % Create ResultsLayout.
            this.ResultsLayout = uigridlayout(parent);
            this.ResultsLayout.ColumnWidth = "1x";
            this.ResultsLayout.RowHeight = "1x";

            % Create science preview.
            this.instantiateSciencePreview(this.ResultsLayout);

            % Reset.
            this.reset();
        end

        function reset(this)
            this.resetSciencePreview();
        end
    end

    methods (Access = protected)

        function modelChangedCallback(this, model, ~)

            if model.HasAnalysis && model.Analysis.Results.HasScience
                this.plotPreview(model.Analysis.Results);
            else
                this.reset();
            end
        end

        function plotPreview(this, results)
        % PLOTPREVIEW Plot preview of results with science data.
            this.plotDualSensorPreview({results.Outboard, results.Inboard}, this.SensorNames);
        end

        function plotDualSensorPreview(this, sensors, names)
        % PLOTDUALSENSORPREVIEW Plot preview of the sensors that have data.

            arguments
                this (1, 1) mag.app.manage.ResultsManager
                sensors (1, 2) cell
                names (1, 2) string
            end

            hasData = cellfun(@(s) ~isempty(s) && s.HasData, sensors);

            if any(hasData)

                data = cellfun(@(s) s.Data, sensors(hasData), UniformOutput = false);
                this.plotSensorPreview(data{:}, LegendLabels = names(hasData));
            end
        end

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
