classdef VisualizationManager < mag.app.manage.Manager
% VISUALIZATIONMANAGER Manager for visualization of IMAP analysis.

    properties (SetAccess = private)
        VisualizationOptionsLayout matlab.ui.container.GridLayout
        VisualizationOptionsPanel matlab.ui.container.Panel
        VisualizationTypeListBox matlab.ui.control.ListBox
    end

    properties (Access = private)
        SelectedControl mag.app.Control {mustBeScalarOrEmpty}
    end

    methods

        function instantiate(this, parent)

            % Create VisualizationOptionsLayout.
            this.VisualizationOptionsLayout = uigridlayout(parent);
            this.VisualizationOptionsLayout.ColumnWidth = ["1x", "4x"];
            this.VisualizationOptionsLayout.RowHeight = "1x";

            % Create VisualizationTypeListBox.
            this.VisualizationTypeListBox = uilistbox(this.VisualizationOptionsLayout);
            this.VisualizationTypeListBox.Items = ["AT, SFT", "CPT", "Science", "Spectrogram", "PSD"];
            this.VisualizationTypeListBox.ItemsData = [mag.app.imap.control.AT(), mag.app.imap.control.CPT(), mag.app.imap.control.Field(), ...
                mag.app.imap.control.Spectrogram(), mag.app.imap.control.PSD()];
            this.VisualizationTypeListBox.Value = this.VisualizationTypeListBox.ItemsData(1);
            this.VisualizationTypeListBox.ValueChangedFcn = @(~, ~) this.visualizationTypeListBoxValueChanged();
            this.VisualizationTypeListBox.Enable = "off";
            this.VisualizationTypeListBox.Layout.Row = 1;
            this.VisualizationTypeListBox.Layout.Column = 1;

            % Create VisualizationOptionsPanel.
            this.VisualizationOptionsPanel = uipanel(this.VisualizationOptionsLayout);
            this.VisualizationOptionsPanel.Enable = "off";
            this.VisualizationOptionsPanel.BorderType = "none";
            this.VisualizationOptionsPanel.Layout.Row = 1;
            this.VisualizationOptionsPanel.Layout.Column = 2;

            % Reset.
            this.reset();
        end

        function reset(this)

            this.VisualizationTypeListBox.Value = this.VisualizationTypeListBox.ItemsData(1);
            this.VisualizationTypeListBox.Enable = "off";
            this.VisualizationOptionsPanel.Enable = "off";
        end

        function figures = visualize(this, analysis)

            if isa(this.SelectedControl, "mag.app.imap.control.AT") || isa(this.SelectedControl, "mag.app.imap.control.CPT")
                args = {analysis};
            else
                args = {analysis.Results};
            end

            command = this.SelectedControl.getVisualizeCommand(args{:});
            figures = command.call();
        end
    end

    methods (Access = protected)

        function modelChangedCallback(this, model, ~)

            if model.HasAnalysis && model.Analysis.Results.HasScience

                this.VisualizationTypeListBox.Enable = "on";
                this.VisualizationOptionsPanel.Enable = "on";

                this.visualizationTypeListBoxValueChanged();
            else
                this.reset();
            end
        end
    end

    methods (Access = private)

        function visualizationTypeListBoxValueChanged(this)

            this.SelectedControl = this.VisualizationTypeListBox.ItemsData(this.VisualizationTypeListBox.ValueIndex);
            this.SelectedControl.instantiate(this.VisualizationOptionsPanel);
        end
    end
end
