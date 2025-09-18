classdef Model < mag.app.Model
% MODEL IMAP mission analysis model.

    properties (Constant, Access = protected)
        AnalysisClassName = "mag.imap.Analysis"
    end

    methods

        function analyze(this, options)

            analysis = mag.imap.Analysis.start(options{:});
            this.setAnalysisAndNotify(analysis);
        end

        function export(this, options)
            this.Analysis.export(options{:});
        end

        function reset(this)
            this.setAnalysisAndNotify(mag.imap.Analysis.empty());
        end
    end
end
