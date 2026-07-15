classdef Model < mag.app.Model
% MODEL HENON mission analysis model.

    properties (Constant, Access = protected)
        AnalysisClassName = "mag.henon.Analysis"
    end

    methods

        function analyze(this, options)

            analysis = mag.henon.Analysis.start(options{:});
            this.setAnalysisAndNotify(analysis);
        end

        function export(this, options)
            this.Analysis.export(options{:});
        end

        function reset(this)
            this.setAnalysisAndNotify(mag.henon.Analysis.empty());
        end
    end
end
