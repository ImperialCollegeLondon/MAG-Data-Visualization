classdef ExportManager < mag.app.manage.ExportManager & mag.app.mixin.StartEndDate
% EXPORTMANAGER Manager for export of IMAP analysis.

    properties (Constant)
        SupportedFormats = ["MAT (Science Lead)", "CDF"]
    end

    properties (SetAccess = private)
        ExportSettingsLayout matlab.ui.container.GridLayout
    end

    methods

        function instantiate(this, parent)

            % Create ExportSettingsLayout.
            this.ExportSettingsLayout = uigridlayout(parent);
            this.ExportSettingsLayout.ColumnWidth = ["1x", "2x", "2x"];
            this.ExportSettingsLayout.RowHeight = ["1x", "1x", "1x", "1x"];

            % Start and end dates.
            this.addStartEndDateButtons(this.ExportSettingsLayout, StartDateRow = 1, EndDateRow = 2);

            % Reset.
            this.reset();
        end

        function reset(this)
            this.resetStartEndDate();
        end

        function options = getExportOptions(this, format, location)

            format = extractBefore(format, " ");

            startTime = mag.app.internal.combineDateAndTime(this.StartDatePicker.Value, this.StartTimeField.Value);
            endTime = mag.app.internal.combineDateAndTime(this.EndDatePicker.Value, this.EndTimeField.Value);

            options = {format, "Location", location, "StartTime", startTime, "EndTime", endTime};
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
