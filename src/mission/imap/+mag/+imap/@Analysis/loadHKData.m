function loadHKData(this)
    %% Initialize

    if isempty(this.HKFileNames)
        return;
    end

    this.Results.HK = mag.HK.empty();

    %% Import and Process Data

    for hkp = 1:numel(this.HKPattern)

        [~, ~, extension] = fileparts(this.HKPattern(hkp));
        importStrategy = this.dispatchExtension(extension, "HK");

        if ~isempty(this.Results.Science) && ...
                ~isempty(this.Results.Outboard) && ~isempty(this.Results.Outboard.Metadata) && ...
                ~isempty(this.Results.Inboard) && ~isempty(this.Results.Inboard.Metadata)

            importStrategy.SensorSetup = [this.Results.Outboard.Metadata.Setup, this.Results.Inboard.Metadata.Setup];
        end

        hkData = mag.io.import( ...
            FileNames = this.HKFileNames{hkp}, ...
            Format = importStrategy, ...
            ProcessingSteps = this.HKProcessing);

        if ~isempty(hkData)
            this.Results.HK(end + 1) = hkData;
        end
    end

    %% Amend Time Range

    % Concentrate on recorded timerange.
    if ~isempty(this.Results.Metadata) && ~ismissing(this.Results.Metadata.Timestamp)

        for i = 1:numel(this.Results.HK)
            this.Results.HK(i).Data = this.Results.HK(i).Data(timerange(this.Results.Metadata.Timestamp, this.Results.HK(i).Time(end), "closed"), :);
        end
    end
end
