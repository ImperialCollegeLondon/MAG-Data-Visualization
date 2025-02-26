function [primarySetup, secondarySetup] = loadMetaData(this)

    % Initialize.
    metaData = mag.meta.Instrument(Mission = mag.meta.Mission.IMAP);
    primarySetup = mag.meta.Setup();
    secondarySetup = mag.meta.Setup();

    % Load instrument and science meta data.
    for mdf = this.MetaDataFileNames

        [~, ~, extension] = fileparts(mdf);

        switch extension
            case cellstr(mag.imap.meta.JSON.Extensions)
                loader = mag.imap.meta.JSON(FileName = mdf);
            case cellstr(mag.imap.meta.GSEOS.Extensions)
                loader = mag.imap.meta.GSEOS(FileName = mdf);
            case cellstr(mag.imap.meta.Excel.Extensions)
                loader = mag.imap.meta.Excel(FileName = mdf);
            case cellstr(mag.imap.meta.Word.Extensions)
                loader = mag.imap.meta.Word(FileName = mdf);
            case cellstr(mag.imap.meta.SID15.Extensions)
                loader = mag.imap.meta.SID15(FileName = mdf);
            otherwise
                error("Unsupported meta data extension ""%s"".", extension);
        end

        [metaData, primarySetup, secondarySetup] = loader.load(metaData, primarySetup, secondarySetup);
    end

    % Assign value.
    this.Results.MetaData = metaData;
end
