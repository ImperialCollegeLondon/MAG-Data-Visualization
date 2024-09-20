function v = version()
% VERSION Get MAG software version, compliant with Semantic Versioning
% 2.0.0.

    arguments (Output)
        v (1, 1) string {mustBeVersion}
    end

    persistent ver;

    if isempty(ver)

        location = fileparts(mfilename("fullpath"));
        fileName = fullfile(location, "../../../.env");

        if isfile(fileName)

            env = loadenv(fileName);

            if env.isKey("MAG_DATA_VISUALIZATION_VERSION")
                ver = env("MAG_DATA_VISUALIZATION_VERSION");
            else
                error("Could not determine version from "".env"" file.");
            end
        else

            addOns = matlab.addons.installedAddons();
            locMAG = addOns.Name == "MAG Data Visualization";

            if any(locMAG) && (nnz(locMAG) == 1)
                ver = addOns{locMAG, "Version"};
            else
                error("Could not determine version from AddOns.");
            end
        end
    end

    v = ver;
end

function mustBeVersion(value)

    if ~matches(value, regexpPattern("\d+\.\d+\.\d+"))
        error("Version must be compliant with Semantic Versioning 2.0.0.");
    end
end
