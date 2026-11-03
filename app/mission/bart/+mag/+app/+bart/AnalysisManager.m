classdef AnalysisManager < mag.app.manage.AnalysisManager
% ANALYSISMANAGER Manager for analysis of Bartington data.

    properties (SetAccess = private)
        Input1PatternEditField matlab.ui.control.EditField
        Input1PatternEditFieldLabel matlab.ui.control.Label
        Input2PatternEditField matlab.ui.control.EditField
        Input2PatternEditFieldLabel matlab.ui.control.Label
        GradiometerCheckBox matlab.ui.control.CheckBox
    end

    methods

        function this = AnalysisManager()
            this@mag.app.manage.AnalysisManager(mag.meta.Mission.Bartington);
        end
    end

    methods (Access = protected)

        function instantiateSettings(this, layout)

            % Create Input1PatternEditFieldLabel.
            this.Input1PatternEditFieldLabel = uilabel(layout);
            this.Input1PatternEditFieldLabel.HorizontalAlignment = "right";
            this.Input1PatternEditFieldLabel.Layout.Row = 2;
            this.Input1PatternEditFieldLabel.Layout.Column = 1;
            this.Input1PatternEditFieldLabel.Text = "Input 1 pattern:";

            % Create Input1PatternEditField.
            this.Input1PatternEditField = uieditfield(layout, "text");
            this.Input1PatternEditField.Layout.Row = 2;
            this.Input1PatternEditField.Layout.Column = [2, 3];

            % Create Input2PatternEditFieldLabel.
            this.Input2PatternEditFieldLabel = uilabel(layout);
            this.Input2PatternEditFieldLabel.HorizontalAlignment = "right";
            this.Input2PatternEditFieldLabel.Layout.Row = 3;
            this.Input2PatternEditFieldLabel.Layout.Column = 1;
            this.Input2PatternEditFieldLabel.Text = "Input 2 pattern:";

            % Create Input2PatternEditField.
            this.Input2PatternEditField = uieditfield(layout, "text");
            this.Input2PatternEditField.Layout.Row = 3;
            this.Input2PatternEditField.Layout.Column = 2;

            % Create GradiometerCheckBox.
            this.GradiometerCheckBox = uicheckbox(layout);
            this.GradiometerCheckBox.Layout.Row = 3;
            this.GradiometerCheckBox.Layout.Column = 3;
            this.GradiometerCheckBox.Text = "Gradiometer";
        end

        function resetSettings(this, defaultAnalysis)

            this.Input1PatternEditField.Value = defaultAnalysis.Input1Pattern;
            this.Input2PatternEditField.Value = defaultAnalysis.Input2Pattern;
            this.GradiometerCheckBox.Value = defaultAnalysis.Gradiometer;
        end

        function options = getSettingsOptions(this)

            options = {"Input1Pattern", this.Input1PatternEditField.Value, ...
                "Input2Pattern", this.Input2PatternEditField.Value, ...
                "Gradiometer", this.GradiometerCheckBox.Value};
        end
    end
end
