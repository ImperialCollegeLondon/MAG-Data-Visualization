classdef (Sealed) DataVisualization < matlab.mixin.SetGet
% DATAVISUALIZATION App for processing, exporting and visualizing MAG data.

    properties (SetAccess = private)
        UIFigure matlab.ui.Figure
        Toolbar matlab.ui.container.Toolbar
        PushTool matlab.ui.container.toolbar.PushTool
        DebugToggleTool matlab.ui.container.toolbar.ToggleTool
        HelpPushTool matlab.ui.container.toolbar.PushTool
        GridLayout matlab.ui.container.GridLayout
        TabGroup matlab.ui.container.TabGroup
        AnalyzeTab matlab.ui.container.Tab
        AnalyzeLayout matlab.ui.container.GridLayout
        VersionLabel matlab.ui.control.Label
        ResetButton matlab.ui.control.Button
        ProcessDataButton matlab.ui.control.Button
        AnalyzeSettingsPanel matlab.ui.container.Panel
        ResultsTab matlab.ui.container.Tab
        ExportTab matlab.ui.container.Tab
        ExportLayout matlab.ui.container.GridLayout
        ExportSettingsPanel matlab.ui.container.Panel
        ExportSettingsLayout matlab.ui.container.GridLayout
        EndTimeEditField matlab.ui.control.EditField
        EndDateTimeDatePicker matlab.ui.control.DatePicker
        EndDateTimeDatePickerLabel matlab.ui.control.Label
        StartTimeEditField matlab.ui.control.EditField
        StartDateTimeDatePicker matlab.ui.control.DatePicker
        StartDateTimeDatePickerLabel matlab.ui.control.Label
        ExportButtonsLayout matlab.ui.container.GridLayout
        ExportNoteLabel matlab.ui.control.Label
        ExportButton matlab.ui.control.Button
        ExportFormatDropDown matlab.ui.control.DropDown
        FormatDropDownLabel matlab.ui.control.Label
        VisualizeTab matlab.ui.container.Tab
        VisualizeLayout matlab.ui.container.GridLayout
        VisualizePanel matlab.ui.container.Panel
        VisualizeButtonsLayout matlab.ui.container.GridLayout
        CloseFiguresButton matlab.ui.control.Button
        SaveFiguresButton matlab.ui.control.Button
        ShowFiguresButton matlab.ui.control.Button
    end

    properties (SetAccess = private)
        Provider mag.app.Provider {mustBeScalarOrEmpty}
        Model mag.app.Model {mustBeScalarOrEmpty} = mag.app.imap.Model.empty()
        AnalysisManager mag.app.Manager {mustBeScalarOrEmpty}
        ResultsManager mag.app.Manager {mustBeScalarOrEmpty}
        VisualizationManager mag.app.Manager {mustBeScalarOrEmpty}
    end

    properties (Access = private)
        PreviousError MException {mustBeScalarOrEmpty}
        DebugStatus struct = dbstatus()
    end

    properties (SetObservable, Access = private)
        Figures (1, :) matlab.ui.Figure
    end

    properties (Dependent, Access = private)
        ResultsLocation (1, 1) string {mustBeFolder}
    end

    methods

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
    end

    methods (Access = private)

        function modelChangedCallback(app, model, ~)

            status = matlab.lang.OnOffSwitchState(model.HasAnalysis);

            [app.ExportFormatDropDown.Enable, app.ExportButton.Enable, app.ExportSettingsPanel.Enable, ...
                app.ShowFiguresButton.Enable] = deal(status);
        end

        function figuresChanged(app, varargin)

            figuresAvailable = ~isempty(app.Figures) && any(isvalid(app.Figures));
            [app.SaveFiguresButton.Enable, app.CloseFiguresButton.Enable] = deal(matlab.lang.OnOffSwitchState(figuresAvailable));
        end

        function displayAlert(app, message, title, icon)

            arguments
                app
                message (1, 1) {mustBeA(message, ["string", "MException"])}
                title (1, 1) string = "Something Went Wrong..."
                icon (1, 1) string {mustBeMember(icon, ["error", "warning", "info", "success", "none"])} = "error"
            end

            if isa(message, "MException")

                app.PreviousError = message;
                msg = message.message;
            else
                msg = message;
            end

            uialert(app.UIFigure, msg, title, Icon = icon, Interpreter = "html");
        end

        function closeProgressBar = overlayProgressBar(app, message)

            arguments (Input)
                app
                message (1, 1) string
            end

            arguments (Output)
                closeProgressBar (1, 2) onCleanup
            end

            progressBar = uiprogressdlg(app.UIFigure, Message = message, Icon = "info", Indeterminate = "on");
            closeProgressBar = [onCleanup(@() delete(progressBar)), onCleanup(@() beep())];
        end
    end

    methods (Access = private)

        function processDataButtonPushed(app)

            % Show progress bar.
            closeProgressBar = app.overlayProgressBar("Processing data..."); %#ok<NASGU>

            % Disable warning back-traces.
            previousWarningState = warning("off", "backtrace");
            restoreWarningState = onCleanup(@() warning(previousWarningState));

            % Start analysis.
            try
                app.Model.analyze(app.AnalysisManager);
            catch exception
                app.displayAlert(exception);
            end
        end

        function exportButtonPushed(app)

            closeProgressBar = app.overlayProgressBar("Exporting..."); %#ok<NASGU>

            format = app.ExportFormatDropDown.Value;

            switch format
                case "Workspace"

                    if evalin("base", "exist(""analysis"", ""var"")")

                        selectedOption = uiconfirm(app.UIFigure, "Variable <code>analysis</code> already exists in the MATLAB Workspace." + ...
                            " Would you like to overwrite it?", "Variable Already Exists", Interpreter = "html");

                        if ~isequal(selectedOption, "OK")
                            return;
                        end
                    end

                    assignin("base", "analysis", app.Model.Analysis);
                    return;
                case "MAT (Full Analysis)"

                    analysis = app.Model.Analysis;
                    save(fullfile(app.ResultsLocation, "Data.mat"), "analysis");
                    return;
                case "MAT (Science Lead)"
                    exportType = "MAT";
                case "CDF"
                    exportType = "CDF";
                otherwise
                    app.displayAlert(compose("Unrecognized export format option ""%s"".", format));
            end

            try

                startTime = mag.app.internal.combineDateAndTime(app.StartDateTimeDatePicker.Value, app.StartTimeEditField.Value);
                endTime = mag.app.internal.combineDateAndTime(app.EndDateTimeDatePicker.Value, app.EndTimeEditField.Value);

                app.Model.Analysis.export(exportType, Location = app.ResultsLocation, StartTime = startTime, EndTime = endTime);
            catch exception
                app.displayAlert(exception);
            end
        end

        function resetButtonPushed(app, event)

            app.startup();
            app.closeFiguresButtonPushed(event);

            app.Figures = matlab.ui.Figure.empty();
        end

        function helpPushToolClicked(app)

            % Show progress bar.
            closeProgressBar = app.overlayProgressBar("Generating diagnostics..."); %#ok<NASGU>

            % Initialize variables to save.
            analysis = app.Model.Analysis;

            exportStartDate = app.StartDateTimeDatePicker.Value;
            exportStartTime = app.StartTimeEditField.Value;
            exportEndDate = app.EndDateTimeDatePicker.Value;
            exportEndTime = app.EndTimeEditField.Value;

            selectedControl = app.SelectedControl;

            % Create folder to zip.
            statusFolder = tempname();
            zipFolder = statusFolder + ".zip";

            mkdir(statusFolder);
            deleteFolder = onCleanup(@() rmdir(statusFolder, "s"));

            % Create MAT file with variables.
            save(fullfile(statusFolder, "data.mat"), "analysis", ...
                "exportStartDate", "exportStartTime", "exportEndDate", "exportEndTime", ...
                "selectedControl");
            exportapp(app.UIFigure, fullfile(statusFolder, "app.png"));

            zip(zipFolder, statusFolder);
            clipboard("copy", zipFolder);

            % Show dialog.
            app.displayAlert(compose("Share ZIP file ""%s""" + newline() + "with the developer. Path copied to clipboard.", zipFolder), "Share Diagnostics", "info");
        end

        function debugToggleToolOn(app)

            app.DebugStatus = dbstatus();

            if ~isempty(app.PreviousError)

                stack = app.PreviousError.stack;
                dbstop("in", stack(1).file, "at", num2str(stack(1).line));
            end
        end

        function debugToggleToolOff(app)

            dbclear("all");
            dbstop(app.DebugStatus);
        end

        function pushToolClicked(app)

            [file, folder] = uigetfile("*.mat", "Import Analysis");

            if ~isequal(file, 0) && ~isequal(folder, 0)

                try
                    app.Model.load(fullfile(folder, file));
                catch exception
                    app.displayAlert(exception);
                end
            end
        end

        function showFiguresButtonPushed(app)

            % Show progress bar.
            closeProgressBar = app.overlayProgressBar("Plotting data..."); %#ok<NASGU>

            % Select plotting function based on plot types.
            try
                app.Figures = app.VisualizationManager.visualize(app.Model.Analysis);
            catch exception
                app.displayAlert(exception);
            end
        end

        function saveFiguresButtonPushed(app)

            closeProgressBar = app.overlayProgressBar("Saving figures..."); %#ok<NASGU>

            try
                mag.graphics.savePlots(app.Figures, app.ResultsLocation);
            catch exception
                app.displayAlert(exception);
            end
        end

        function closeFiguresButtonPushed(app)

            isValidFigures = isvalid(app.Figures);

            if ~isempty(app.Figures) && any(isValidFigures)

                closeProgressBar = app.overlayProgressBar("Closing figures..."); %#ok<NASGU>
                close(app.Figures(isValidFigures));

                app.Figures = matlab.ui.Figure.empty();
            end
        end
    end

    methods (Access = private)

        function createComponents(app)

            % Get the file path for locating images.
            pathToAppIcons = fullfile(fileparts(mfilename("fullpath")), "icons");

            % Create Toolbar.
            app.Toolbar = uitoolbar(app.UIFigure);

            % Create PushTool.
            app.PushTool = uipushtool(app.Toolbar);
            app.PushTool.Tooltip = "Import existing analysis";
            app.PushTool.ClickedCallback = @(~, ~) app.pushToolClicked();
            app.PushTool.Icon = fullfile(pathToAppIcons, "import.png");

            % Create DebugToggleTool.
            app.DebugToggleTool = uitoggletool(app.Toolbar);
            app.DebugToggleTool.Tooltip = "Set break point at last error source";
            app.DebugToggleTool.Icon = fullfile(pathToAppIcons, "debug.png");
            app.DebugToggleTool.Separator = "on";
            app.DebugToggleTool.OffCallback = @(~, ~) app.debugToggleToolOff();
            app.DebugToggleTool.OnCallback = @(~, ~) app.debugToggleToolOn();

            % Create HelpPushTool.
            app.HelpPushTool = uipushtool(app.Toolbar);
            app.HelpPushTool.Tooltip = "Share debugging information with development";
            app.HelpPushTool.ClickedCallback = @(~, ~) app.helpPushToolClicked();
            app.HelpPushTool.Icon = fullfile(pathToAppIcons, "help.png");

            % Create GridLayout.
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.RowHeight = "1x";

            % Create TabGroup.
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = 1;
            app.TabGroup.Layout.Column = [1 2];

            % Create AnalyzeTab.
            app.AnalyzeTab = uitab(app.TabGroup);
            app.AnalyzeTab.Title = "Analyze";

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
            app.AnalysisManager.reset();

            % Create ProcessDataButton.
            app.ProcessDataButton = uibutton(app.AnalyzeLayout, "push");
            app.ProcessDataButton.ButtonPushedFcn = @(~, ~) app.processDataButtonPushed();
            app.ProcessDataButton.Layout.Row = 2;
            app.ProcessDataButton.Layout.Column = 3;
            app.ProcessDataButton.Text = "Process Data";

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

            % Create ResultsTab.
            app.ResultsTab = uitab(app.TabGroup);
            app.ResultsTab.Title = "Results";

            % Populate "Results" tab based on mission.
            app.ResultsManager.instantiate(app.ResultsTab);
            app.ResultsManager.reset();

            % Create ExportTab.
            app.ExportTab = uitab(app.TabGroup);
            app.ExportTab.Title = "Export";

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

            % Create FormatDropDownLabel.
            app.FormatDropDownLabel = uilabel(app.ExportButtonsLayout);
            app.FormatDropDownLabel.HorizontalAlignment = "right";
            app.FormatDropDownLabel.Layout.Row = 1;
            app.FormatDropDownLabel.Layout.Column = 3;
            app.FormatDropDownLabel.Text = "Format:";

            % Create ExportFormatDropDown.
            app.ExportFormatDropDown = uidropdown(app.ExportButtonsLayout);
            app.ExportFormatDropDown.Items = ["Workspace", "MAT (Full Analysis)", "MAT (Science Lead)", "CDF"];
            app.ExportFormatDropDown.Enable = "off";
            app.ExportFormatDropDown.Layout.Row = 1;
            app.ExportFormatDropDown.Layout.Column = 4;
            app.ExportFormatDropDown.Value = "Workspace";

            % Create ExportButton.
            app.ExportButton = uibutton(app.ExportButtonsLayout, "push");
            app.ExportButton.ButtonPushedFcn = @(~, ~) app.exportButtonPushed();
            app.ExportButton.Enable = "off";
            app.ExportButton.Layout.Row = 1;
            app.ExportButton.Layout.Column = 5;
            app.ExportButton.Text = "Export";

            % Create ExportNoteLabel.
            app.ExportNoteLabel = uilabel(app.ExportButtonsLayout);
            app.ExportNoteLabel.Layout.Row = 1;
            app.ExportNoteLabel.Layout.Column = [1 2];
            app.ExportNoteLabel.Text = ["Note: Export start and end times do not apply"; "to ""Workspace"" and ""MAT (Full Analysis)"""; "formats."];

            % Create ExportSettingsPanel.
            app.ExportSettingsPanel = uipanel(app.ExportLayout);
            app.ExportSettingsPanel.Enable = "off";
            app.ExportSettingsPanel.Title = "Settings";
            app.ExportSettingsPanel.Layout.Row = 1;
            app.ExportSettingsPanel.Layout.Column = 1;

            % Create ExportSettingsLayout.
            app.ExportSettingsLayout = uigridlayout(app.ExportSettingsPanel);
            app.ExportSettingsLayout.ColumnWidth = ["1x", "2x", "2x"];
            app.ExportSettingsLayout.RowHeight = ["1x", "1x", "1x", "1x"];

            % Create StartDateTimeDatePickerLabel.
            app.StartDateTimeDatePickerLabel = uilabel(app.ExportSettingsLayout);
            app.StartDateTimeDatePickerLabel.HorizontalAlignment = "right";
            app.StartDateTimeDatePickerLabel.Layout.Row = 1;
            app.StartDateTimeDatePickerLabel.Layout.Column = 1;
            app.StartDateTimeDatePickerLabel.Text = "Start Date/Time:";

            % Create StartDateTimeDatePicker.
            app.StartDateTimeDatePicker = uidatepicker(app.ExportSettingsLayout);
            app.StartDateTimeDatePicker.Layout.Row = 1;
            app.StartDateTimeDatePicker.Layout.Column = 2;

            % Create StartTimeEditField.
            app.StartTimeEditField = uieditfield(app.ExportSettingsLayout, "text");
            app.StartTimeEditField.Placeholder = "HH:mm:ss.SSS";
            app.StartTimeEditField.Layout.Row = 1;
            app.StartTimeEditField.Layout.Column = 3;

            % Create EndDateTimeDatePickerLabel.
            app.EndDateTimeDatePickerLabel = uilabel(app.ExportSettingsLayout);
            app.EndDateTimeDatePickerLabel.HorizontalAlignment = "right";
            app.EndDateTimeDatePickerLabel.Layout.Row = 2;
            app.EndDateTimeDatePickerLabel.Layout.Column = 1;
            app.EndDateTimeDatePickerLabel.Text = "End Date/Time:";

            % Create EndDateTimeDatePicker.
            app.EndDateTimeDatePicker = uidatepicker(app.ExportSettingsLayout);
            app.EndDateTimeDatePicker.Layout.Row = 2;
            app.EndDateTimeDatePicker.Layout.Column = 2;

            % Create EndTimeEditField.
            app.EndTimeEditField = uieditfield(app.ExportSettingsLayout, "text");
            app.EndTimeEditField.Placeholder = "HH:mm:ss.SSS";
            app.EndTimeEditField.Layout.Row = 2;
            app.EndTimeEditField.Layout.Column = 3;

            % Create VisualizeTab.
            app.VisualizeTab = uitab(app.TabGroup);
            app.VisualizeTab.Title = "Visualize";

            % Create VisualizeLayout.
            app.VisualizeLayout = uigridlayout(app.VisualizeTab);
            app.VisualizeLayout.ColumnWidth = "1x";
            app.VisualizeLayout.RowHeight = ["4x", "1x"];

            % Create VisualizePanel.
            app.VisualizePanel = uipanel(app.VisualizeLayout);
            app.VisualizePanel.Layout.Row = 1;
            app.VisualizePanel.Layout.Column = 1;

            % Populate "Visualize" tab based on mission.
            app.VisualizationManager.instantiate(app.VisualizePanel);
            app.VisualizationManager.reset();

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

    methods (Access = public)

        function app = DataVisualization()

            % Create figure and hide until all components are created.
            app.UIFigure = uifigure();
            app.UIFigure.Position = [100 100 694 429];
            app.UIFigure.Name = "MAG Data Visulization App";
            app.UIFigure.Resize = "off";

            % Ask which mission to load.
            selection = uiconfirm(app.UIFigure, "Select the mission to load.", "Select Mission", Icon = "question", ...
                Options = ["HelioSwarm", "IMAP", "Solar Orbiter", "Cancel"], DefaultOption = "IMAP", CancelOption = "Cancel");

            switch selection
                case "Cancel"

                    delete(app);
                    clear("app");
                    return;
                case "HelioSwarm"
                    error("HelioSwarm mission not yet supported.");
                case "IMAP"
                    app.Provider = mag.app.imap.Provider();
                case "Solar Orbiter"
                    error("Solar Orbiter mission not yet supported.");
            end

            % Show the figure after all components are created.
            app.UIFigure.Visible = "off";
            restoreVisibility = onCleanup(@() set(app.UIFigure, Visible = "on"));

            % Set managers.
            app.Model = app.Provider.getModel();
            app.AnalysisManager = app.Provider.getAnalysisManager();
            app.ResultsManager = app.Provider.getResultsManager();
            app.VisualizationManager = app.Provider.getVisualizationManager();

            for manager = [app.AnalysisManager, app.ResultsManager, app.VisualizationManager]
                manager.subscribe(app.Model);
            end

            % Initialize app.
            app.createComponents();
            app.addlistener("Figures", "PostSet", @app.figuresChanged);
            app.Model.addlistener("AnalysisChanged", @app.modelChangedCallback);

            if nargout == 0
                clear("app");
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end
