classdef ResultsManager < mag.app.Manager
% RESULTSMANAGER Manager for results of IMAP analysis.

    properties (SetAccess = private)
        ResultsLayout matlab.ui.container.GridLayout
        MetaDataPanel matlab.ui.container.Panel
        MetaDataLayout matlab.ui.container.GridLayout
        InstrumentTextArea matlab.ui.control.TextArea
        PrimaryTextArea matlab.ui.control.TextArea
        SecondaryTextArea matlab.ui.control.TextArea
    end

    methods

        function instantiate(this, parent)

            % Create ResultsLayout.
            this.ResultsLayout = uigridlayout(parent);
            this.ResultsLayout.ColumnWidth = "1x";
            this.ResultsLayout.RowHeight = ["1x", "3x"];

            % Create MetaDataPanel.
            this.MetaDataPanel = uipanel(this.ResultsLayout);
            this.MetaDataPanel.Enable = "off";
            this.MetaDataPanel.Title = "Meta Data";
            this.MetaDataPanel.Layout.Row = 1;
            this.MetaDataPanel.Layout.Column = 1;

            % Create MetaDataLayout.
            this.MetaDataLayout = uigridlayout(this.MetaDataPanel);
            this.MetaDataLayout.ColumnWidth = ["1x", "1x", "1x"];
            this.MetaDataLayout.RowHeight = "1x";

            % Create InstrumentTextArea.
            this.InstrumentTextArea = uitextarea(this.MetaDataLayout);
            this.InstrumentTextArea.Editable = "off";
            this.InstrumentTextArea.Tooltip = "Instrument Meta Data";
            this.InstrumentTextArea.Placeholder = "Instrument...";
            this.InstrumentTextArea.Layout.Row = 1;
            this.InstrumentTextArea.Layout.Column = 1;

            % Create PrimaryTextArea.
            this.PrimaryTextArea = uitextarea(this.MetaDataLayout);
            this.PrimaryTextArea.Editable = "off";
            this.PrimaryTextArea.Tooltip = "Primary Sensor Meta Data";
            this.PrimaryTextArea.Placeholder = "Primary Sensor...";
            this.PrimaryTextArea.Layout.Row = 1;
            this.PrimaryTextArea.Layout.Column = 2;

            % Create SecondaryTextArea.
            this.SecondaryTextArea = uitextarea(this.MetaDataLayout);
            this.SecondaryTextArea.Editable = "off";
            this.SecondaryTextArea.Tooltip = "Secondary Sensor Meta Data";
            this.SecondaryTextArea.Placeholder = "Secondary Sensor...";
            this.SecondaryTextArea.Layout.Row = 1;
            this.SecondaryTextArea.Layout.Column = 3;
        end

        function reset(this)

            this.MetaDataPanel.Enable = "off";

            this.InstrumentTextArea.Value = char.empty();
            this.PrimaryTextArea.Value = char.empty();
            this.SecondaryTextArea.Value = char.empty();
        end
    end

    methods (Access = protected)

        function modelChangedCallback(this, model, ~)

            if model.HasAnalysis && model.Analysis.Results.HasScience

                results = model.Analysis.Results;

                instrumentMetaData = compose("%s - BSW: %s - ASW: %s", results.MetaData.Model, results.MetaData.BSW, results.MetaData.ASW);
                primaryMetaData = compose("%s (%s - %s - %s)", results.Primary.MetaData.getDisplay("Sensor"), results.Primary.MetaData.Setup.FEE, results.Primary.MetaData.Setup.Model, results.Primary.MetaData.Setup.Can);
                secondaryMetaData = compose("%s (%s - %s - %s)", results.Secondary.MetaData.getDisplay("Sensor"), results.Secondary.MetaData.Setup.FEE, results.Secondary.MetaData.Setup.Model, results.Secondary.MetaData.Setup.Can);

                if ~isempty(instrumentMetaData)
                    this.InstrumentTextArea.Value = instrumentMetaData;
                end

                if ~isempty(primaryMetaData)
                    this.PrimaryTextArea.Value = primaryMetaData;
                end

                if ~isempty(secondaryMetaData)
                    this.SecondaryTextArea.Value = secondaryMetaData;
                end

                this.MetaDataPanel.Enable = "on";
            else
                this.reset();
            end
        end
    end
end
