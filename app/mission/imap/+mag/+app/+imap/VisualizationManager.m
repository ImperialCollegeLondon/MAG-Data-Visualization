classdef VisualizationManager < mag.app.manage.VisualizationManager
% VISUALIZATIONMANAGER Manager for visualization of IMAP analysis.

    methods

        function items = getVisualizationTypes(~)
            items = ["AT/SFT", "CPT", "HK", "Science", "Spectrogram", "PSD"];
        end

        function itemsData = getVisualizationClasses(~)

            itemsData = [mag.app.imap.control.AT(), mag.app.imap.control.CPT(), mag.app.imap.control.HK(), ...
                mag.app.imap.control.Field(), mag.app.imap.control.Spectrogram(), mag.app.imap.control.PSD()];
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
end
