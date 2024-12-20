classdef Model < mag.app.Model
% MODEL HelioSwarm mission analysis model.

    methods

        function analyze(this, options)

            analysis = mag.hs.Analysis.start(options{:});
            this.setAnalysisAndNotify(analysis);
        end

        function load(this, matFile)

            results = load(matFile);

            for f = string(fieldnames(results))'

                if isa(results.(f), "mag.hs.Analysis")

                    this.setAnalysisAndNotify(results.(f));
                    return;
                end
            end

            error("No ""mag.hs.Analysis"" found in MAT file.");
        end

        function export(this, options)
            this.Analysis.export(options{:});
        end

        function reset(this)
            this.setAnalysisAndNotify(mag.hs.Analysis.empty());
        end
    end
end
