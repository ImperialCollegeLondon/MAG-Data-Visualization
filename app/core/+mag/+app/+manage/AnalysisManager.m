classdef AnalysisManager < mag.app.manage.Manager
% ANALYSISMANAGER Manager for analysis components. Shows the location of
% the data to analyze and, by default, the pattern of science files.
% Subclasses can show other settings by overriding "instantiateSettings",
% "resetSettings" and "getSettingsOptions".

    properties (SetAccess = immutable)
        % MISSION Mission to analyze.
        Mission (1, 1) mag.meta.Mission
    end

    properties (SetAccess = private)
        AnalyzeSettingsLayout matlab.ui.container.GridLayout
        LocationEditField matlab.ui.control.EditField
        LocationEditFieldLabel matlab.ui.control.Label
        BrowseButton matlab.ui.control.Button
    end

    properties (SetAccess = protected)
        SciencePatternEditField matlab.ui.control.EditField
        SciencePatternEditFieldLabel matlab.ui.control.Label
    end

    properties (Access = protected)
        % ROWHEIGHT Height of rows of settings layout.
        RowHeight (1, :) string = ["1x", "1x", "1x", "1x", "1x", "1x"]
    end

    methods

        function this = AnalysisManager(mission)

            arguments
                mission (1, 1) mag.meta.Mission
            end

            this.Mission = mission;
        end

        function instantiate(this, parent)

            % Create AnalyzeSettingsLayout.
            this.AnalyzeSettingsLayout = uigridlayout(parent);
            this.AnalyzeSettingsLayout.ColumnWidth = ["fit", "1x", "fit"];
            this.AnalyzeSettingsLayout.RowHeight = this.RowHeight;

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

            % Create other settings.
            this.instantiateSettings(this.AnalyzeSettingsLayout);

            % Reset.
            this.reset();
        end

        function reset(this)

            this.LocationEditField.Value = string.empty();
            this.resetSettings(feval("mag." + this.Mission.PackageName + ".Analysis"));
        end

        function options = getAnalysisOptions(this)
        % GETANALYSISOPTIONS Get options to perform analysis.

            % Validate location.
            location = this.LocationEditField.Value;

            if isempty(location)
                error("mag:app:EmptyLocation", "Location is empty.");
            elseif ~isfolder(location)
                error("mag:app:NonexistentLocation", "Location ""%s"" does not exist.", location);
            end

            options = [{"Location", location}, this.getSettingsOptions()];
        end
    end

    methods (Access = protected)

        function instantiateSettings(this, layout)
        % INSTANTIATESETTINGS Create components for settings other than
        % location, from the second row of the layout.

            % Create SciencePatternEditFieldLabel.
            this.SciencePatternEditFieldLabel = uilabel(layout);
            this.SciencePatternEditFieldLabel.HorizontalAlignment = "right";
            this.SciencePatternEditFieldLabel.Layout.Row = 2;
            this.SciencePatternEditFieldLabel.Layout.Column = 1;
            this.SciencePatternEditFieldLabel.Text = "Science pattern:";

            % Create SciencePatternEditField.
            this.SciencePatternEditField = uieditfield(layout, "text");
            this.SciencePatternEditField.Layout.Row = 2;
            this.SciencePatternEditField.Layout.Column = [2, 3];
        end

        function resetSettings(this, defaultAnalysis)
        % RESETSETTINGS Reset settings other than location to the values
        % of a default analysis.
            this.SciencePatternEditField.Value = defaultAnalysis.SciencePattern;
        end

        function options = getSettingsOptions(this)
        % GETSETTINGSOPTIONS Get analysis options for settings other than
        % location.
            options = {"SciencePattern", this.SciencePatternEditField.Value};
        end

        function modelChangedCallback(~, ~, ~)
            % do nothing
        end
    end

    methods (Static, Access = protected)

        function patterns = splitPatterns(value)
        % SPLITPATTERNS Split patterns separated by the path separator.

            if isempty(value)
                patterns = string.empty();
            else
                patterns = split(value, pathsep())';
            end
        end
    end

    methods (Access = private)

        function browseButtonPushed(this)

            location = uigetdir(this.LocationEditField.Value, "Select Data Root");

            if ~isequal(location, 0)
                this.LocationEditField.Value = location;
            end

            this.LocationEditField.focus();
        end
    end
end
