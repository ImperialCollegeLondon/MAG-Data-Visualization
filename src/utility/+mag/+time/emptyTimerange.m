function period = emptyTimerange()
% EMPTYTIMERANGE Time range that selects no rows.

    arguments (Output)
        period (1, 1) timerange
    end

    period = timerange(NaT(TimeZone = mag.time.Constant.TimeZone), NaT(TimeZone = mag.time.Constant.TimeZone));
end
