function results = cropResults(results, startTime, endTime)
% CROPRESULTS Crop results with given start and end times. If times are
% NaT, no cropping is done.

    arguments (Input)
        results (1, 1) mag.Instrument
        startTime (1, 1) datetime
        endTime (1, 1) datetime
    end

    arguments (Output)
        results (1, 1) mag.Instrument
    end

    results = results.copy();
    results.crop(mag.time.closedTimerange(startTime, endTime));
end
