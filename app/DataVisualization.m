classdef (Sealed) DataVisualization < matlab.mixin.SetGet
% DATAVISUALIZATION App for processing, exporting and visualizing MAG data.

    properties (Constant)
        ExportWorkspace (1, 1) string = "Workspace"
        ExportMAT (1, 1) string = "MAT (Full Analysis)"
    end

    properties (Constant, Access = private)
        AppName (1, 1) string = "MAG Data Visualization App"
        ProcessDataText (1, 1) string = "Process Data"
        ExportText (1, 1) string = "Export"
        CancelText (1, 1) string = "Cancel"
    end

    properties (SetAccess = private)
        UIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        TabGroup matlab.ui.container.TabGroup
        AnalyzeTab matlab.ui.container.Tab
        AnalyzeLayout matlab.ui.container.GridLayout
        AnalyzeSettingsPanel matlab.ui.container.Panel
        VersionLabel matlab.ui.control.Label
        AnalyzeStatusLabel matlab.ui.control.Label
        ProcessDataButton matlab.ui.control.Button
        ResetButton matlab.ui.control.Button
        ResultsTab matlab.ui.container.Tab
        HealthTab matlab.ui.container.Tab
        ExportTab matlab.ui.container.Tab
        ExportLayout matlab.ui.container.GridLayout
        ExportSettingsPanel matlab.ui.container.Panel
        ExportButtonsLayout matlab.ui.container.GridLayout
        ExportNoteLabel matlab.ui.control.Label
        ExportStatusLabel matlab.ui.control.Label
        ExportButton matlab.ui.control.Button
        ExportFormatDropDown matlab.ui.control.DropDown
        FormatDropDownLabel matlab.ui.control.Label
        VisualizeTab matlab.ui.container.Tab
        VisualizeLayout matlab.ui.container.GridLayout
        VisualizeSettingsPanel matlab.ui.container.Panel
        VisualizeButtonsLayout matlab.ui.container.GridLayout
        CloseFiguresButton matlab.ui.control.Button
        SaveFiguresButton matlab.ui.control.Button
        ShowFiguresButton matlab.ui.control.Button
    end

    properties (SetAccess = private)
        SelectMissionDialog mag.app.internal.SelectMissionDialog {mustBeScalarOrEmpty}
        Mission mag.meta.Mission {mustBeScalarOrEmpty}
        Provider mag.app.Provider {mustBeScalarOrEmpty}
        Model mag.app.Model {mustBeScalarOrEmpty} = mag.app.imap.Model.empty()
        ToolbarManager mag.app.manage.ToolbarManager {mustBeScalarOrEmpty}
        AnalysisManager mag.app.manage.AnalysisManager {mustBeScalarOrEmpty}
        ResultsManager mag.app.manage.Manager {mustBeScalarOrEmpty}
        HealthManager mag.app.manage.HealthManager {mustBeScalarOrEmpty}
        ExportManager mag.app.manage.ExportManager {mustBeScalarOrEmpty}
        VisualizationManager mag.app.manage.VisualizationManager {mustBeScalarOrEmpty}
        NotificationHandler mag.app.internal.NotificationHandler {mustBeScalarOrEmpty}
        ProcessingTask mag.app.internal.BackgroundTask {mustBeScalarOrEmpty}
        ExportTask mag.app.internal.BackgroundTask {mustBeScalarOrEmpty}
    end

    properties (Dependent, SetAccess = private)
        % ISPROCESSING Logical denoting whether data is being processed.
        IsProcessing (1, 1) logical
        % ISEXPORTING Logical denoting whether data is being exported.
        IsExporting (1, 1) logical
    end

    properties (SetObservable, SetAccess = private)
        Figures (1, :) matlab.ui.Figure
    end

    properties (Dependent, Access = private)
        ResultsLocation (1, 1) string {mustBeFolder}
        Managers (1, :) mag.app.manage.Manager
    end

    properties (Access = private)
        ToolbarLock onCleanup {mustBeScalarOrEmpty}
    end

    methods

        function app = DataVisualization(mission)

            arguments (Input)
                mission mag.meta.Mission {mustBeScalarOrEmpty} = string.empty()
            end

            % Create figure and other UI components.
            app.UIFigure = uifigure(Name = app.getAppName(), Position = [100, 100, 800, 495], Resize = "off");

            pathToAppIcons = fullfile(fileparts(mfilename("fullpath")), "icons");
            app.ToolbarManager = mag.app.manage.ToolbarManager(app, pathToAppIcons);
            app.ToolbarManager.instantiate(app.UIFigure);

            app.NotificationHandler = mag.app.internal.NotificationHandler(app.UIFigure);
            app.ToolbarManager.subscribe(app.NotificationHandler);

            % Initialize app based on mission.
            try
                app.selectMission(mission);
            catch exception

                delete(app);
                rethrow(exception);
            end

            if nargout() == 0
                clear("app");
            end
        end

        function delete(app)

            app.cancelTasks();
            delete(app.UIFigure);
        end

        function value = get.IsProcessing(app)
            value = ~isempty(app.ProcessingTask) && isvalid(app.ProcessingTask) && app.ProcessingTask.IsRunning;
        end

        function value = get.IsExporting(app)
            value = ~isempty(app.ExportTask) && isvalid(app.ExportTask) && app.ExportTask.IsRunning;
        end

        function completed = waitForTasks(app, timeout)
        % WAITFORTASKS Wait for background tasks to complete, or until
        % timeout (in seconds) is reached.

            arguments (Input)
                app (1, 1) DataVisualization
                timeout (1, 1) double {mustBePositive} = Inf
            end

            arguments (Output)
                completed (1, 1) logical
            end

            deadline = tic();
            completed = true;

            for task = [app.ProcessingTask, app.ExportTask]

                if isvalid(task)
                    completed = task.wait(max(eps(), timeout - toc(deadline))) && completed;
                end
            end
        end

        function importAnalysis(app, matFile)
        % IMPORTANALYSIS Import existing analysis from MAT file, in the
        % background.

            arguments
                app (1, 1) DataVisualization
                matFile (1, 1) string
            end

            if app.IsProcessing

                app.NotificationHandler.displayAlert("Cannot import while processing.", "Busy", "warning");
                return;
            end

            try
                task = app.Model.createLoadTask(matFile);
            catch exception

                app.NotificationHandler.displayAlert(exception);
                return;
            end

            app.startProcessingTask(task, "Import");
        end

        function value = get.ResultsLocation(app)

            if isempty(app.Model.Analysis)
                location = app.AnalysisManager.LocationEditField.Value;
            else
                location = app.Model.Analysis.Location;
            end

            value = fullfile(location, compose("Results (v%s)", mag.version()));

            if ~isfolder(value)
                mkdir(value);
            end
        end

        function value = get.Managers(app)
            value = [app.AnalysisManager, app.ResultsManager, app.HealthManager, app.ExportManager, app.VisualizationManager];
        end

        function selectMission(app, mission)
        % SELECTMISSION Select mission to analyze.

            arguments (Input)
                app
                mission mag.meta.Mission {mustBeScalarOrEmpty} = string.empty()
            end

            % Cancel tasks first, as their completion unlocks the toolbar.
            app.cancelTasks();

            unlockToolbar = app.ToolbarManager.lock(); %#ok<NASGU>

            % Ask which mission to load, if not provided.
            if isempty(mission)

                app.SelectMissionDialog = mag.app.internal.SelectMissionDialog(app.UIFigure);
                mission = app.SelectMissionDialog.waitForSelection();

                if app.SelectMissionDialog.Aborted
                    error("mag:app:Abort", "User aborted.");
                else
                    app.SelectMissionDialog.delete();
                end

                closeProgressBar = app.NotificationHandler.overlayProgressBar("Initializing mission..."); %#ok<NASGU>
            end

            app.Mission = mission;

            switch app.Mission
                case mag.meta.Mission.Bartington
                    app.Provider = mag.app.bart.Provider();
                case mag.meta.Mission.HENON
                    app.Provider = mag.app.henon.Provider();
                case mag.meta.Mission.HelioSwarm
                    app.Provider = mag.app.hs.Provider();
                case mag.meta.Mission.IMAP
                    app.Provider = mag.app.imap.Provider();
                case mag.meta.Mission.Vigil
                    app.Provider = mag.app.vigil.Provider();
                otherwise
                    error("mag:app:UnsupportedMission", "%s mission not supported.", app.Mission.DisplayName);
            end

            % Set managers.
            app.Model = app.Provider.getModel();

            app.AnalysisManager = app.Provider.getAnalysisManager();
            app.ResultsManager = app.Provider.getResultsManager();
            app.HealthManager = mag.app.manage.HealthManager();
            app.ExportManager = app.Provider.getExportManager();
            app.VisualizationManager = app.Provider.getVisualizationManager();

            for manager = app.Managers
                manager.subscribe(app.Model);
            end

            % Create components.
            delete(app.GridLayout);

            app.createComponents();

            app.addlistener("Figures", "PostSet", @app.figuresChanged);
            app.Model.addlistener("ModelChanged", @app.modelChangedCallback);

            app.UIFigure.Name = app.getAppName();
        end
    end

    methods (Access = private)

        function name = getAppName(app)

            if isempty(app.Mission)
                name = app.AppName;
            else
                name = compose("%s (%s)", app.AppName, app.Mission.DisplayName);
            end
        end

        function modelChangedCallback(app, model, ~)

            hasModel = model.HasAnalysis;
            hasData = hasModel && (model.Analysis.Results.HasScience || model.Analysis.Results.HasHK);

            if hasModel && ~hasData
                app.NotificationHandler.displayAlert("No HK or science data detected.", "No Data", "warning");
            end

            status = matlab.lang.OnOffSwitchState(hasData);

            [app.ExportFormatDropDown.Enable, app.ExportSettingsPanel.Enable] = deal(status && ~app.IsExporting);
            app.ExportButton.Enable = status || app.IsExporting;
            app.ShowFiguresButton.Enable = status;
        end

        function figuresChanged(app, varargin)

            figuresAvailable = ~isempty(app.Figures) && any(isvalid(app.Figures));
            [app.SaveFiguresButton.Enable, app.CloseFiguresButton.Enable] = deal(matlab.lang.OnOffSwitchState(figuresAvailable));
        end

        function processDataButtonPushed(app)

            % Button cancels processing, while it is running.
            if app.IsProcessing

                app.ProcessingTask.cancel();
                return;
            end

            try
                task = app.Model.createAnalysisTask(app.AnalysisManager.getAnalysisOptions());
            catch exception

                app.NotificationHandler.displayAlert(exception);
                return;
            end

            app.startProcessingTask(task, "Processing");
        end

        function startProcessingTask(app, task, action)
        % STARTPROCESSINGTASK Start task that updates analysis, locking UI
        % while it runs.

            task.BlockingFcn = @app.blockUI;
            task.addlistener("Completed", @(task, ~) app.processingCompleted(task, action));

            app.ProcessingTask = task;
            app.setProcessingState(true, task.Description);

            task.start();
        end

        function processingCompleted(app, task, action)

            if ~isvalid(app)
                return;
            end

            app.setProcessingState(false);
            app.AnalyzeStatusLabel.Text = app.reportTaskCompletion(task, action);

            if (action == "Import") && (task.State == mag.app.internal.TaskState.Succeeded)
                app.NotificationHandler.displayAlert("Analysis successfully imported.", "Import Complete", "success");
            end
        end

        function setProcessingState(app, isProcessing, status)

            arguments
                app (1, 1) DataVisualization
                isProcessing (1, 1) logical
                status (1, 1) string = ""
            end

            if isProcessing

                app.ProcessDataButton.Text = app.CancelText;
                app.AnalyzeStatusLabel.Text = status;

                % Release previous lock first, as releasing it unlocks the
                % toolbar.
                app.ToolbarLock = onCleanup.empty();
                app.ToolbarLock = app.ToolbarManager.lock();
            else

                app.ProcessDataButton.Text = app.ProcessDataText;
                app.ToolbarLock = onCleanup.empty();
            end

            [app.AnalyzeSettingsPanel.Enable, app.ResetButton.Enable] = deal(matlab.lang.OnOffSwitchState(~isProcessing));
        end

        function resetButtonPushed(app)

            app.cancelTasks();
            app.closeFiguresButtonPushed();

            app.AnalyzeStatusLabel.Text = "";
            app.ExportStatusLabel.Text = "";

            app.Model.reset();
            app.Figures = matlab.ui.Figure.empty();

            for manager = app.Managers
                manager.reset();
            end
        end

        function exportButtonPushed(app)

            % Button cancels export, while it is running.
            if app.IsExporting

                app.ExportTask.cancel();
                return;
            end

            closeProgressBar = app.NotificationHandler.overlayProgressBar("Exporting..."); %#ok<NASGU>
            restoreWarningState = app.NotificationHandler.disableWarningStackTrace(); %#ok<NASGU>

            format = app.ExportFormatDropDown.Value;

            switch format
                case app.ExportWorkspace

                    variableName = app.createMissionSpecificVariable();

                    if evalin("base", compose("exist(""%s"", ""var"")", variableName)) %#ok<EVALIN>

                        selectedOption = uiconfirm(app.UIFigure, compose("Variable <code>%s</code> already exists in the MATLAB Workspace.", variableName) + ...
                            " Would you like to overwrite it?", "Variable Already Exists", Interpreter = "html");

                        if ~isequal(selectedOption, "OK")
                            return;
                        end
                    end

                    assignin("base", variableName, eval(variableName));
                case app.ExportMAT

                    if isempty(app.Model.TimeRange)
                        extra = "";
                    else

                        timestamp = app.Model.TimeRange(1);
                        timestamp.Format = "dd-MMM-yyyy HHmmss";

                        extra = compose(" (%s)", timestamp);
                    end

                    fileName = fullfile(app.ResultsLocation, compose("Analysis%s.mat", extra));
                    variableName = app.createMissionSpecificVariable();

                    if isfile(fileName)
                        options = {"-append"};
                    else
                        options = {};
                    end

                    save(fileName, variableName, options{:});
                case cellstr(app.ExportManager.SupportedFormats)

                    try
                        task = app.Model.createExportTask(app.ExportManager.getExportOptions(format, app.ResultsLocation));
                    catch exception

                        app.NotificationHandler.displayAlert(exception);
                        return;
                    end

                    % Close progress bar, as export continues in the
                    % background.
                    clear("closeProgressBar", "restoreWarningState");

                    task.BlockingFcn = @app.blockUI;
                    task.addlistener("Completed", @(task, ~) app.exportCompleted(task));

                    app.ExportTask = task;
                    app.setExportingState(true);

                    task.start();
                otherwise
                    app.NotificationHandler.displayAlert(compose("Unrecognized export format option ""%s"".", format));
            end
        end

        function exportCompleted(app, task)

            if ~isvalid(app)
                return;
            end

            app.setExportingState(false);
            app.ExportStatusLabel.Text = app.reportTaskCompletion(task, "Export");
        end

        function setExportingState(app, isExporting)

            arguments
                app (1, 1) DataVisualization
                isExporting (1, 1) logical
            end

            if isExporting

                app.ExportButton.Text = app.CancelText;
                app.ExportStatusLabel.Text = "Exporting...";
            else
                app.ExportButton.Text = app.ExportText;
            end

            hasData = app.Model.HasAnalysis && (app.Model.Analysis.Results.HasScience || app.Model.Analysis.Results.HasHK);
            [app.ExportFormatDropDown.Enable, app.ExportSettingsPanel.Enable] = deal(matlab.lang.OnOffSwitchState(hasData && ~isExporting));
        end

        function cancelTasks(app)
        % CANCELTASKS Cancel any running background task.

            for task = [app.ProcessingTask, app.ExportTask]

                if isvalid(task)
                    task.cancel();
                end
            end
        end

        function unblock = blockUI(app, message)
        % BLOCKUI Block UI while task runs in the foreground.

            unblock = [app.NotificationHandler.overlayProgressBar(message), app.NotificationHandler.disableWarningStackTrace()];
        end

        function status = reportTaskCompletion(app, task, action)
        % REPORTTASKCOMPLETION Report outcome of background task and return
        % status message.

            arguments (Input)
                app (1, 1) DataVisualization
                task (1, 1) mag.app.internal.BackgroundTask
                action (1, 1) string
            end

            arguments (Output)
                status (1, 1) string
            end

            % Show output generated in the background.
            if strlength(task.Diary) > 0
                fprintf("%s", task.Diary);
            end

            switch task.State
                case mag.app.internal.TaskState.Succeeded
                    status = compose("%s completed in %s.", action, string(task.Duration, "hh:mm:ss"));
                case mag.app.internal.TaskState.Cancelled
                    status = compose("%s cancelled.", action);
                otherwise

                    status = compose("%s failed.", action);
                    app.NotificationHandler.displayAlert(task.Error);
            end

            % Foreground tasks already notify on completion.
            if task.CurrentEnvironment.isBackground() && (task.State ~= mag.app.internal.TaskState.Cancelled)
                mag.app.internal.NotificationHandler.beep();
            end
        end

        function showFiguresButtonPushed(app)

            closeProgressBar = app.NotificationHandler.overlayProgressBar("Plotting data..."); %#ok<NASGU>
            restoreWarningState = app.NotificationHandler.disableWarningStackTrace(); %#ok<NASGU>

            try
                app.Figures = [app.Figures, app.VisualizationManager.visualize(app.Model.Analysis)];
            catch exception
                app.NotificationHandler.displayAlert(exception);
            end
        end

        function saveFiguresButtonPushed(app)

            closeProgressBar = app.NotificationHandler.overlayProgressBar("Saving figures..."); %#ok<NASGU>
            restoreWarningState = app.NotificationHandler.disableWarningStackTrace(); %#ok<NASGU>

            try
                mag.graphics.savePlots(app.Figures, app.ResultsLocation);
            catch exception
                app.NotificationHandler.displayAlert(exception);
            end
        end

        function closeFiguresButtonPushed(app)

            isValidFigures = isvalid(app.Figures);

            if ~isempty(app.Figures) && any(isValidFigures)

                closeProgressBar = app.NotificationHandler.overlayProgressBar("Closing figures..."); %#ok<NASGU>
                restoreWarningState = app.NotificationHandler.disableWarningStackTrace(); %#ok<NASGU>

                close(app.Figures(isValidFigures));
            end

            % Force UI to refresh, even if no figures were closed.
            app.Figures = matlab.ui.Figure.empty();
        end

        function createComponents(app)

            % Create GridLayout.
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.RowHeight = "1x";

            % Create TabGroup.
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = 1;
            app.TabGroup.Layout.Column = [1 2];

            % Create AnalyzeTab.
            app.AnalyzeTab = uitab(app.TabGroup, Title = "Analyze");

            % Create AnalyzeLayout.
            app.AnalyzeLayout = uigridlayout(app.AnalyzeTab);
            app.AnalyzeLayout.ColumnWidth = ["1x", "3x", "2x", "1x"];
            app.AnalyzeLayout.RowHeight = ["6x", "1x"];

            % Create AnalyzeSettingsPanel.
            app.AnalyzeSettingsPanel = uipanel(app.AnalyzeLayout);
            app.AnalyzeSettingsPanel.Title = "Settings";
            app.AnalyzeSettingsPanel.Layout.Row = 1;
            app.AnalyzeSettingsPanel.Layout.Column = [1, 4];

            % Populate "Analyze" tab based on mission.
            app.AnalysisManager.instantiate(app.AnalyzeSettingsPanel);

            % Create ProcessDataButton.
            app.ProcessDataButton = uibutton(app.AnalyzeLayout, "push");
            app.ProcessDataButton.ButtonPushedFcn = @(~, ~) app.processDataButtonPushed();
            app.ProcessDataButton.Layout.Row = 2;
            app.ProcessDataButton.Layout.Column = 3;
            app.ProcessDataButton.Text = app.ProcessDataText;

            % Create ResetButton.
            app.ResetButton = uibutton(app.AnalyzeLayout, "push");
            app.ResetButton.ButtonPushedFcn = @(~, ~) app.resetButtonPushed();
            app.ResetButton.Layout.Row = 2;
            app.ResetButton.Layout.Column = 4;
            app.ResetButton.Text = "Reset";

            % Create VersionLabel.
            app.VersionLabel = uilabel(app.AnalyzeLayout);
            app.VersionLabel.VerticalAlignment = "bottom";
            app.VersionLabel.Layout.Row = 2;
            app.VersionLabel.Layout.Column = 1;
            app.VersionLabel.Text = compose("v%s", mag.version());

            % Create AnalyzeStatusLabel.
            app.AnalyzeStatusLabel = uilabel(app.AnalyzeLayout);
            app.AnalyzeStatusLabel.HorizontalAlignment = "right";
            app.AnalyzeStatusLabel.Layout.Row = 2;
            app.AnalyzeStatusLabel.Layout.Column = 2;
            app.AnalyzeStatusLabel.Text = "";

            % Create ResultsTab.
            app.ResultsTab = uitab(app.TabGroup, Title = "Results");
            app.ResultsManager.instantiate(app.ResultsTab);

            % Create HealthTab.
            app.HealthTab = uitab(app.TabGroup, Title = "Health");
            app.HealthManager.instantiate(app.HealthTab);

            % Create ExportTab.
            app.ExportTab = uitab(app.TabGroup, Title = "Export");

            % Create ExportLayout.
            app.ExportLayout = uigridlayout(app.ExportTab);
            app.ExportLayout.ColumnWidth = "1x";
            app.ExportLayout.RowHeight = ["4x", "1x"];

            % Create ExportButtonsLayout.
            app.ExportButtonsLayout = uigridlayout(app.ExportLayout);
            app.ExportButtonsLayout.ColumnWidth = ["1x", "1x", "0.5x", "1.5x", "1x"];
            app.ExportButtonsLayout.RowHeight = "1x";
            app.ExportButtonsLayout.Layout.Row = 2;
            app.ExportButtonsLayout.Layout.Column = 1;

            % Create ExportStatusLabel.
            app.ExportStatusLabel = uilabel(app.ExportButtonsLayout);
            app.ExportStatusLabel.Layout.Row = 1;
            app.ExportStatusLabel.Layout.Column = [1, 2];
            app.ExportStatusLabel.Text = "";

            % Create FormatDropDownLabel.
            app.FormatDropDownLabel = uilabel(app.ExportButtonsLayout);
            app.FormatDropDownLabel.HorizontalAlignment = "right";
            app.FormatDropDownLabel.Layout.Row = 1;
            app.FormatDropDownLabel.Layout.Column = 3;
            app.FormatDropDownLabel.Text = "Format:";

            % Create ExportFormatDropDown.
            app.ExportFormatDropDown = uidropdown(app.ExportButtonsLayout);
            app.ExportFormatDropDown.Items = [app.ExportWorkspace, app.ExportMAT, app.ExportManager.SupportedFormats];
            app.ExportFormatDropDown.Enable = "off";
            app.ExportFormatDropDown.Layout.Row = 1;
            app.ExportFormatDropDown.Layout.Column = 4;
            app.ExportFormatDropDown.Value = app.ExportWorkspace;

            % Create ExportButton.
            app.ExportButton = uibutton(app.ExportButtonsLayout, "push");
            app.ExportButton.ButtonPushedFcn = @(~, ~) app.exportButtonPushed();
            app.ExportButton.Enable = "off";
            app.ExportButton.Layout.Row = 1;
            app.ExportButton.Layout.Column = 5;
            app.ExportButton.Text = app.ExportText;

            % Create ExportSettingsPanel.
            app.ExportSettingsPanel = uipanel(app.ExportLayout);
            app.ExportSettingsPanel.Enable = "off";
            app.ExportSettingsPanel.Title = "Settings";
            app.ExportSettingsPanel.Layout.Row = 1;
            app.ExportSettingsPanel.Layout.Column = 1;

            % Populate "Export" tab based on mission.
            app.ExportManager.instantiate(app.ExportSettingsPanel);

            % Create VisualizeTab.
            app.VisualizeTab = uitab(app.TabGroup, Title = "Visualize");

            % Create VisualizeLayout.
            app.VisualizeLayout = uigridlayout(app.VisualizeTab);
            app.VisualizeLayout.ColumnWidth = "1x";
            app.VisualizeLayout.RowHeight = ["4x", "1x"];

            % Create VisualizeSettingsPanel.
            app.VisualizeSettingsPanel = uipanel(app.VisualizeLayout);
            app.VisualizeSettingsPanel.Title = "Settings";
            app.VisualizeSettingsPanel.Layout.Row = 1;
            app.VisualizeSettingsPanel.Layout.Column = 1;

            % Populate "Visualize" tab based on mission.
            app.VisualizationManager.instantiate(app.VisualizeSettingsPanel);

            % Create VisualizeButtonsLayout.
            app.VisualizeButtonsLayout = uigridlayout(app.VisualizeLayout);
            app.VisualizeButtonsLayout.ColumnWidth = ["2x", "2x", "1x", "fit"];
            app.VisualizeButtonsLayout.RowHeight = "1x";
            app.VisualizeButtonsLayout.Layout.Row = 2;
            app.VisualizeButtonsLayout.Layout.Column = 1;

            % Create ShowFiguresButton.
            app.ShowFiguresButton = uibutton(app.VisualizeButtonsLayout, "push");
            app.ShowFiguresButton.ButtonPushedFcn = @(~, ~) app.showFiguresButtonPushed();
            app.ShowFiguresButton.Enable = "off";
            app.ShowFiguresButton.Layout.Row = 1;
            app.ShowFiguresButton.Layout.Column = 2;
            app.ShowFiguresButton.Text = ["Show"; "Figures"];

            % Create SaveFiguresButton.
            app.SaveFiguresButton = uibutton(app.VisualizeButtonsLayout, "push");
            app.SaveFiguresButton.ButtonPushedFcn = @(~, ~) app.saveFiguresButtonPushed();
            app.SaveFiguresButton.Enable = "off";
            app.SaveFiguresButton.Layout.Row = 1;
            app.SaveFiguresButton.Layout.Column = 3;
            app.SaveFiguresButton.Text = ["Save"; "Figures"];

            % Create CloseFiguresButton.
            app.CloseFiguresButton = uibutton(app.VisualizeButtonsLayout, "push");
            app.CloseFiguresButton.ButtonPushedFcn = @(~, ~) app.closeFiguresButtonPushed();
            app.CloseFiguresButton.Enable = "off";
            app.CloseFiguresButton.Layout.Row = 1;
            app.CloseFiguresButton.Layout.Column = 4;
            app.CloseFiguresButton.Text = ["Close"; "Figures"];
        end
    end

    methods (Hidden, Access = private)

        function variableName = createMissionSpecificVariable(app)

            variableName = lower(app.Mission.ShortName) + "Analysis";
            assignin("caller", variableName, app.Model.Analysis.copy());
        end
    end
end
