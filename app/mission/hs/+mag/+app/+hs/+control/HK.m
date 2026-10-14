classdef HK < mag.app.Control & mag.app.mixin.StartEndDate
% HK View-controller for generating HelioSwarm housekeeping views.

    properties (Constant)
        Name = "HK"
    end

    properties (SetAccess = private)
        Layout matlab.ui.container.GridLayout
        FieldsLabel matlab.ui.control.Label
        FieldsPanel matlab.ui.container.Panel
        FieldCheckBoxes (1, :) matlab.ui.control.CheckBox = matlab.ui.control.CheckBox.empty()
        FieldNames (1, :) string = string.empty()
    end

    methods

        function instantiate(this, parent)

            this.Layout = this.createDefaultGridLayout(parent);
            this.Layout.RowHeight = ["2x", "4x", "fit", "4x", "4x"];

            % Start and end dates.
            this.addStartEndDateButtons(this.Layout, Limits = this.Model.HKTimeRange);

            % Available HK fields.
            this.FieldNames = this.getAvailableFields();

            this.FieldsLabel = uilabel(this.Layout, Text = "HK fields:");
            this.FieldsLabel.Layout.Row = 3;
            this.FieldsLabel.Layout.Column = [1, 3];

            this.FieldsPanel = uipanel(this.Layout, BorderType = "none", Scrollable = "on");
            this.FieldsPanel.Layout.Row = [4, 5];
            this.FieldsPanel.Layout.Column = [1, 3];

            numColumns = 3;
            numRows = max(1, ceil(numel(this.FieldNames) / numColumns));
            contentHeight = max(26 * numRows, 26);
            columnWidth = 190;
            xOffset = 10;
            yOffset = 4;

            this.FieldCheckBoxes = matlab.ui.control.CheckBox.empty();

            for fieldIdx = 1:numel(this.FieldNames)

                rowIdx = ceil(fieldIdx / numColumns);
                columnIdx = mod(fieldIdx - 1, numColumns) + 1;

                checkBox = uicheckbox(this.FieldsPanel, ...
                    Text = this.FieldNames(fieldIdx), ...
                    Value = false);
                checkBox.Position = [xOffset + (columnIdx - 1) * (columnWidth + 10), ...
                    contentHeight - rowIdx * 26 + yOffset, columnWidth, 22];

                this.FieldCheckBoxes(end + 1) = checkBox; %#ok<AGROW>
            end
        end

        function supported = isSupported(~, results)
            supported = results.HasHK && any(results.HK.isPlottable());
        end

        function command = getVisualizeCommand(this, results)

            arguments (Input)
                this
                results (1, 1) mag.Instrument
            end

            arguments (Output)
                command (1, 1) mag.app.Command
            end

            [startTime, endTime] = this.getStartEndTimes();
            results = mag.app.internal.cropResults(results, startTime, endTime);

            selectedFields = this.FieldNames(arrayfun(@(x) x.Value, this.FieldCheckBoxes));

            command = mag.app.Command(Functional = @(varargin) mag.hs.view.HK(varargin{:}).visualizeAll(), ...
                PositionalArguments = {results}, ...
                NamedArguments = struct(SelectedFields = selectedFields));
        end
    end

    methods (Access = private)

        function fieldNames = getAvailableFields(this)

            hk = this.Model.Analysis.Results.HK;
            hk = hk(find(~cellfun(@isempty, arrayfun(@(x) {x.Data}, hk)), 1, "first"));

            if isempty(hk)
                fieldNames = string.empty();
            else
                fieldNames = string(hk.Data.Properties.VariableNames);
            end
        end
    end
end