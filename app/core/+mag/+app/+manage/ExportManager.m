classdef ExportManager < mag.app.manage.Manager & mag.app.mixin.StartEndDate
% EXPORTMANAGER Manager for export components. If the mission supports
% export formats, the start and end times of the export can be selected.

    properties (SetAccess = immutable)
        % MISSION Mission to export.
        Mission (1, 1) mag.meta.Mission
        % SUPPORTEDFORMATS Supported export formats.
        SupportedFormats (1, :) string
    end

    properties (SetAccess = private)
        ExportSettingsLayout matlab.ui.container.GridLayout
    end

    methods

        function this = ExportManager(mission, supportedFormats)

            arguments
                mission (1, 1) mag.meta.Mission
                supportedFormats (1, :) string = string.empty()
            end

            this.Mission = mission;
            this.SupportedFormats = supportedFormats;
        end

        function instantiate(this, parent)

            % Create ExportSettingsLayout.
            this.ExportSettingsLayout = uigridlayout(parent);

            if isempty(this.SupportedFormats)

                this.ExportSettingsLayout.ColumnWidth = "1x";
                this.ExportSettingsLayout.RowHeight = ["1x", "1x"];

                uilabel(this.ExportSettingsLayout, Text = compose("No export options for %s yet.", this.Mission.DisplayName), ...
                    HorizontalAlignment = "center", VerticalAlignment = "center");
            else

                this.ExportSettingsLayout.ColumnWidth = ["1x", "1x", "1x"];
                this.ExportSettingsLayout.RowHeight = ["1x", "1x", "1x", "1x"];

                % Start and end dates.
                this.addStartEndDateButtons(this.ExportSettingsLayout);
            end

            % Reset.
            this.reset();
        end

        function reset(this)

            if ~isempty(this.Slider)
                this.resetStartEndDate();
            end
        end

        function options = getExportOptions(this, format, location)
        % GETEXPORTOPTIONS Get options to export analysis.

            if isempty(this.SupportedFormats)
                options = {};
            else

                format = extractBefore(format, " ");
                [startTime, endTime] = this.getStartEndTimes();

                options = {format, "Location", location, "StartTime", startTime, "EndTime", endTime};
            end
        end
    end

    methods (Access = protected)

        function modelChangedCallback(this, model, ~)

            if ~model.HasAnalysis || ~model.Analysis.Results.HasScience
                this.reset();
            elseif ~isempty(this.Slider)
                this.changeSliderLimits(model.TimeRange);
            end
        end
    end
end
