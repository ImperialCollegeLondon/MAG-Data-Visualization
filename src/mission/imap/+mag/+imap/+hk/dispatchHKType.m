function hk = dispatchHKType(hkData, metadata)
% DISPATCHHKTYPE Dispatch HK data to specific HK class based on its type.

    arguments (Input)
        hkData timetable
        metadata (1, 1) mag.meta.HK
    end

    arguments (Output)
        hk (1, 1) mag.HK
    end

    switch metadata.Type
        case "PROCSTAT"
            hk = mag.imap.hk.Processor(hkData, metadata);
        case "PW"
            hk = mag.imap.hk.Power(hkData, metadata);
        case "SCI"
            hk = mag.imap.hk.Science(hkData, metadata);
        case "SID15"
            hk = mag.imap.hk.SID15(hkData, metadata);
        case "STATUS"
            hk = mag.imap.hk.Status(hkData, metadata);
        otherwise
            error("Unsupported HK of type ""%s"".", metadata.Type);
    end
end
