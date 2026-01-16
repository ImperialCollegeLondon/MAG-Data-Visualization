classdef Model < mag.app.Model
% MODEL Vigil reference analysis model.

    properties (Constant, Access = protected)
        AnalysisClassName = "mag.vigil.Analysis"
    end

    methods

        function analyze(this, options)

            analysis = mag.vigil.Analysis.start(options{:});
            this.setAnalysisAndNotify(analysis);
        end

        function export(this, options)
            this.Analysis.export(options{:});
        end

        function reset(this)
            this.setAnalysisAndNotify(mag.vigil.Analysis.empty());
        end
    end
end
