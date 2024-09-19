classdef Model < mag.app.Model
% MODEL HelioSwarm mission analysis model.

    methods

        function analyze(this, options)

            analysis = mag.hk.Analysis.start(options{:});
            this.setAnalysisAndNotify(analysis);
        end

        function load(this, matFile)

            results = load(matFile);

            for f = string(fieldnames(results))'

                if isa(results.(f), "mag.hk.Analysis")

                    this.setAnalysisAndNotify(results.(f));
                    return;
                end
            end

            error("No ""mag.hk.Analysis"" found in MAT file.");
        end

        function export(this, options)
            this.Analysis.export(options{:});
        end

        function reset(this)
            this.setAnalysisAndNotify(mag.hk.Analysis.empty());
        end
    end

    methods (Access = private)

        function setAnalysisAndNotify(this, analysis)

            this.Analysis = analysis;
            this.notify("AnalysisChanged");
        end
    end
end
