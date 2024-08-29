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
    for m = modes

        views(end + 1) = mag.graphics.view.Field(m); %#ok<AGROW>

        if ~isempty(options.PSDStart)

            % Crop the first and last few seconds of the mode, to avoid
            % plotting wrongful information.
            if range(m.TimeRange) > minutes(2)
                m.crop([seconds(30), seconds(-30)]);
            end

            views(end + 1) = mag.graphics.view.Frequency(m, PSDStart = options.PSDStart, PSDDuration = options.PSDDuration); %#ok<AGROW>
        end
    end

    % Show I-ALiRT.
    if ~isempty(croppedAnalysis.Results.IALiRT)
        views(end + 1) = mag.graphics.view.Field(croppedAnalysis.Results.IALiRT);
    end

    % Show science comparison.
    views(end + 1) = mag.graphics.view.Comparison(croppedAnalysis.Results);

    % Show timestamp analysis.
    views(end + 1) = mag.graphics.view.Timestamp(analysis.Results);

    % Show HK.
    views(end + 1) = mag.graphics.view.HK(analysis.Results);

    % Generate figures.
    figures = views.visualizeAll();
end
