function figures = sftPlots(analysis, options)
% SFTPLOTS Create plots for SFT results.

    arguments (Input)
        analysis (1, 1) mag.IMAPAnalysis
        options.Filter duration {mustBeScalarOrEmpty} = duration.empty()
        options.PSDStart datetime {mustBeScalarOrEmpty} = datetime.empty()
        options.PSDDuration (1, 1) duration = hours(1)
        options.SeparateModes (1, 1) logical = true
    end

    arguments (Output)
        figures (1, :) matlab.ui.Figure
    end

    views = mag.graphics.view.View.empty();

    % Crop data.
    if ~isempty(options.Filter)

        croppedAnalysis = analysis.copy();
        croppedAnalysis.Results.cropScience(options.Filter);
    else
        croppedAnalysis = analysis;
    end

    % Separate modes.
    modes = croppedAnalysis.getAllModes();

    if ~options.SeparateModes || isempty(modes)
        modes = croppedAnalysis.Results;
    end

    % Show science and frequency.
    for i = 1:numel(modes)

        views(end + 1) = mag.graphics.view.Field(modes(i)); %#ok<AGROW>

        if ~isempty(options.PSDStart)
            views(end + 1) = mag.graphics.view.Frequency(modes(i), PSDStart = options.PSDStart, PSDDuration = options.PSDDuration); %#ok<AGROW>
        end
    end

    % Show I-ALiRT.
    if ~isempty(croppedAnalysis.Results.IALiRT)
        views(end + 1) = mag.graphics.view.IALiRT(croppedAnalysis.Results);
    end

    % Show timestamp analysis.
    views(end + 1) = mag.graphics.view.Timestamp(analysis.Results);

    % Show HK.
    views(end + 1) = mag.graphics.view.HK(analysis.Results);

    % Generate figures.
    figures = views.visualizeAll();
end
