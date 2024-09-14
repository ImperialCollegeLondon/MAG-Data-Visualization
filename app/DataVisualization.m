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
        SettingsPanel matlab.ui.container.Panel
        ResultsTab matlab.ui.container.Tab
        ResultsLayout matlab.ui.container.GridLayout
        MetaDataPanel matlab.ui.container.Panel
        MetaDataLayout matlab.ui.container.GridLayout
        SecondaryTextArea matlab.ui.control.TextArea
        PrimaryTextArea matlab.ui.control.TextArea
        InstrumentTextArea matlab.ui.control.TextArea
        ProcessingStepsPanel matlab.ui.container.Panel
        StepsLayout matlab.ui.container.GridLayout
        RampTextArea matlab.ui.control.TextArea
        HKTextArea matlab.ui.control.TextArea
        ScienceTextArea matlab.ui.control.TextArea
        WholeDataTextArea matlab.ui.control.TextArea
        RampDropDown matlab.ui.control.DropDown
        RampModeDropDownLabel matlab.ui.control.Label
        HKDropDown matlab.ui.control.DropDown
        HKDropDownLabel matlab.ui.control.Label
        ScienceDropDown matlab.ui.control.DropDown
        ScienceDropDownLabel matlab.ui.control.Label
        WholeDataDropDown matlab.ui.control.DropDown
        WholeDataDropDownLabel matlab.ui.control.Label
        PerFileTextArea matlab.ui.control.TextArea
        PerFileDropDown matlab.ui.control.DropDown
        PerFileLabel matlab.ui.control.Label
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
        FormatDropDown matlab.ui.control.DropDown
        FormatDropDownLabel matlab.ui.control.Label
        VisualizeTab matlab.ui.container.Tab
        VisualizeLayout matlab.ui.container.GridLayout
        VisualizationOptionsLayout matlab.ui.container.GridLayout
        VisualizationOptionsPanel matlab.ui.container.Panel
        VisualizationTypeListBox matlab.ui.control.ListBox
        VisualizeButtonsLayout matlab.ui.container.GridLayout
        CloseFiguresButton matlab.ui.control.Button
        SaveFiguresButton matlab.ui.control.Button
        ShowFiguresButton matlab.ui.control.Button
    end

    properties (SetAccess = private)
        AppProvider mag.app.Provider {mustBeScalarOrEmpty}
        SelectedControl mag.app.control.Control {mustBeScalarOrEmpty}
    end

    properties (Access = private)
        PreviousError MException {mustBeScalarOrEmpty}
        DebugStatus struct = dbstatus()
    end

    properties (SetObservable, Access = private)
        Analysis mag.imap.Analysis {mustBeScalarOrEmpty}
        Figures (1, :) matlab.ui.Figure
    end

    properties (Dependent, Access = private)
        ResultsLocation (1, 1) string {mustBeFolder}
    end

    methods

        function value = get.ResultsLocation(app)

            if isempty(app.Analysis)
                location = app.LocationEditField.Value;
            else
                location = app.Analysis.Location;
            end

            value = fullfile(location, compose("Results (v%s)", mag.version()));

            if ~isfolder(value)
                mkdir(value);
            end
        end
    end

    methods (Access = private)

        function analysisChanged(app, varargin)

            resultsAvailable = ~isempty(app.Analysis) && ~isempty(app.Analysis.Results.Science);

            % Enable/disable buttons.
            status = matlab.lang.OnOffSwitchState(resultsAvailable);

            [app.FormatDropDown.Enable, app.ExportButton.Enable, app.ShowFiguresButton.Enable, ...
                app.MetaDataPanel.Enable, app.ProcessingStepsPanel.Enable, ...
                app.ExportSettingsPanel.Enable, ...
                app.VisualizationTypeListBox.Enable, app.VisualizationOptionsPanel.Enable] = deal(status);

            % Set values in app.
            if resultsAvailable

                results = app.Analysis.Results;

                instrumentMetaData = compose("%s - BSW: %s - ASW: %s", results.MetaData.Model, results.MetaData.BSW, results.MetaData.ASW);
                primaryMetaData = compose("%s (%s - %s - %s)", results.Primary.MetaData.getDisplay("Sensor"), results.Primary.MetaData.Setup.FEE, results.Primary.MetaData.Setup.Model, results.Primary.MetaData.Setup.Can);
                secondaryMetaData = compose("%s (%s - %s - %s)", results.Secondary.MetaData.getDisplay("Sensor"), results.Secondary.MetaData.Setup.FEE, results.Secondary.MetaData.Setup.Model, results.Secondary.MetaData.Setup.Can);

                if ~isempty(instrumentMetaData)
                    app.InstrumentTextArea.Value = instrumentMetaData;
                end

                if ~isempty(primaryMetaData)
                    app.PrimaryTextArea.Value = primaryMetaData;
                end

                if ~isempty(secondaryMetaData)
                    app.SecondaryTextArea.Value = secondaryMetaData;
                end

                for i = ["PerFile", "WholeData", "Science", "HK", "Ramp"]

                    app.(i + "DropDown").Items = [app.Analysis.(i + "Processing").Name];
                    app.(i + "DropDown").ItemsData = app.Analysis.(i + "Processing");
                    app.(regexprep(i, "(\w{2})(\w+)?", "${lower($1)}$2") + "DropDownValueChanged")();
                end

                app.visualizationTypeListBoxValueChanged();
            else

                app.InstrumentTextArea.Value = char.empty();
                app.PrimaryTextArea.Value = char.empty();
                app.SecondaryTextArea.Value = char.empty();

                for i = ["PerFile", "WholeData", "Science", "HK", "Ramp"]

                    app.(i + "DropDown").Items = "";
                    app.(i + "DropDown").ItemsData = [];
                    app.(i + "TextArea").Value = char.empty();
                end
            end
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

        function updateProcessingStepUI(app, name)

            value = app.(name + "DropDown").Value;

            if ~isempty(value)
                app.(name + "TextArea").Value = value.DetailedDescription;
            end
        end
    end

    methods (Access = private)

        function startup(app)

            % Subscribe to properties.
            app.addlistener("Analysis", "PostSet", @app.analysisChanged);
            app.addlistener("Figures", "PostSet", @app.figuresChanged);
        end

        function processDataButtonPushed(app)

            % Validate location.
            location = app.LocationEditField.Value;
            if isempty(location)

                app.displayAlert("Location is empty.", "Invalid Location");
                return;
            elseif ~isfolder(location)

                app.displayAlert(compose("Location ""%s"" does not exist.", location), "Invalid Location");
                return;
            end

            % Show progress bar.
            closeProgressBar = app.overlayProgressBar("Processing data..."); %#ok<NASGU>

            % Disable warning back-traces.
            previousWarningState = warning("off", "backtrace");
            restoreWarningState = onCleanup(@() warning(previousWarningState));

            % Retrieve data file patterns.
            if isempty(app.EventPatternEditField.Value)
                eventPattern = string.empty();
            else
                eventPattern = split(app.EventPatternEditField.Value, pathsep())';
            end

            if isempty(app.MetaDataPatternEditField.Value)
                metaDataPattern = string.empty();
            else
                metaDataPattern = split(app.MetaDataPatternEditField.Value, pathsep())';
            end

            if isempty(app.HKPatternEditField.Value)
                hkPattern = string.empty();
            else
                hkPattern = split(app.HKPatternEditField.Value, pathsep())';
            end

            % Start analysis.
            try

                app.Analysis = mag.imap.Analysis.start(Location = app.LocationEditField.Value, ...
                    EventPattern = eventPattern, ...
                    MetaDataPattern = metaDataPattern, ...
                    SciencePattern = app.SciencePatternEditField.Value, ...
                    IALiRTPattern = app.IALiRTPatternEditField.Value, ...
                    HKPattern = hkPattern);
            catch exception

                app.displayAlert(exception);
                return;
            end
        end

        function exportButtonPushed(app)

            closeProgressBar = app.overlayProgressBar("Exporting..."); %#ok<NASGU>

            format = app.FormatDropDown.Value;

            switch format
                case "Workspace"

                    if evalin("base", "exist(""analysis"", ""var"")")

                        selectedOption = uiconfirm(app.UIFigure, "Variable <code>analysis</code> already exists in the MATLAB Workspace." + ...
                            " Would you like to overwrite it?", "Variable Already Exists", Interpreter = "html");

                        if ~isequal(selectedOption, "OK")
                            return;
                        end
                    end

                    assignin("base", "analysis", app.Analysis);
                    return;
                case "MAT (Full Analysis)"

                    analysis = app.Analysis;
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

                app.Analysis.export(exportType, Location = app.ResultsLocation, StartTime = startTime, EndTime = endTime);
            catch exception
                app.displayAlert(exception);
            end
        end

        function resetButtonPushed(app, event)

            app.startup();
            app.closeFiguresButtonPushed(event);

            app.Analysis = mag.imap.Analysis.empty();
            app.Figures = matlab.ui.Figure.empty();
        end

        function helpPushToolClicked(app)

            % Show progress bar.
            closeProgressBar = app.overlayProgressBar("Generating diagnostics..."); %#ok<NASGU>

            % Initialize variables to save.
            analysis = app.Analysis;

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

                results = load(fullfile(folder, file));

                for f = string(fieldnames(results))'

                    if isa(results.(f), "mag.imap.Analysis")

                        app.Analysis = results.(f);
                        return;
                    end
                end

                app.displayAlert("No ""mag.imap.Analysis"" found in MAT file.", "Invalid File Selected", "warning");
            end
        end

        function perFileDropDownValueChanged(app)
            app.updateProcessingStepUI("PerFile");
        end

        function wholeDataDropDownValueChanged(app)
            app.updateProcessingStepUI("WholeData");
        end

        function scienceDropDownValueChanged(app)
            app.updateProcessingStepUI("Science");
        end

        function hkDropDownValueChanged(app)
            app.updateProcessingStepUI("HK");
        end

        function rampDropDownValueChanged(app)
            app.updateProcessingStepUI("Ramp");
        end

        function visualizationTypeListBoxValueChanged(app)

            app.SelectedControl = app.VisualizationTypeListBox.ItemsData{app.VisualizationTypeListBox.ValueIndex};
            app.SelectedControl.instantiate(app.VisualizationOptionsPanel);
        end

        function showFiguresButtonPushed(app)

            % Show progress bar.
            closeProgressBar = app.overlayProgressBar("Plotting data..."); %#ok<NASGU>

            % Select plotting function based on plot types.
            try

                if isa(app.SelectedControl, "mag.app.imap.controlAT") || isa(app.SelectedControl, "mag.app.imap.controlCPT")
                    args = {app.Analysis};
                else
                    args = {app.Analysis.Results};
                end

                command = app.SelectedControl.getVisualizeCommand(args{:});
                app.Figures = command.call();
                return;
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

            % Create SettingsPanel.
            app.SettingsPanel = uipanel(app.AnalyzeLayout);
            app.SettingsPanel.Title = "Settings";
            app.SettingsPanel.Layout.Row = 1;
            app.SettingsPanel.Layout.Column = [1 4];

            % Populate "Analyze" tab based on mission.
            analysisManager = app.AppProvider.getAnalysisManager();
            analysisManager.instantiate(app.SettingsPanel);
            analysisManager.reset();

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

            % Create ResultsLayout.
            app.ResultsLayout = uigridlayout(app.ResultsTab);
            app.ResultsLayout.ColumnWidth = "1x";
            app.ResultsLayout.RowHeight = ["1x", "3x"];

            % Create ProcessingStepsPanel.
            app.ProcessingStepsPanel = uipanel(app.ResultsLayout);
            app.ProcessingStepsPanel.Enable = "off";
            app.ProcessingStepsPanel.Title = "Processing Steps";
            app.ProcessingStepsPanel.Layout.Row = 2;
            app.ProcessingStepsPanel.Layout.Column = 1;

            % Create StepsLayout.
            app.StepsLayout = uigridlayout(app.ProcessingStepsPanel);
            app.StepsLayout.ColumnWidth = ["fit", "1x", "2x"];
            app.StepsLayout.RowHeight = ["1x", "1x", "1x", "1x", "1x"];

            % Create PerFileLabel.
            app.PerFileLabel = uilabel(app.StepsLayout);
            app.PerFileLabel.HorizontalAlignment = "right";
            app.PerFileLabel.Layout.Row = 1;
            app.PerFileLabel.Layout.Column = 1;
            app.PerFileLabel.Text = "Per File:";

            % Create PerFileDropDown.
            app.PerFileDropDown = uidropdown(app.StepsLayout);
            app.PerFileDropDown.Items = string.empty();
            app.PerFileDropDown.ValueChangedFcn = @(~, ~) app.perFileDropDownValueChanged();
            app.PerFileDropDown.Layout.Row = 1;
            app.PerFileDropDown.Layout.Column = 2;
            app.PerFileDropDown.Value = string.empty();

            % Create PerFileTextArea.
            app.PerFileTextArea = uitextarea(app.StepsLayout);
            app.PerFileTextArea.Layout.Row = 1;
            app.PerFileTextArea.Layout.Column = 3;

            % Create WholeDataDropDownLabel.
            app.WholeDataDropDownLabel = uilabel(app.StepsLayout);
            app.WholeDataDropDownLabel.HorizontalAlignment = "right";
            app.WholeDataDropDownLabel.Layout.Row = 2;
            app.WholeDataDropDownLabel.Layout.Column = 1;
            app.WholeDataDropDownLabel.Text = "Whole Data:";

            % Create WholeDataDropDown.
            app.WholeDataDropDown = uidropdown(app.StepsLayout);
            app.WholeDataDropDown.Items = string.empty();
            app.WholeDataDropDown.ValueChangedFcn = @(~, ~) app.wholeDataDropDownValueChanged();
            app.WholeDataDropDown.Layout.Row = 2;
            app.WholeDataDropDown.Layout.Column = 2;
            app.WholeDataDropDown.Value = string.empty();

            % Create ScienceDropDownLabel.
            app.ScienceDropDownLabel = uilabel(app.StepsLayout);
            app.ScienceDropDownLabel.HorizontalAlignment = "right";
            app.ScienceDropDownLabel.Layout.Row = 3;
            app.ScienceDropDownLabel.Layout.Column = 1;
            app.ScienceDropDownLabel.Text = "Science:";

            % Create ScienceDropDown.
            app.ScienceDropDown = uidropdown(app.StepsLayout);
            app.ScienceDropDown.Items = string.empty();
            app.ScienceDropDown.ValueChangedFcn = @(~, ~) app.scienceDropDownValueChanged();
            app.ScienceDropDown.Layout.Row = 3;
            app.ScienceDropDown.Layout.Column = 2;
            app.ScienceDropDown.Value = string.empty();

            % Create HKDropDownLabel.
            app.HKDropDownLabel = uilabel(app.StepsLayout);
            app.HKDropDownLabel.HorizontalAlignment = "right";
            app.HKDropDownLabel.Layout.Row = 4;
            app.HKDropDownLabel.Layout.Column = 1;
            app.HKDropDownLabel.Text = "HK:";

            % Create HKDropDown.
            app.HKDropDown = uidropdown(app.StepsLayout);
            app.HKDropDown.Items = string.empty();
            app.HKDropDown.ValueChangedFcn = @(~, ~) app.hkDropDownValueChanged();
            app.HKDropDown.Layout.Row = 4;
            app.HKDropDown.Layout.Column = 2;
            app.HKDropDown.Value = string.empty();

            % Create RampModeDropDownLabel.
            app.RampModeDropDownLabel = uilabel(app.StepsLayout);
            app.RampModeDropDownLabel.HorizontalAlignment = "right";
            app.RampModeDropDownLabel.Layout.Row = 5;
            app.RampModeDropDownLabel.Layout.Column = 1;
            app.RampModeDropDownLabel.Text = "Ramp Mode:";

            % Create RampDropDown.
            app.RampDropDown = uidropdown(app.StepsLayout);
            app.RampDropDown.Items = string.empty();
            app.RampDropDown.ValueChangedFcn = @(~, ~) app.rampDropDownValueChanged();
            app.RampDropDown.Layout.Row = 5;
            app.RampDropDown.Layout.Column = 2;
            app.RampDropDown.Value = string.empty();

            % Create WholeDataTextArea.
            app.WholeDataTextArea = uitextarea(app.StepsLayout);
            app.WholeDataTextArea.Layout.Row = 2;
            app.WholeDataTextArea.Layout.Column = 3;

            % Create ScienceTextArea.
            app.ScienceTextArea = uitextarea(app.StepsLayout);
            app.ScienceTextArea.Layout.Row = 3;
            app.ScienceTextArea.Layout.Column = 3;

            % Create HKTextArea.
            app.HKTextArea = uitextarea(app.StepsLayout);
            app.HKTextArea.Layout.Row = 4;
            app.HKTextArea.Layout.Column = 3;

            % Create RampTextArea.
            app.RampTextArea = uitextarea(app.StepsLayout);
            app.RampTextArea.Layout.Row = 5;
            app.RampTextArea.Layout.Column = 3;

            % Create MetaDataPanel.
            app.MetaDataPanel = uipanel(app.ResultsLayout);
            app.MetaDataPanel.Enable = "off";
            app.MetaDataPanel.Title = "Meta Data";
            app.MetaDataPanel.Layout.Row = 1;
            app.MetaDataPanel.Layout.Column = 1;

            % Create MetaDataLayout.
            app.MetaDataLayout = uigridlayout(app.MetaDataPanel);
            app.MetaDataLayout.ColumnWidth = ["1x", "1x", "1x"];
            app.MetaDataLayout.RowHeight = "1x";

            % Create InstrumentTextArea.
            app.InstrumentTextArea = uitextarea(app.MetaDataLayout);
            app.InstrumentTextArea.Editable = "off";
            app.InstrumentTextArea.Tooltip = "Instrument Meta Data";
            app.InstrumentTextArea.Placeholder = "Instrument...";
            app.InstrumentTextArea.Layout.Row = 1;
            app.InstrumentTextArea.Layout.Column = 1;

            % Create PrimaryTextArea.
            app.PrimaryTextArea = uitextarea(app.MetaDataLayout);
            app.PrimaryTextArea.Editable = "off";
            app.PrimaryTextArea.Tooltip = "Primary Sensor Meta Data";
            app.PrimaryTextArea.Placeholder = "Primary Sensor...";
            app.PrimaryTextArea.Layout.Row = 1;
            app.PrimaryTextArea.Layout.Column = 2;

            % Create SecondaryTextArea.
            app.SecondaryTextArea = uitextarea(app.MetaDataLayout);
            app.SecondaryTextArea.Editable = "off";
            app.SecondaryTextArea.Tooltip = "Secondary Sensor Meta Data";
            app.SecondaryTextArea.Placeholder = "Secondary Sensor...";
            app.SecondaryTextArea.Layout.Row = 1;
            app.SecondaryTextArea.Layout.Column = 3;

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

            % Create FormatDropDown.
            app.FormatDropDown = uidropdown(app.ExportButtonsLayout);
            app.FormatDropDown.Items = ["Workspace", "MAT (Full Analysis)", "MAT (Science Lead)", "CDF"];
            app.FormatDropDown.Enable = "off";
            app.FormatDropDown.Layout.Row = 1;
            app.FormatDropDown.Layout.Column = 4;
            app.FormatDropDown.Value = "Workspace";

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

            % Create VisualizationOptionsLayout.
            app.VisualizationOptionsLayout = uigridlayout(app.VisualizeLayout);
            app.VisualizationOptionsLayout.ColumnWidth = ["1x", "4x"];
            app.VisualizationOptionsLayout.RowHeight = "1x";
            app.VisualizationOptionsLayout.Layout.Row = 1;
            app.VisualizationOptionsLayout.Layout.Column = 1;

            % Create VisualizationTypeListBox.
            app.VisualizationTypeListBox = uilistbox(app.VisualizationOptionsLayout);
            app.VisualizationTypeListBox.ValueChangedFcn = @(~, ~) app.visualizationTypeListBoxValueChanged();
            app.VisualizationTypeListBox.Enable = "off";
            app.VisualizationTypeListBox.Layout.Row = 1;
            app.VisualizationTypeListBox.Layout.Column = 1;
            % app.VisualizationTypeListBox.Items = ["AT, SFT", "CPT", "Science", "Spectrogram", "PSD"];
            % app.VisualizationTypeListBox.ItemsData = [mag.app.imap.control.AT(), mag.app.imap.control.CPT(), mag.app.imap.control.Field(), mag.app.imap.control.Spectrogram(), mag.app.imap.control.PSD()];
            % app.VisualizationTypeListBox.Value = mag.app.imap.control.AT();

            % Create VisualizationOptionsPanel.
            app.VisualizationOptionsPanel = uipanel(app.VisualizationOptionsLayout);
            app.VisualizationOptionsPanel.Enable = "off";
            app.VisualizationOptionsPanel.BorderType = "none";
            app.VisualizationOptionsPanel.Layout.Row = 1;
            app.VisualizationOptionsPanel.Layout.Column = 2;
        end
    end

    methods (Access = public)

        function app = DataVisualization()

            % Create UIFigure and hide until all components are created.
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
                    return;
                case "HelioSwarm"
                    error("HelioSwarm mission not yet supported.");
                case "IMAP"
                    app.AppProvider = mag.app.imap.Provider();
                case "Solar Orbiter"
                    error("Solar Orbiter mission not yet supported.");
            end

            % Show the figure after all components are created.
            app.UIFigure.Visible = "off";
            restoreVisibility = onCleanup(@() set(app.UIFigure, Visible = "on"));

            % Initialize app.
            app.createComponents();
            app.startup();

            if nargout == 0
                clear("app");
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end
