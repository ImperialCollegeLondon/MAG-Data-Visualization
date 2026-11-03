classdef Provider < mag.mixin.SetGet
% PROVIDER App components provider for a mission. A mission can customize
% a manager by defining a class with the same name in its namespace, such
% as "mag.app.imap.AnalysisManager". Otherwise, the shared manager is used.

    properties (SetAccess = immutable)
        % MISSION Mission to provide components for.
        Mission (1, 1) mag.meta.Mission
    end

    methods

        function this = Provider(mission)

            arguments
                mission (1, 1) mag.meta.Mission
            end

            this.Mission = mission;
        end

        function model = getModel(this)
            model = mag.app.Model(this.Mission);
        end

        function manager = getAnalysisManager(this)
            manager = this.createManager("AnalysisManager", @() mag.app.manage.AnalysisManager(this.Mission));
        end

        function manager = getResultsManager(this)
            manager = this.createManager("ResultsManager", @() mag.app.manage.ResultsManager());
        end

        function manager = getExportManager(this)
            manager = this.createManager("ExportManager", @() mag.app.manage.ExportManager(this.Mission));
        end

        function manager = getVisualizationManager(this)
            manager = this.createManager("VisualizationManager", @() error("mag:app:NoVisualizationManager", ...
                "No visualization manager for %s mission.", this.Mission.DisplayName));
        end
    end

    methods (Access = private)

        function manager = createManager(this, name, createDefault)
        % CREATEMANAGER Create manager of mission, if it defines one, or
        % the shared manager otherwise.

            className = "mag.app." + this.Mission.PackageName + "." + name;

            if exist(className, "class") == 8
                manager = feval(className);
            else
                manager = createDefault();
            end
        end
    end
end
