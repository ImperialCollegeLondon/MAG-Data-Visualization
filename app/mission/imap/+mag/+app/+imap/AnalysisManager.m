classdef AnalysisManager < mag.app.manage.AnalysisManager
% ANALYSISMANAGER Manager for analysis of IMAP data.

    properties (SetAccess = private)
        LevelDropDown matlab.ui.control.DropDown
        MetadataPatternEditField matlab.ui.control.EditField
        MetadataPatternEditFieldLabel matlab.ui.control.Label
        EventPatternEditField matlab.ui.control.EditField
        EventPatternEditFieldLabel matlab.ui.control.Label
        IALiRTPatternEditField matlab.ui.control.EditField
        IALiRTPatternEditFieldLabel matlab.ui.control.Label
        HKPatternEditField matlab.ui.control.EditField
        HKPatternEditFieldLabel matlab.ui.control.Label
    end

    methods

        function this = AnalysisManager()

            this@mag.app.manage.AnalysisManager(mag.meta.Mission.IMAP);
            this.RowHeight = ["1x", "1x", "1x", "1x", "1x", "1x", "1x"];
        end
    end

    methods (Access = protected)

        function instantiateSettings(this, layout)

            % Create LevelDropDown.
            supportedLevels = [mag.imap.meta.Level.L1a, mag.imap.meta.Level.L1b];

            levelLabel = uilabel(layout, Text = "Level:", HorizontalAlignment = "right");
            levelLabel.Layout.Row = 2;
            levelLabel.Layout.Column = 1;

            this.LevelDropDown = uidropdown(layout, Tooltip = "Level L1b might require a change in the ""Science pattern"" setting (e.g., ""data/imap/mag/l1b/*/*/*.cdf"").");
            this.LevelDropDown.Items = string(supportedLevels);
            this.LevelDropDown.ItemsData = supportedLevels;
            this.LevelDropDown.Layout.Row = 2;
            this.LevelDropDown.Layout.Column = [2, 3];

            % Create EventPatternEditFieldLabel.
            this.EventPatternEditFieldLabel = uilabel(layout);
            this.EventPatternEditFieldLabel.HorizontalAlignment = "right";
            this.EventPatternEditFieldLabel.Layout.Row = 3;
            this.EventPatternEditFieldLabel.Layout.Column = 1;
            this.EventPatternEditFieldLabel.Text = "Event pattern:";

            % Create EventPatternEditField.
            this.EventPatternEditField = uieditfield(layout, "text");
            this.EventPatternEditField.Layout.Row = 3;
            this.EventPatternEditField.Layout.Column = [2, 3];

            % Create MetadataPatternEditFieldLabel.
            this.MetadataPatternEditFieldLabel = uilabel(layout);
            this.MetadataPatternEditFieldLabel.HorizontalAlignment = "right";
            this.MetadataPatternEditFieldLabel.Layout.Row = 4;
            this.MetadataPatternEditFieldLabel.Layout.Column = 1;
            this.MetadataPatternEditFieldLabel.Text = "Metadata pattern:";

            % Create MetadataPatternEditField.
            this.MetadataPatternEditField = uieditfield(layout, "text");
            this.MetadataPatternEditField.Layout.Row = 4;
            this.MetadataPatternEditField.Layout.Column = [2, 3];

            % Create SciencePatternEditFieldLabel.
            this.SciencePatternEditFieldLabel = uilabel(layout);
            this.SciencePatternEditFieldLabel.HorizontalAlignment = "right";
            this.SciencePatternEditFieldLabel.Layout.Row = 5;
            this.SciencePatternEditFieldLabel.Layout.Column = 1;
            this.SciencePatternEditFieldLabel.Text = "Science pattern:";

            % Create SciencePatternEditField.
            this.SciencePatternEditField = uieditfield(layout, "text");
            this.SciencePatternEditField.Layout.Row = 5;
            this.SciencePatternEditField.Layout.Column = [2, 3];

            % Create IALiRTPatternEditFieldLabel.
            this.IALiRTPatternEditFieldLabel = uilabel(layout);
            this.IALiRTPatternEditFieldLabel.HorizontalAlignment = "right";
            this.IALiRTPatternEditFieldLabel.Layout.Row = 6;
            this.IALiRTPatternEditFieldLabel.Layout.Column = 1;
            this.IALiRTPatternEditFieldLabel.Text = "I-ALiRT pattern:";

            % Create IALiRTPatternEditField.
            this.IALiRTPatternEditField = uieditfield(layout, "text");
            this.IALiRTPatternEditField.Layout.Row = 6;
            this.IALiRTPatternEditField.Layout.Column = [2, 3];

            % Create HKPatternEditFieldLabel.
            this.HKPatternEditFieldLabel = uilabel(layout);
            this.HKPatternEditFieldLabel.HorizontalAlignment = "right";
            this.HKPatternEditFieldLabel.Layout.Row = 7;
            this.HKPatternEditFieldLabel.Layout.Column = 1;
            this.HKPatternEditFieldLabel.Text = "HK pattern:";

            % Create HKPatternEditField.
            this.HKPatternEditField = uieditfield(layout, "text");
            this.HKPatternEditField.Layout.Row = 7;
            this.HKPatternEditField.Layout.Column = [2, 3];
        end

        function resetSettings(this, defaultAnalysis)

            this.LevelDropDown.ValueIndex = 1;
            this.EventPatternEditField.Value = join(defaultAnalysis.EventPattern, pathsep());
            this.MetadataPatternEditField.Value = join(defaultAnalysis.MetadataPattern, pathsep());
            this.SciencePatternEditField.Value = defaultAnalysis.SciencePattern;
            this.IALiRTPatternEditField.Value = defaultAnalysis.IALiRTPattern;
            this.HKPatternEditField.Value = join(defaultAnalysis.HKPattern, pathsep());
        end

        function options = getSettingsOptions(this)

            options = {"Level", this.LevelDropDown.Value, ...
                "EventPattern", this.splitPatterns(this.EventPatternEditField.Value), ...
                "MetadataPattern", this.splitPatterns(this.MetadataPatternEditField.Value), ...
                "SciencePattern", this.SciencePatternEditField.Value, ...
                "IALiRTPattern", this.IALiRTPatternEditField.Value, ...
                "HKPattern", this.splitPatterns(this.HKPatternEditField.Value)};
        end
    end
end
