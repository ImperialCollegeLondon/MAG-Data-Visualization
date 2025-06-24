function data = resampleIrregularData(data)
% RESAMPLEIRREGULARDATA Resample irregular data in a timetable.

    arguments (Input)
        data timetable
    end

    arguments (Output)
        data timetable
    end

    if ~isregular(data)

        dt = diff(data.Properties.RowTimes);
        frequencies = 1 ./ seconds(dt);

        warning("mag:app:NonFiniteData", "Resampling data as not uniformly sampled (%.3f ± %.3g Hz).", mode(frequencies), std(frequencies, 0, "omitmissing"));

        data = resample(data);
    end
end