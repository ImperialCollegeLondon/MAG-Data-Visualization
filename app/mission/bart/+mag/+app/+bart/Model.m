classdef Model < mag.app.Model
% MODEL Bartington reference analysis model.

    properties (Constant, Access = protected)
        AnalysisClassName = "mag.bart.Analysis"
    end

    methods

        function analyze(this, options)

            analysis = mag.bart.Analysis.start(options{:});
            this.setAnalysisAndNotify(analysis);
        end

        function export(this, options)
            this.Analysis.export(options{:});
        end

        function reset(this)
            this.setAnalysisAndNotify(mag.bart.Analysis.empty());
        end
    end
end
