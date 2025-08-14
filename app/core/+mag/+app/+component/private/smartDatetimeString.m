function results = smartDatetimeString(dates)

    results = strings(size(dates));

    if isempty(dates)
        return;
    end

    shortFormat = "dd-MM-yy";
    longFormat = "dd-MM-yy HH:mm:ss";
    hourFormat = "HH:mm:ss";

    if isequal(dates(1), dateshift(dates(1), "start", "day"))
        results(1) = string(dates(1), shortFormat);
    else
        results(1) = string(dates(1), longFormat);
    end

    for i = 2:numel(dates)

        currentDate = dateshift(dates(i), "start", "day");
        previousDate = dateshift(dates(i - 1), "start", "day");

        if isequal(currentDate, previousDate)
            results(i) = string(dates(i), hourFormat);
        elseif isequal(dates(i), currentDate)
            results(i) = string(dates(i), shortFormat);
        else
            results(i) = string(dates(i), longFormat);
        end
    end
end
