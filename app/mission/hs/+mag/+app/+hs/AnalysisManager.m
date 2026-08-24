classdef AnalysisManager < mag.app.manage.AnalysisManager
% ANALYSISMANAGER Manager for analysis of HelioSwarm data.

    properties (SetAccess = private)
        AnalyzeSettingsLayout matlab.ui.container.GridLayout
        LocationEditField matlab.ui.control.EditField
        LocationEditFieldLabel matlab.ui.control.Label
        BrowseButton matlab.ui.control.Button
        MetadataPatternEditField matlab.ui.control.EditField
        MetadataPatternEditFieldLabel matlab.ui.control.Label
        SciencePatternEditField matlab.ui.control.EditField
        SciencePatternEditFieldLabel matlab.ui.control.Label
        HKPatternEditField matlab.ui.control.EditField
        HKPatternEditFieldLabel matlab.ui.control.Label
        DecodeBinaryFilesCheckBox matlab.ui.control.CheckBox
        ScaleFactorsTableLabel matlab.ui.control.Label
        ScaleFactorsTable matlab.ui.control.Table
    end

    methods

        function instantiate(this, parent)

            % Create AnalyzeSettingsLayout.
            this.AnalyzeSettingsLayout = uigridlayout(parent);
            this.AnalyzeSettingsLayout.ColumnWidth = ["fit", "1x", "fit"];
            this.AnalyzeSettingsLayout.RowHeight = ["1x", "fit", "1x", "1x", "1x", "fit", "4x"];

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

            % Create DecodeBinaryFilesCheckBox.
            this.DecodeBinaryFilesCheckBox = uicheckbox(this.AnalyzeSettingsLayout, Text = "Decode binary files", Value = true);
            this.DecodeBinaryFilesCheckBox.Layout.Row = 2;
            this.DecodeBinaryFilesCheckBox.Layout.Column = [2, 3];

            % Create MetadataPatternEditFieldLabel.
            this.MetadataPatternEditFieldLabel = uilabel(this.AnalyzeSettingsLayout);
            this.MetadataPatternEditFieldLabel.HorizontalAlignment = "right";
            this.MetadataPatternEditFieldLabel.Layout.Row = 3;
            this.MetadataPatternEditFieldLabel.Layout.Column = 1;
            this.MetadataPatternEditFieldLabel.Text = "Metadata pattern:";

            % Create MetadataPatternEditField.
            this.MetadataPatternEditField = uieditfield(this.AnalyzeSettingsLayout, "text", Enable = "off");
            this.MetadataPatternEditField.Layout.Row = 3;
            this.MetadataPatternEditField.Layout.Column = [2, 3];
            this.MetadataPatternEditField.Placeholder = "Not supported for HelioSwarm yet";

            % Create SciencePatternEditFieldLabel.
            this.SciencePatternEditFieldLabel = uilabel(this.AnalyzeSettingsLayout);
            this.SciencePatternEditFieldLabel.HorizontalAlignment = "right";
            this.SciencePatternEditFieldLabel.Layout.Row = 4;
            this.SciencePatternEditFieldLabel.Layout.Column = 1;
            this.SciencePatternEditFieldLabel.Text = "Science pattern:";

            % Create SciencePatternEditField.
            this.SciencePatternEditField = uieditfield(this.AnalyzeSettingsLayout, "text");
            this.SciencePatternEditField.Layout.Row = 4;
            this.SciencePatternEditField.Layout.Column = [2, 3];

            % Create HKPatternEditFieldLabel.
            this.HKPatternEditFieldLabel = uilabel(this.AnalyzeSettingsLayout);
            this.HKPatternEditFieldLabel.HorizontalAlignment = "right";
            this.HKPatternEditFieldLabel.Layout.Row = 5;
            this.HKPatternEditFieldLabel.Layout.Column = 1;
            this.HKPatternEditFieldLabel.Text = "HK pattern:";

            % Create HKPatternEditField.
            this.HKPatternEditField = uieditfield(this.AnalyzeSettingsLayout, "text");
            this.HKPatternEditField.Layout.Row = 5;
            this.HKPatternEditField.Layout.Column = [2, 3];

            % Create ScaleFactorsTableLabel.
            this.ScaleFactorsTableLabel = uilabel(this.AnalyzeSettingsLayout);
            this.ScaleFactorsTableLabel.Layout.Row = 6;
            this.ScaleFactorsTableLabel.Layout.Column = [1, 3];
            this.ScaleFactorsTableLabel.Text = "Scale factors which will be used to convert raw science data to nT:";

            % Create ScaleFactorsTable.
            this.ScaleFactorsTable = uitable(this.AnalyzeSettingsLayout);
            this.ScaleFactorsTable.ColumnName = compose("Range %d", 0:3);
            this.ScaleFactorsTable.RowName = ["X", "Y", "Z"];
            this.ScaleFactorsTable.ColumnFormat = repmat({'char'}, 1, 4);
            this.ScaleFactorsTable.ColumnEditable = true(1, 4);
            this.ScaleFactorsTable.Layout.Row = 7;
            this.ScaleFactorsTable.Layout.Column = [1, 3];

            % Reset.
            this.reset();
        end

        function reset(this)

            dummyAnalysis = mag.hs.Analysis();

            this.LocationEditField.Value = string.empty();
            this.MetadataPatternEditField.Value = join(dummyAnalysis.MetadataPattern, pathsep());
            this.SciencePatternEditField.Value = dummyAnalysis.SciencePattern;
            this.HKPatternEditField.Value = join(dummyAnalysis.HKPattern, pathsep());
            this.DecodeBinaryFilesCheckBox.Value = true;
            this.ScaleFactorsTable.Data = this.formatScaleFactorsData(mag.hs.Analysis.getCompleteScaleFactors());
        end

        function options = getAnalysisOptions(this)

            % Validate location.
            location = this.LocationEditField.Value;

            if isempty(location)
                error("mag:app:EmptyLocation", "Location is empty.");
            elseif ~isfolder(location)
                error("mag:app:NonexistentLocation", "Location ""%s"" does not exist.", location);
            end

            % Retrieve data file patterns.
            if isempty(this.MetadataPatternEditField.Value)
                metadataPattern = string.empty();
            else
                metadataPattern = split(this.MetadataPatternEditField.Value, pathsep())';
            end

            scaleFactors = this.parseScaleFactorsData(this.ScaleFactorsTable.Data);

            options = {"Location", this.LocationEditField.Value, ...
                "InputSource", mag.hs.meta.InputSource.iDPU, ...
                "MetadataPattern", metadataPattern, ...
                "SciencePattern", this.SciencePatternEditField.Value, ...
                "HKPattern", this.HKPatternEditField.Value, ...
                "DecodeBinaryFiles", this.DecodeBinaryFilesCheckBox.Value, ...
                "ScaleFactors", scaleFactors};
        end
    end

    methods (Access = protected)

        function modelChangedCallback(~, ~, ~)
            % do nothing
        end
    end

    methods (Access = private)

        function formattedData = formatScaleFactorsData(~, scaleFactors)

            formattedData = strings(size(scaleFactors));

            for idx = 1:numel(scaleFactors)

                fixedDisplay = sprintf("%.4f", scaleFactors(idx));
                if scaleFactors(idx) ~= 0 && mag.app.hs.AnalysisManager.countSignificantDigits(fixedDisplay) < 3
                    formattedData(idx) = sprintf("%.6e", scaleFactors(idx));
                else
                    formattedData(idx) = fixedDisplay;
                end
            end
        end

        function browseButtonPushed(this)

            location = uigetdir(this.LocationEditField.Value, "Select Data Root");

            if ~isequal(location, 0)
                this.LocationEditField.Value = location;
            end

            this.LocationEditField.focus();
        end

        function scaleFactors = parseScaleFactorsData(~, data)

            if isnumeric(data)
                scaleFactors = double(data);
            elseif iscell(data)
                scaleFactors = str2double(string(data));
            else
                scaleFactors = str2double(string(data));
            end

            if ~isequal(size(scaleFactors), [3, 4])
                error("mag:app:hs:InvalidScaleFactorsSize", "Scale factors must be a 3x4 matrix.");
            end

            if any(isnan(scaleFactors), "all")
                error("mag:app:hs:InvalidScaleFactorsNaN", "Scale factors must be valid numeric values.");
            end

            if any(~isfinite(scaleFactors), "all")
                error("mag:app:hs:InvalidScaleFactorsFinite", "Scale factors must be finite values.");
            end

            if any(scaleFactors <= 0, "all")
                error("mag:app:hs:InvalidScaleFactorsPositive", "Scale factors must be positive values.");
            end
        end
    end

    methods (Static, Access = private)

        function numSignificantDigits = countSignificantDigits(value)

            digitsOnly = regexprep(value, "[-+.]", "");
            digitsOnly = regexprep(digitsOnly, "^0+", "");
            numSignificantDigits = strlength(digitsOnly);
        end
    end
end
