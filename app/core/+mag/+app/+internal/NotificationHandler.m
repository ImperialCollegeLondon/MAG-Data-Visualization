classdef NotificationHandler < handle
% NOTIFICATIONHANDLER Handle notifications for app components.

    events
        % ERROR Trigger event on error.
        Error
    end

    properties (Access = private)
        UIFigure matlab.ui.Figure {mustBeScalarOrEmpty}
    end

    methods

        function this = NotificationHandler(uiFigure)
            this.UIFigure = uiFigure;
        end

        function displayAlert(this, message, title, icon)

            arguments
                this (1, 1) mag.app.internal.NotificationHandler
                message (1, 1) {mustBeA(message, ["string", "MException"])}
                title (1, 1) string = "Something Went Wrong..."
                icon (1, 1) string {mustBeMember(icon, ["question", "info", "success", "warning", "error", "none"])} = "error"
            end

            if ~isvalid(this.UIFigure)
                return;
            end

            if isa(message, "MException")

                eventData = mag.app.event.ErrorData(message);
                this.notify("Error", eventData);

                msg = message.message;
            else
                msg = message;
            end

            uialert(this.UIFigure, msg, title, Icon = icon, Interpreter = "html");
        end

        function selection = displayPopup(this, message, title, icon, options, defaultOption, cancelOption)

            arguments
                this (1, 1) mag.app.internal.NotificationHandler
                message (1, 1) string
                title (1, 1) string
                icon (1, 1) string {mustBeMember(icon, ["question", "info", "success", "warning", "error", "none"])}
                options (1, :) string
                defaultOption (1, 1) string
                cancelOption (1, 1) string
            end

            selection = uiconfirm(this.UIFigure, message, title, ...
                Icon = icon, ...
                Options = options, ...
                DefaultOption = defaultOption, ...
                CancelOption = cancelOption);
        end

        function closeProgressBar = overlayProgressBar(this, message)

            arguments (Input)
                this (1, 1) mag.app.internal.NotificationHandler
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

        function restoreWarningState = disableWarningStackTrace(~)

            previousWarningState = warning("off", "backtrace");
            restoreWarningState = onCleanup(@() warning(previousWarningState));
        end

        function executeCallback(this, callback, message)

            closeProgressBar = this.overlayProgressBar(message); %#ok<NASGU>
            restoreWarningState = this.disableWarningStackTrace(); %#ok<NASGU>

            try
                callback();
            catch exception
                this.displayAlert(exception);
            end
        end
    end
end
