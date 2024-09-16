classdef Model < mag.app.Model
% MODEL IMAP mission analysis model.

    methods

        function analyze(this, options)

            results = mag.imap.Analysis.start(options{:});
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

        function export(this, options)
            this.Analysis.export(options{:}, Location = location);
        end

        function reset(this)
            this.setAnalysisAndNotify(mag.imap.Analysis.empty());
        end
    end

    methods (Access = private)

        function setAnalysisAndNotify(this, analysis)

            this.Analysis = analysis;
            this.notify("AnalysisChanged");
        end
    end
end
