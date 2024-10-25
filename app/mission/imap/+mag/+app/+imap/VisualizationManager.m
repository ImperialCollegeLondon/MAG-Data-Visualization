classdef VisualizationManager < mag.app.manage.VisualizationManager
% VISUALIZATIONMANAGER Manager for visualization of IMAP analysis.

    properties (Constant, Access = protected)
        EmptyModel = mag.app.imap.Model.empty()
    end

    methods

        function [items, itemsData] = getVisualizationTypesAndClasses(~, model)

            arguments
                ~
                model mag.app.imap.Model {mustBeScalarOrEmpty}
            end

            items = string.empty();
            itemsData = mag.app.Control.empty();

            if ~isempty(model) && model.HasAnalysis

                if model.Analysis.Results.HasScience

                    items = [items, "AT/SFT", "CPT", "Spectrogram", "PSD"];
                    itemsData = [itemsData, mag.app.imap.control.AT(), mag.app.imap.control.CPT(), ...
                        mag.app.imap.control.Spectrogram(), mag.app.imap.control.PSD()];
                end

                if (~isempty(model.Analysis.Results.Primary) && model.Analysis.Results.Primary.HasData) || ...
                        (~isempty(model.Analysis.Results.Secondary) && model.Analysis.Results.Secondary.HasData)

                    items = [items, "Science"];
                    itemsData = [itemsData, mag.app.imap.control.Field()];
                end

                if model.Analysis.Results.HasHK

                    items = [items, "HK"];
                    itemsData = [itemsData, mag.app.imap.control.HK()];
                end
            end
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
