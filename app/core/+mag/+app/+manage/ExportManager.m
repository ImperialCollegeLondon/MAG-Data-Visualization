classdef (Abstract) ExportManager < mag.app.manage.Manager
% EXPORTMANAGER Manager for export components.

    properties (Abstract, Constant)
        % SUPPORTEDFORMATS Supported export formats.
        SupportedFormats (1, :) string
    end

    methods (Abstract)

        % GETEXPORTOPTIONS Get options to export analysis.
        options = getExportOptions(this)
    end
end
