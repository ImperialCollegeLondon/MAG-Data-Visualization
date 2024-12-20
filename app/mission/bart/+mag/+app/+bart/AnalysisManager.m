classdef AnalysisManager < mag.app.manage.AnalysisManager
% ANALYSISMANAGER Manager for analysis of HelioSwarm data.

    properties (SetAccess = private)
        AnalyzeSettingsLayout matlab.ui.container.GridLayout
        LocationEditField matlab.ui.control.EditField
        LocationEditFieldLabel matlab.ui.control.Label
        BrowseButton matlab.ui.control.Button
        Input1PatternEditField matlab.ui.control.EditField
        Input1PatternEditFieldLabel matlab.ui.control.Label
        Input2PatternEditField matlab.ui.control.EditField
        Input2PatternEditFieldLabel matlab.ui.control.Label
        GradiometerCheckBox matlab.ui.control.CheckBox
    end

    methods

        function instantiate(this, parent)

            % Create AnalyzeSettingsLayout.
            this.AnalyzeSettingsLayout = uigridlayout(parent);
            this.AnalyzeSettingsLayout.ColumnWidth = ["fit", "1x", "fit"];
            this.AnalyzeSettingsLayout.RowHeight = ["1x", "1x", "1x", "1x", "1x", "1x"];

            % Create LocationEditFieldLabel.
            this.LocationEditFieldLabel = uilabel(this.AnalyzeSettingsLayout);
            this.LocationEditFieldLabel.HorizontalAlignment = "right";
            this.LocationEditFieldLabel.Layout.Row = 1;
            this.LocationEditFieldLabel.Layout.Column = 1;
            this.LocationEditFieldLabel.Text = "Location:";

            % Create LocationEditField.
            this.LocationEditField = uieditfield(this.AnalyzeSettingsLayout, "text");
            this.LocationEditField.Layout.Row = 1;
            this.LocationEditField.Layout.Column = 2;

            % Create BrowseButton.
            this.BrowseButton = uibutton(this.AnalyzeSettingsLayout, "push");
            this.BrowseButton.ButtonPushedFcn = @(~, ~) this.browseButtonPushed();
            this.BrowseButton.Layout.Row = 1;
            this.BrowseButton.Layout.Column = 3;
            this.BrowseButton.Text = "Browse";

            % Create Input1PatternEditFieldLabel.
            this.Input1PatternEditFieldLabel = uilabel(this.AnalyzeSettingsLayout);
            this.Input1PatternEditFieldLabel.HorizontalAlignment = "right";
            this.Input1PatternEditFieldLabel.Layout.Row = 2;
            this.Input1PatternEditFieldLabel.Layout.Column = 1;
            this.Input1PatternEditFieldLabel.Text = "Input 1 pattern:";

            % Create Input1PatternEditField.
            this.Input1PatternEditField = uieditfield(this.AnalyzeSettingsLayout, "text");
            this.Input1PatternEditField.Layout.Row = 2;
            this.Input1PatternEditField.Layout.Column = [2, 3];

            % Create Input2PatternEditFieldLabel.
            this.Input2PatternEditFieldLabel = uilabel(this.AnalyzeSettingsLayout);
            this.Input2PatternEditFieldLabel.HorizontalAlignment = "right";
            this.Input2PatternEditFieldLabel.Layout.Row = 3;
            this.Input2PatternEditFieldLabel.Layout.Column = 1;
            this.Input2PatternEditFieldLabel.Text = "Input 2 pattern:";

            % Create Input2PatternEditField.
            this.Input2PatternEditField = uieditfield(this.AnalyzeSettingsLayout, "text");
            this.Input2PatternEditField.Layout.Row = 3;
            this.Input2PatternEditField.Layout.Column = 2;

            % Create GradiometerCheckBox.
            this.GradiometerCheckBox = uicheckbox(this.AnalyzeSettingsLayout);
            this.GradiometerCheckBox.Layout.Row = 3;
            this.GradiometerCheckBox.Layout.Column = 3;
            this.GradiometerCheckBox.Text = "Gradiometer";

            % Reset.
            this.reset();
        end

        function reset(this)

            dummyAnalysis = mag.bart.Analysis();

            this.LocationEditField.Value = string.empty();
            this.Input1PatternEditField.Value = dummyAnalysis.Input1Pattern;
            this.Input2PatternEditField.Value = dummyAnalysis.Input2Pattern;
            this.GradiometerCheckBox.Value = dummyAnalysis.Gradiometer;
        end

        function options = getAnalysisOptions(this)

            % Validate location.
            location = this.LocationEditField.Value;

            if isempty(location)
                error("Location is empty.");
            elseif ~isfolder(location)
                error("Location ""%s"" does not exist.", location);
            end

            options = {"Location", this.LocationEditField.Value, ...
                "Input1Pattern", this.Input1PatternEditField.Value, ...
                "Input2Pattern", this.Input2PatternEditField.Value, ...
                "Gradiometer", this.GradiometerCheckBox.Value};
        end
    end

    methods (Access = protected)

        function modelChangedCallback(~, ~, ~)
            % do nothing
        end
    end

    methods (Access = private)

        function browseButtonPushed(this)

            location = uigetdir(this.LocationEditField.Value, "Select Data Root");

            if ~isequal(location, 0)
                this.LocationEditField.Value = location;
            end
        end
    end
end
