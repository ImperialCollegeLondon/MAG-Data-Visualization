classdef AnalysisManager < mag.app.manage.AnalysisManager
% ANALYSISMANAGER Manager for analysis of HelioSwarm data.

    properties (SetAccess = private)
        HKPatternEditField matlab.ui.control.EditField
        HKPatternEditFieldLabel matlab.ui.control.Label
        DecodeBinaryFilesCheckBox matlab.ui.control.CheckBox
        ScaleFactorsTableLabel matlab.ui.control.Label
        ScaleFactorsTable matlab.ui.control.Table
    end

    methods

        function this = AnalysisManager()

            this@mag.app.manage.AnalysisManager(mag.meta.Mission.HelioSwarm);
            this.RowHeight = ["1x", "fit", "1x", "1x", "fit", "4x"];
        end
    end

    methods (Access = protected)

        function instantiateSettings(this, layout)

            % Create DecodeBinaryFilesCheckBox.
            this.DecodeBinaryFilesCheckBox = uicheckbox(layout, Text = "Decode binary files", Value = true);
            this.DecodeBinaryFilesCheckBox.Layout.Row = 2;
            this.DecodeBinaryFilesCheckBox.Layout.Column = [2, 3];

            % Create SciencePatternEditFieldLabel.
            this.SciencePatternEditFieldLabel = uilabel(layout);
            this.SciencePatternEditFieldLabel.HorizontalAlignment = "right";
            this.SciencePatternEditFieldLabel.Layout.Row = 3;
            this.SciencePatternEditFieldLabel.Layout.Column = 1;
            this.SciencePatternEditFieldLabel.Text = "Science pattern:";

            % Create SciencePatternEditField.
            this.SciencePatternEditField = uieditfield(layout, "text");
            this.SciencePatternEditField.Layout.Row = 3;
            this.SciencePatternEditField.Layout.Column = [2, 3];

            % Create HKPatternEditFieldLabel.
            this.HKPatternEditFieldLabel = uilabel(layout);
            this.HKPatternEditFieldLabel.HorizontalAlignment = "right";
            this.HKPatternEditFieldLabel.Layout.Row = 4;
            this.HKPatternEditFieldLabel.Layout.Column = 1;
            this.HKPatternEditFieldLabel.Text = "HK pattern:";

            % Create HKPatternEditField.
            this.HKPatternEditField = uieditfield(layout, "text");
            this.HKPatternEditField.Layout.Row = 4;
            this.HKPatternEditField.Layout.Column = [2, 3];

            % Create ScaleFactorsTableLabel.
            this.ScaleFactorsTableLabel = uilabel(layout);
            this.ScaleFactorsTableLabel.Layout.Row = 5;
            this.ScaleFactorsTableLabel.Layout.Column = [1, 3];
            this.ScaleFactorsTableLabel.Text = "Scale factors which will be used to convert raw science data to nT:";

            % Create ScaleFactorsTable.
            this.ScaleFactorsTable = uitable(layout);
            this.ScaleFactorsTable.ColumnName = compose("Range %d", 0:3);
            this.ScaleFactorsTable.RowName = ["X", "Y", "Z"];
            this.ScaleFactorsTable.ColumnFormat = repmat({'char'}, 1, 4);
            this.ScaleFactorsTable.ColumnEditable = true(1, 4);
            this.ScaleFactorsTable.Layout.Row = 6;
            this.ScaleFactorsTable.Layout.Column = [1, 3];
        end

        function resetSettings(this, defaultAnalysis)

            this.SciencePatternEditField.Value = defaultAnalysis.SciencePattern;
            this.HKPatternEditField.Value = join(defaultAnalysis.HKPattern, pathsep());
            this.DecodeBinaryFilesCheckBox.Value = true;
            this.ScaleFactorsTable.Data = this.formatScaleFactorsData(mag.hs.Analysis.getCompleteScaleFactors());
        end

        function options = getSettingsOptions(this)

            scaleFactors = this.parseScaleFactorsData(this.ScaleFactorsTable.Data);

            options = {"SciencePattern", this.SciencePatternEditField.Value, ...
                "HKPattern", this.HKPatternEditField.Value, ...
                "DecodeBinaryFiles", this.DecodeBinaryFilesCheckBox.Value, ...
                "ScaleFactors", scaleFactors};
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
