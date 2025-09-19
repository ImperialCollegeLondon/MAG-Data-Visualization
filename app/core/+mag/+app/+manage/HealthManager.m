classdef HealthManager < mag.app.manage.Manager
% HEALTHMANAGER Manager for results components.

    properties (SetAccess = private)
        HealthLayout matlab.ui.container.GridLayout
        SummaryLayout matlab.ui.container.GridLayout
        SummaryLabel matlab.ui.control.Label
        SummaryLamp matlab.ui.control.Lamp
        IndividualPanel matlab.ui.container.Panel
        IndividualLayout matlab.ui.container.GridLayout
        IndividualTable matlab.ui.control.Table
        NoteLabel matlab.ui.control.Label
    end

    methods

        function instantiate(this, parent)

            this.HealthLayout = uigridlayout(parent);
            this.HealthLayout.ColumnWidth = "1x";
            this.HealthLayout.RowHeight = ["fit", "6x"];

            % Summary.
            this.SummaryLayout = uigridlayout(this.HealthLayout, Visible = "off");
            this.SummaryLayout.ColumnWidth = ["1x", "fit"];
            this.SummaryLayout.RowHeight = "1x";
            this.SummaryLayout.ColumnSpacing = 0;
            this.SummaryLayout.RowSpacing = 0;
            this.SummaryLayout.Layout.Row = 1;
            this.SummaryLayout.Layout.Column = 1;

            this.SummaryLabel = uilabel(this.SummaryLayout, Text = "");
            this.SummaryLabel.Layout.Row = 1;
            this.SummaryLabel.Layout.Column = 1;

            this.SummaryLamp = uilamp(this.SummaryLayout);
            this.SummaryLamp.Color = 0.25 * ones(1, 3);
            this.SummaryLamp.Layout.Row = 1;
            this.SummaryLamp.Layout.Column = 2;

            % Individual.
            this.IndividualPanel = uipanel(this.HealthLayout, Visible = "off");
            this.IndividualPanel.Title = "Checks";
            this.IndividualPanel.Layout.Row = 2;
            this.IndividualPanel.Layout.Column = 1;

            this.IndividualLayout = uigridlayout(this.IndividualPanel);
            this.IndividualLayout.ColumnWidth = "1x";
            this.IndividualLayout.RowHeight = "1x";
            this.IndividualLayout.ColumnSpacing = 0;
            this.IndividualLayout.RowSpacing = 0;
            this.IndividualLayout.Padding = [0, 0, 0, 0];

            this.IndividualTable = uitable(this.IndividualLayout);
            this.IndividualTable.Layout.Row = 1;
            this.IndividualTable.Layout.Column = 1;

            % Label.
            this.NoteLabel = uilabel(this.HealthLayout);
            this.NoteLabel.Text = "No health data available.";
            this.NoteLabel.HorizontalAlignment = "center";
            this.NoteLabel.Layout.Row = [1, 2];
            this.NoteLabel.Layout.Column = 1;
        end

        function reset(this)

            this.SummaryLayout.Visible = "off";
            this.IndividualPanel.Visible = "off";
            this.IndividualTable.Data = table();

            this.NoteLabel.Visible = "on";
        end
    end

    methods (Access = protected)

        function modelChangedCallback(this, model, ~)

            arguments
                this (1, 1) mag.app.manage.HealthManager
                model (1, 1) mag.app.Model
                ~
            end

            if model.HasAnalysis && ~isempty(model.Analysis.HealthChecks) && ~isempty([model.Analysis.HealthChecks.Results])

                checks = [model.Analysis.HealthChecks.Results];

                checkStatus = [checks.Status];
                worstStatus = checkStatus.getWorst();

                figure = ancestor(this.HealthLayout, "figure");

                % Add summary.
                this.SummaryLabel.Text = compose("Overall: %d/%d checks passed.", nnz(checkStatus == mag.health.Status.Pass), numel(checks));
                this.SummaryLamp.Color = worstStatus.getThemedColor(figure);
                this.SummaryLamp.Tooltip = string(worstStatus);

                % Add check results.
                data = table(vertcat(checks.Name), string(checkStatus'), vertcat(checks.Description), VariableNames = ["Name", "Status", "Description"]);

                this.IndividualTable.Data = data;
                this.IndividualTable.ColumnWidth = ["fit", "fit", "1x"];

                % Add style based on status.
                for s = unique(checkStatus)

                    idxStatus = find(data.Status == string(s));
                    idxStatus = [idxStatus, repmat(2, numel(idxStatus), 1)]; %#ok<AGROW>

                    style = uistyle(BackgroundColor = s.getThemedColor(figure));
                    this.IndividualTable.addStyle(style, "cell", idxStatus);
                end

                % Show results.
                this.SummaryLayout.Visible = "on";
                this.IndividualPanel.Visible = "on";
                this.NoteLabel.Visible = "off";
            else
                this.reset();
            end
        end
    end
end
