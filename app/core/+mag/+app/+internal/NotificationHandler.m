classdef NotificationHandler < handle
% NOTIFICATIONHANDLER Handle notifications for app components.

    properties (Access = private)
        UIFigure matlab.ui.Figure {mustBeScalarOrEmpty}
        ToolbarManager mag.app.manage.ToolbarManager {mustBeScalarOrEmpty}
    end

    methods

        function this = NotificationHandler(uiFigure, toolbarManager)

            this.UIFigure = uiFigure;
            this.ToolbarManager = toolbarManager;
        end

        function displayAlert(this, message, title, icon)

            arguments
                this
                message (1, 1) {mustBeA(message, ["string", "MException"])}
                title (1, 1) string = "Something Went Wrong..."
                icon (1, 1) string {mustBeMember(icon, ["error", "warning", "info", "success", "none"])} = "error"
            end

            if ~isvalid(this.UIFigure)
                return;
            end

            if isa(message, "MException")

                this.ToolbarManager.setLatestErrorMessage(message);
                msg = message.message;
            else
                msg = message;
            end

            uialert(this.UIFigure, msg, title, Icon = icon, Interpreter = "html");
        end

        function closeProgressBar = overlayProgressBar(this, message)

            arguments (Input)
                this
                message (1, 1) string
            end

            arguments (Output)
                closeProgressBar (1, :) onCleanup
            end

            if ~isvalid(this.UIFigure)

                closeProgressBar = onCleanup.empty();
                return;
            end

            progressBar = uiprogressdlg(this.UIFigure, Message = message, Icon = "info", Indeterminate = "on");
            closeProgressBar = [onCleanup(@() delete(progressBar)), onCleanup(@() beep())];
        end
    end
end
