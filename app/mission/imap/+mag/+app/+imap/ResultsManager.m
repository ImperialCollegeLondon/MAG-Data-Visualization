classdef ResultsManager < mag.app.manage.ResultsManager
% RESULTSMANAGER Manager for results of IMAP analysis.

    properties (SetAccess = private)
        ResultsLayout matlab.ui.container.GridLayout
        MetadataPanel matlab.ui.container.Panel
        MetadataLayout matlab.ui.container.GridLayout
        InstrumentTextArea matlab.ui.control.TextArea
        PrimaryTextArea matlab.ui.control.TextArea
        SecondaryTextArea matlab.ui.control.TextArea
    end

    methods

        function instantiate(this, parent)

            % Create layout.
            this.ResultsLayout = uigridlayout(parent);
            this.ResultsLayout.ColumnWidth = "1x";
            this.ResultsLayout.RowHeight = ["1x", "4.5x"];

            % Create metadata.
            this.MetadataPanel = uipanel(this.ResultsLayout);
            this.MetadataPanel.Enable = "off";
            this.MetadataPanel.Title = "Metadata";
            this.MetadataPanel.Layout.Row = 1;
            this.MetadataPanel.Layout.Column = 1;

            this.MetadataLayout = uigridlayout(this.MetadataPanel);
            this.MetadataLayout.ColumnWidth = ["1x", "1x", "1x"];
            this.MetadataLayout.RowHeight = "1x";

            this.InstrumentTextArea = uitextarea(this.MetadataLayout);
            this.InstrumentTextArea.Editable = "off";
            this.InstrumentTextArea.Tooltip = "Instrument Metadata";
            this.InstrumentTextArea.Placeholder = "Instrument...";
            this.InstrumentTextArea.Layout.Row = 1;
            this.InstrumentTextArea.Layout.Column = 1;

            this.PrimaryTextArea = uitextarea(this.MetadataLayout);
            this.PrimaryTextArea.Editable = "off";
            this.PrimaryTextArea.Tooltip = "Primary Sensor Metadata";
            this.PrimaryTextArea.Placeholder = "Primary Sensor...";
            this.PrimaryTextArea.Layout.Row = 1;
            this.PrimaryTextArea.Layout.Column = 2;

            this.SecondaryTextArea = uitextarea(this.MetadataLayout);
            this.SecondaryTextArea.Editable = "off";
            this.SecondaryTextArea.Tooltip = "Secondary Sensor Metadata";
            this.SecondaryTextArea.Placeholder = "Secondary Sensor...";
            this.SecondaryTextArea.Layout.Row = 1;
            this.SecondaryTextArea.Layout.Column = 3;

            % Create science preview.
            this.instantiateSciencePreview(this.ResultsLayout, Row = 2);

            % Reset.
            this.reset();
        end

        function reset(this)

            % Metadata.
            this.MetadataPanel.Enable = "off";

            this.InstrumentTextArea.Value = char.empty();
            this.PrimaryTextArea.Value = char.empty();
            this.SecondaryTextArea.Value = char.empty();

            % Science preview.
            this.resetSciencePreview();
        end
    end

    methods (Access = protected)

        function modelChangedCallback(this, model, ~)

            if model.HasAnalysis && model.Analysis.Results.HasScience

                results = model.Analysis.Results;

                % Metadata.
                instrumentMetadata = compose("%s - BSW: %s - ASW: %s", results.Metadata.Model, results.Metadata.BSW, results.Metadata.ASW);
                primaryMetadata = compose("%s (%s)", results.Primary.Metadata.getDisplay("Sensor"), string(results.Primary.Metadata.Setup));
                secondaryMetadata = compose("%s (%s)", results.Secondary.Metadata.getDisplay("Sensor"), string(results.Secondary.Metadata.Setup));

                if ~isempty(instrumentMetadata)
                    this.InstrumentTextArea.Value = instrumentMetadata;
                end

                if ~isempty(primaryMetadata)
                    this.PrimaryTextArea.Value = primaryMetadata;
                end

                if ~isempty(secondaryMetadata)
                    this.SecondaryTextArea.Value = secondaryMetadata;
                end

                this.MetadataPanel.Enable = "on";

                % Science preview.
                if results.Primary.HasData && results.Secondary.HasData
                    this.plotSensorPreview(results.Primary.Data, results.Secondary.Data, LegendLabels = ["Primary", "Secondary"]);
                end
            else
                this.reset();
            end
        end
    end
end
