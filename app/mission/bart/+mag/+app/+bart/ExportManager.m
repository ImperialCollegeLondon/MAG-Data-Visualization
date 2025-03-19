classdef ExportManager < mag.app.manage.ExportManager & mag.app.mixin.StartEndDate
% EXPORTMANAGER Manager for export of Bartington analysis.

    properties (Constant)
        SupportedFormats = string.empty()
    end

    properties (SetAccess = private)
        ExportSettingsLayout matlab.ui.container.GridLayout
    end

    methods

        function instantiate(this, parent)

            % Create ExportSettingsLayout.
            this.ExportSettingsLayout = uigridlayout(parent);
            this.ExportSettingsLayout.ColumnWidth = "1x";
            this.ExportSettingsLayout.RowHeight = ["1x", "1x"];

            uilabel(this.ExportSettingsLayout, Text = "No export options for Bartington yet.", HorizontalAlignment = "center", VerticalAlignment = "center");

            % Reset.
            this.reset();
        end

        function reset(this) %#ok<MANU>
            % nothing to do
        end

        function options = getExportOptions(this, format, location) %#ok<INUSD>
            options = {};
        end
    end

    methods (Access = protected)

        function modelChangedCallback(this, model, ~)

            if ~model.HasAnalysis || ~model.Analysis.Results.HasScience
                this.reset();
            end
        end
    end
end
