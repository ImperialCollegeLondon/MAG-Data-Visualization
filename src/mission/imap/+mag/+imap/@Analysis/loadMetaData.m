function [primarySetup, secondarySetup] = loadMetadata(this)

    % Initialize.
    metadata = mag.meta.Instrument(Mission = mag.meta.Mission.IMAP);
    primarySetup = mag.meta.Setup();
    secondarySetup = mag.meta.Setup();

    % Load instrument and science metadata.
    for mdf = this.MetadataFileNames

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
                error("Unsupported metadata extension ""%s"".", extension);
        end

        [metadata, primarySetup, secondarySetup] = loader.load(metadata, primarySetup, secondarySetup);
    end

    % Assign value.
    this.Results.Metadata = metadata;
end
