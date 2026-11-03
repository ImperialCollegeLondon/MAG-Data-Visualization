classdef ExportManager < mag.app.manage.ExportManager
% EXPORTMANAGER Manager for export of IMAP analysis.

    methods

        function this = ExportManager()
            this@mag.app.manage.ExportManager(mag.meta.Mission.IMAP, "MAT (Science Lead)");
        end
    end
end
