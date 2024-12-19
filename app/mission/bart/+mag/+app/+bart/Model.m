classdef Model < mag.app.Model
% MODEL Bartington reference analysis model.

    methods

        function analyze(this, options)

            analysis = mag.bart.Analysis.start(options{:});
            this.setAnalysisAndNotify(analysis);
        end

        function load(this, matFile)

            results = load(matFile);

            for f = string(fieldnames(results))'

                if isa(results.(f), "mag.bart.Analysis")

                    this.setAnalysisAndNotify(results.(f));
                    return;
                end
            end

            error("No ""mag.bart.Analysis"" found in MAT file.");
        end

        function export(this, options)
            this.Analysis.export(options{:});
        end

        function reset(this)
            this.setAnalysisAndNotify(mag.bart.Analysis.empty());
        end
    end
end
