classdef ExportManager < mag.app.manage.ExportManager
% EXPORTMANAGER Manager for export of HelioSwarm analysis.

    methods

        function this = ExportManager()
            this@mag.app.manage.ExportManager(mag.meta.Mission.HelioSwarm, "MAT (Science Lead)");
        end
    end
end
