function hk = dispatchHKType(hkData, metadata)
% DISPATCHHKTYPE Dispatch HK data to specific HK class based on its type.

    arguments (Input)
        hkData timetable
        metadata (1, 1) mag.meta.HK
    end

    arguments (Output)
        hk (1, 1) mag.HK
    end

    if isempty(metadata.Type)
        error("mag:hk:UnknownType", "HK type unknown.");
    end

    switch metadata.Type
        case mag.meta.HKType.Power
            hk = mag.imap.hk.Power(hkData, metadata);
        case mag.meta.HKType.Processor
            hk = mag.imap.hk.Processor(hkData, metadata);
        case mag.meta.HKType.Science
            hk = mag.imap.hk.Science(hkData, metadata);
        case mag.meta.HKType.SID15
            hk = mag.imap.hk.SID15(hkData, metadata);
        case mag.meta.HKType.Status
            hk = mag.imap.hk.Status(hkData, metadata);
        otherwise
            error("mag:hk:UnsupportedType", "Unsupported HK of type ""%s"".", metadata.Type);
    end
end
