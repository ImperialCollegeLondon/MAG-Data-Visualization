classdef Model < mag.app.Model
% MODEL HelioSwarm mission analysis model.

    properties (Constant, Access = protected)
        AnalysisClassName = "mag.hs.Analysis"
    end

    methods

        function analyze(this, options)

            analysis = mag.hs.Analysis.start(options{:});
            this.setAnalysisAndNotify(analysis);
        end

        function export(this, options)
            this.Analysis.export(options{:});
        end

        function reset(this)
            this.setAnalysisAndNotify(mag.hs.Analysis.empty());
        end
    end
end
