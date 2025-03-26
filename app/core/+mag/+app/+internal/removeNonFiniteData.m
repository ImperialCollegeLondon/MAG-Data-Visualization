function data = removeNonFiniteData(data)
% REMOVENONFINITEDATA Remove non-finite data from table or timetable.

    arguments (Input)
        data tabular
    end

    arguments (Output)
        data tabular
    end

    locNonFinite = ~isfinite(data.Variables);

    if any(locNonFinite, "all")

        warning("mag:app:nonFiniteData", "Removing non-finite data.");
        data(any(locNonFinite, 2), :) = [];
    end
end
