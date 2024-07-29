function data = import(options)
% IMPORT Import data from specified files with specified format.

    arguments (Input)
        options.FileNames (1, :) string {mustBeFile}
        options.Format (1, 1) mag.io.in.Format
        options.ProcessingSteps (1, :) mag.process.Step = mag.process.Step.empty()
    end

    arguments (Output)
        data (1, :) mag.TimeSeries
    end

    data = mag.TimeSeries.empty();

    for fn = options.FileNames

        [rawData, details] = options.Format.load(fn);

        if ~isempty(rawData)
            data = [data, options.Format.process(rawData, details)]; %#ok<AGROW>
        end
    end

    for ps = options.ProcessingSteps

        for d = data
            d.Data = ps.apply(d.Data, d.MetaData);
        end
    end

    % Combine results by type.
    if isempty(data)
        % do nothing
    elseif isa(data, "mag.Science")
        data = combineScience(data);
    elseif isa(data, "mag.HK")
        data = combineHK(data);
    else
        error("Unsupported class ""%s"".", class(data));
    end
end

function combinedData = combineScience(data)
% COMBINESCIENCE Combine science data.

    arguments (Input)
        data (1, :) mag.Science
    end

    arguments (Output)
        combinedData (1, :) mag.Science
    end

    combinedData = mag.Science.empty();

    % Combine data by sensor.
    metaData = [data.MetaData];
    sensors = unique([metaData.Sensor]);

    for s = sensors

        locSelection = [metaData.Sensor] == s;

        selectedData = data(locSelection);
        selectedMetaData = [selectedData.MetaData];

        td = vertcat(selectedData.Data);

        md = selectedMetaData(1).copy();
        md.set(Mode = selectedMetaData.getDisplay("Mode", "Hybrid"), ...
            DataFrequency = selectedMetaData.getDisplay("DataFrequency"), ...
            PacketFrequency = selectedMetaData.getDisplay("PacketFrequency"), ...
            Timestamp = min([selectedMetaData.Timestamp]));

        combinedData(end + 1) = mag.Science(td, md); %#ok<AGROW>
    end
end

function combinedData = combineHK(data)

    arguments (Input)
        data (1, :) mag.HK
    end

    arguments (Output)
        combinedData (1, :) mag.HK
    end

    combinedData = mag.HK.empty();

    % Combine data by sensor.
    metaData = [data.MetaData];
    types = unique([metaData.Type]);

    for t = types

        locSelection = [metaData.Type] == t;
        selectedData = data(locSelection);

        td = vertcat(selectedData.Data);

        md = selectedData(1).MetaData.copy();
        md.set(Timestamp = min([metaData(locSelection).Timestamp]));

        combinedData(end + 1) = mag.hk.dispatchHKType(td, md); %#ok<AGROW>
    end
end
