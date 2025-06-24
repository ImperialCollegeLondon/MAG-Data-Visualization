classdef ToolbarManager < mag.app.manage.Manager
% TOOLBARMANAGER Manager for toolbar components.

    properties (Constant)
        DebugErrorID (1, 1) string = "Error ID"
        DebugErrorSource (1, 1) string = "Error Source"
        DebugCancel (1, 1) string = "Cancel"
    end

    properties (SetAccess = private)
        Toolbar matlab.ui.container.Toolbar
        MissionPushTool matlab.ui.container.toolbar.PushTool
        ImportPushTool matlab.ui.container.toolbar.PushTool
        DebugToggleTool matlab.ui.container.toolbar.ToggleTool
        HelpPushTool matlab.ui.container.toolbar.PushTool
    end

    properties (Access = private)
        App DataVisualization {mustBeScalarOrEmpty}
        IconsPath string {mustBeScalarOrEmpty, mustBeFolder}
        DebugStatus struct = dbstatus()
        PreviousError MException {mustBeScalarOrEmpty}
    end

    methods

        function this = ToolbarManager(app, pathToAppIcons)

            this.App = app;
            this.IconsPath = pathToAppIcons;
        end

        function instantiate(this, parent)

            % Create Toolbar.
            this.Toolbar = uitoolbar(parent);

            if mag.internal.isThemeable(parent)
                theme = parent.Theme.BaseColorStyle;
            else
                theme = "light";
            end

            % Create MissionPushTool.
            this.MissionPushTool = uipushtool(this.Toolbar);
            this.MissionPushTool.Tooltip = "Change mission";
            this.MissionPushTool.ClickedCallback = @(~, ~) this.missionPushToolClicked();
            this.MissionPushTool.Icon = this.getIconPath("mission", theme);

            % Create ImportPushTool.
            this.ImportPushTool = uipushtool(this.Toolbar);
            this.ImportPushTool.Tooltip = "Import existing analysis";
            this.ImportPushTool.ClickedCallback = @(~, ~) this.importPushToolClicked();
            this.ImportPushTool.Icon = this.getIconPath("import", theme);
            this.ImportPushTool.Separator = "on";

            % Create DebugToggleTool.
            this.DebugToggleTool = uitoggletool(this.Toolbar);
            this.DebugToggleTool.Tooltip = "Set break point at last error source";
            this.DebugToggleTool.Icon = this.getIconPath("debug", theme);
            this.DebugToggleTool.Separator = "on";
            this.DebugToggleTool.OffCallback = @(~, ~) this.debugToggleToolOff();
            this.DebugToggleTool.OnCallback = @(~, ~) this.debugToggleToolOn();

            % Create HelpPushTool.
            this.HelpPushTool = uipushtool(this.Toolbar);
            this.HelpPushTool.Tooltip = "Share debugging information with development";
            this.HelpPushTool.ClickedCallback = @(~, ~) this.helpPushToolClicked();
            this.HelpPushTool.Icon = this.getIconPath("help", theme);
        end

        function reset(~)
            error("Reset method not supported.");
        end

        function setLatestErrorMessage(this, exception)
            this.PreviousError = exception;
        end

        function unlockToolbar = lock(this)

            arguments (Output)
                unlockToolbar (1, 1) onCleanup
            end

            [this.MissionPushTool.Enable, this.ImportPushTool.Enable, ...
                this.DebugToggleTool.Enable, this.HelpPushTool.Enable] = deal(false);

            unlockToolbar = onCleanup(@() this.unlock());
        end

        function unlock(this)

            if ~isvalid(this) || ~isvalid(this.Toolbar)
                return;
            end

            [this.MissionPushTool.Enable, this.ImportPushTool.Enable, ...
                this.DebugToggleTool.Enable, this.HelpPushTool.Enable] = deal(true);
        end
    end

    methods (Access = protected)

        function modelChangedCallback(~, ~, ~)
            % do nothing
        end
    end

    methods (Access = private)

        function iconPath = getIconPath(this, iconName, theme)
            iconPath = fullfile(this.IconsPath, compose("%s_%s.png", iconName, theme));
        end

        function missionPushToolClicked(this)
            this.App.selectMission();
        end

        function importPushToolClicked(this)

            closeProgressBar = this.App.AppNotificationHandler.overlayProgressBar("Importing..."); %#ok<NASGU>
            [file, folder] = uigetfile("*.mat", "Import Analysis");

            if ~isequal(file, 0) && ~isequal(folder, 0)

                try

                    this.App.Model.load(fullfile(folder, file));
                    this.App.AppNotificationHandler.displayAlert("Analysis successfully imported.", "Import Complete", "success");
                catch exception
                    this.App.AppNotificationHandler.displayAlert(exception);
                end
            end
        end

        function debugToggleToolOn(this)

            this.DebugStatus = dbstatus();

            if isempty(this.PreviousError)

                this.DebugToggleTool.State = "off";
                this.App.AppNotificationHandler.displayAlert("No error found.", "No Errors", "warning");
                return;
            end

            selection = uiconfirm(this.App.UIFigure, "Select debugging type.", "Debug Type", Icon = "question", Options = [this.DebugErrorID, this.DebugErrorSource, this.DebugCancel], ...
                DefaultOption = this.DebugErrorID, CancelOption = this.DebugCancel);

            switch selection
                case this.DebugErrorID
                    mag.internal.stopIfException(this.PreviousError.identifier);
                case this.DebugErrorSource

                    stack = this.PreviousError.stack;
                    dbstop("in", stack(1).file, "at", num2str(stack(1).line));
                otherwise
                    this.DebugToggleTool.State = "off";
            end
        end

        function debugToggleToolOff(this)

            dbclear("all");
            dbstop(this.DebugStatus);
        end

        function helpPushToolClicked(this)

            web("https://github.com/ImperialCollegeLondon/MAG-Data-Visualization-Toolbox/issues/new/choose");

            this.App.AppNotificationHandler.displayAlert("Create issue on GitHub to share feedback, report issues and ask questions.", ...
                "Create GitHub Issue", "info");
        end
    end
end
