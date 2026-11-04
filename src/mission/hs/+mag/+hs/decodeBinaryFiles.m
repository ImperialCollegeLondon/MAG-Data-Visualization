function decodeBinaryFiles(location)
% DECODEBINARYFILES Decode supported HelioSwarm binary files in location
% into CSV and text files in the same location, using "hs-mag decode" in
% WSL.

    arguments
        location (1, 1) string
    end

    files = dir(fullfile(location, "*"));
    files = files(~[files.isdir]);

    locationWSL = windowsToWSLPath(location);

    for fileIdx = 1:numel(files)

        fileName = string(files(fileIdx).name);
        [isSupported, type, extension] = getBinaryFileType(fileName);

        if ~isSupported
            continue;
        end

        tokens = regexp(fileName, "hs_(\d{8}_\d{6})", "tokens", "once");

        if isempty(tokens)
            timestamp = "unknown";
        else
            timestamp = string(tokens{1});
        end

        inputWSL = replace(fullfile(locationWSL, fileName), "\", "/");
        outputName = compose("%s_%s%s", type, timestamp, extension);
        outputWSL = replace(fullfile(locationWSL, outputName), "\", "/");

        linuxCommand = compose("hs-mag decode '%s' --export-file-name '%s'", inputWSL, outputWSL);
        command = sprintf('wsl bash -lc "%s"', linuxCommand);

        [status, ~] = system(command);

        if status ~= 0
            warning("mag:hs:DecodeFailed", "Failed to decode binary file ""%s"".", fileName);
        end
    end
end

function [isSupported, type, extension] = getBinaryFileType(fileName)

    if contains(fileName, ".361_m128")
        isSupported = true;
        type = "science";
        extension = ".csv";
    elseif contains(fileName, ".360_mhk")
        isSupported = true;
        type = "hk";
        extension = ".csv";
    elseif contains(fileName, ".36e_mid")
        isSupported = true;
        type = "errors";
        extension = ".txt";
    elseif contains(fileName, ".36c_mhkhr")
        isSupported = true;
        type = "full_hk";
        extension = ".csv";
    else
        isSupported = false;
        type = "";
        extension = "";
    end
end

function wslPath = windowsToWSLPath(windowsPath)

    windowsPath = string(windowsPath);

    if contains(windowsPath, ":\")

        driveLetter = lower(extractBefore(windowsPath, 2));
        pathPart = replace(extractAfter(windowsPath, 2), "\", "/");
        wslPath = "/mnt/" + driveLetter + pathPart;
    else
        wslPath = windowsPath;
    end
end
