function figures = cptPlots(analysis, options)
% CPTPLOTS Create plots for CPT results.

    arguments
        analysis (1, 1) mag.imap.Analysis
        options.Filter duration {mustBeScalarOrEmpty} = duration.empty()
        options.PrimaryModePattern (1, :) double = [2, 64, 4, 64, 4, 128]
        options.SecondaryModePattern (1, :) double = [2, 8, 1, 64, 4, 128]
        options.RangePattern (1, :) double = [3, 2, 1, 0]
    end

    views = mag.graphics.view.View.empty();

    % Crop data.
    if ~isempty(options.Filter)

        analysis = analysis.copy();
        analysis.Results.cropScience(options.Filter);
    end

    %% Standard Plots

    figures = mag.graphics.sftPlots(analysis, SeparateModes = false);

    %% Modes

    modeCycling = analysis.getModeCycling(PrimaryPattern = options.PrimaryModePattern, SecondaryPattern = options.SecondaryModePattern);

    if ~isempty(modeCycling)

        views(end + 1) = mag.graphics.view.Field(modeCycling, Events = "Mode", Name = "Mode Cycling", Title = string.empty());
        views(end + 1) = mag.graphics.view.EventPSD(modeCycling, Name = "Mode Cycling PSD Analysis", Event = "DataFrequency");
    end

    %% Ranges

    rangeCycling = analysis.getRangeCycling(Pattern = options.RangePattern);

    if ~isempty(rangeCycling) && rangeCycling.HasData

        % Plot all ranges and PSDs.
        views(end + 1) = mag.graphics.view.Field(rangeCycling, Events = "Range", Name = "Range Cycling", Title = string.empty());
        views(end + 1) = mag.graphics.view.EventPSD(rangeCycling, Name = "Range Cycling PSD Analysis", Event = "Range");

        % Plot ranges without range 0.
        locNoRangeZero = (rangeCycling.Primary.Range ~= 0) & (rangeCycling.Secondary.Range ~= 0);

        if nnz(locNoRangeZero) > 0

            noRange0Cycling = rangeCycling.copy();
            noRange0Cycling.crop(timerange(rangeCycling.Primary.Events.Time(1), rangeCycling.Primary.Events.Time(end), "openright"), ...
                timerange(rangeCycling.Secondary.Events.Time(1), rangeCycling.Secondary.Events.Time(end), "openright"));

            views(end + 1) = mag.graphics.view.Field(noRange0Cycling, Events = "Range", Name = "Range Cycling (No Range 0)", Title = string.empty());
        end
    end

    %% Ramp

    rampMode = analysis.getRampMode();

    if ~isempty(rampMode)
        views(end + 1) = mag.graphics.view.RampMode(rampMode);
    end

    %% Final Normal Mode

    finalNormal = analysis.getFinalNormalMode();

    if ~isempty(finalNormal) && finalNormal.HasData
        views(end + 1) = mag.graphics.view.Field(finalNormal, Name = "Normal Mode (CPT End)", Title = string.empty());
    end

    %% Visualize

    figures = [figures, views.visualizeAll()];
end


