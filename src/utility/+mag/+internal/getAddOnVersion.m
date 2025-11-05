function ver = getAddOnVersion(root)
% GETADDONVERSION Retrieve version of installed AddOn.

    arguments
        root (1, 1) string {mustBeFolder}
    end

    addon = fullfile(root, "resources", "addons_core.xml");

    if isfile(addon)

        details = readstruct(addon);
        ver = details.version;
    else
        error("mag:version:NotAnAddOn", "Could not determine version from AddOns.");
    end

    % Sometimes, the version gets loaded as a datetime!
    if isdatetime(ver)
        ver = compose("%d.%d.%d", ver.Day, ver.Month, ver.Year);
    end
end
