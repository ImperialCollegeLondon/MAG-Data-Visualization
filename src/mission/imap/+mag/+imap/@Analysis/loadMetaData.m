function [primarySetup, secondarySetup] = loadMetaData(this)
    %%  Initialize

    metaData = mag.meta.Instrument();
    primarySetup = mag.meta.Setup();
    secondarySetup = mag.meta.Setup();

    %% Instrument and Science Meta Data

    for mdf = this.MetaDataFileNames

        [~, ~, extension] = fileparts(mdf);

        switch extension
            case cellstr(mag.meta.log.GSEOS.Extensions)
                loader = mag.meta.log.GSEOS(FileName = mdf);
            case cellstr(mag.meta.log.Excel.Extensions)
                loader = mag.meta.log.Excel(FileName = mdf);
            case cellstr(mag.meta.log.Word.Extensions)
                loader = mag.meta.log.Word(FileName = mdf);
            case cellstr(mag.meta.log.SID15.Extensions)
                loader = mag.meta.log.SID15(FileName = mdf);
            otherwise
                error("Unsupported meta data extension ""%s"".", extension);
        end

        [metaData, primarySetup, secondarySetup] = loader.load(metaData, primarySetup, secondarySetup);
    end

    %% Assign Value

    this.Results.MetaData = metaData;
end
