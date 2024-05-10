function savePlots(figures, location, options)
% SAVEPLOTS Save plots at specified location.

    arguments
        figures (1, :) matlab.ui.Figure
        location (1, 1) string = "results"
        options.ColonReplacement (1, 1) string = ""
        options.DotReplacement (1, 1) string = "_"
        options.SlashReplacement (1, 1) string = "_"
        options.QuoteReplacement (1, 1) string = "'"
        options.SaveAsFig (1, 1) logical = true
        options.CreateDirectory (1, 1) logical = false
    end

    if options.CreateDirectory

        if ~isfolder(location)
            mkdir(location);
        end
    end

    mustBeFolder(location);

    for f = figures

        if isvalid(f)

            name = replace(f.Name, [":", ".", "/", "\", """"], [options.ColonReplacement, options.DotReplacement, options.SlashReplacement, options.SlashReplacement, options.QuoteReplacement]);
            name = fullfile(location, name);

            exportgraphics(f, fullfile(name + ".png"), Resolution = 300);

            if options.SaveAsFig

                try
                    savefig(f, name);
                catch exception
                    warning("Could not save figure ""%s"":\n%s", f.Name, exception.message);
                end
            end
        end
    end
end
