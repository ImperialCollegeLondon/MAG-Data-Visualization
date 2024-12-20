classdef Model < mag.app.Model
% MODEL IMAP mission analysis model.

    methods

        function analyze(this, options)

            analysis = mag.imap.Analysis.start(options{:});
            this.setAnalysisAndNotify(analysis);
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
            this.Analysis.export(options{:});
        end

        function reset(this)
            this.setAnalysisAndNotify(mag.imap.Analysis.empty());
        end
    end
end
