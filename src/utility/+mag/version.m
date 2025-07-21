function v = version()
% VERSION Get MAG software version, compliant with Semantic Versioning
% 2.0.0.

    arguments (Output)
        v (1, 1) string {mustBeVersion}
    end

    persistent ver;

    if isempty(ver)

        ver = mag.internal.getPackageDetails("Version");

        % Look for installed toolbox.
        if isempty(ver)

            root = fullfile(fileparts(mfilename("fullpath")), "../../../");
            addon = fullfile(root, "resources", "addons_core.xml");

            if isfile(addon)

                details = readstruct(addon);
                ver = details.version;
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
