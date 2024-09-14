classdef Model < mag.mixin.SetGet
% MODEL IMAP mission analysis model.

    methods

        function performAnalysis(this, analysisManager)

            arguments
                this
                analysisManager (1,1) mag.app.imap.AnalysisManager
            end

            % Validate location.
            location = analysisManager.LocationEditField.Value;

            if isempty(location)
                error("Location is empty.");
            elseif ~isfolder(location)
                error("Location ""%s"" does not exist.", location);
            end

            % Retrieve data file patterns.
            if isempty(analysisManager.EventPatternEditField.Value)
                eventPattern = string.empty();
            else
                eventPattern = split(analysisManager.EventPatternEditField.Value, pathsep())';
            end

            if isempty(analysisManager.MetaDataPatternEditField.Value)
                metaDataPattern = string.empty();
            else
                metaDataPattern = split(analysisManager.MetaDataPatternEditField.Value, pathsep())';
            end

            if isempty(analysisManager.HKPatternEditField.Value)
                hkPattern = string.empty();
            else
                hkPattern = split(analysisManager.HKPatternEditField.Value, pathsep())';
            end

            % Perform analysis.
            analysisManager.Analysis = mag.imap.Analysis.start(Location = analysisManager.LocationEditField.Value, ...
                EventPattern = eventPattern, ...
                MetaDataPattern = metaDataPattern, ...
                SciencePattern = analysisManager.SciencePatternEditField.Value, ...
                IALiRTPattern = analysisManager.IALiRTPatternEditField.Value, ...
                HKPattern = hkPattern);

            % Notify analysis changed.
            notify(this, "AnalysisChanged");
        end
    end
end
