function hk = dispatchHKType(hkData, metaData)
% DISPATCHHKTYPE Dispatch HK data to specific HK class based on its type.

    arguments (Input)
        hkData timetable
        metaData (1, 1) mag.meta.HK
    end

    arguments (Output)
        hk (1, 1) mag.HK
    end

    switch metaData.Type
        case "PROCSTAT"
            hk = mag.imap.hk.Processor(hkData, metaData);
        case "PW"
            hk = mag.imap.hk.Power(hkData, metaData);
        case "SCI"
            hk = mag.imap.hk.Science(hkData, metaData);
        case "SID15"
            hk = mag.imap.hk.SID15(hkData, metaData);
        case "STATUS"
            hk = mag.imap.hk.Status(hkData, metaData);
        otherwise
            error("Unsupported HK of type ""%s"".", metaData.Type);
    end
end
