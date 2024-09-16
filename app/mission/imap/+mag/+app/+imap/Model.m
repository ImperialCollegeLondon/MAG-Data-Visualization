classdef Model < mag.app.Model
% MODEL IMAP mission analysis model.

    methods

        function analyze(this, analysisManager)

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
            results = mag.imap.Analysis.start(Location = analysisManager.LocationEditField.Value, ...
                EventPattern = eventPattern, ...
                MetaDataPattern = metaDataPattern, ...
                SciencePattern = analysisManager.SciencePatternEditField.Value, ...
                IALiRTPattern = analysisManager.IALiRTPatternEditField.Value, ...
                HKPattern = hkPattern);

            % Notify analysis changed.
            this.setAnalysisAndNotify(results);
        end

        function load(this, matFile)

            results = load(matFile);

            for f = string(fieldnames(results))'

                if isa(results.(f), "mag.imap.Analysis")

                    this.setAnalysisAndNotify(results.(f));
                    return;
                end
            end

            error("No ""mag.imap.Analysis"" found in MAT file.");
        end
    end

    methods (Access = private)

        function setAnalysisAndNotify(this, analysis)

            this.Analysis = analysis;
            this.notify("AnalysisChanged");
        end
    end
end
