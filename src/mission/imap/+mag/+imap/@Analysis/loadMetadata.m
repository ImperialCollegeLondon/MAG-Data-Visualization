function [primarySetup, secondarySetup] = loadMetadata(this)

    % Initialize.
    metadata = mag.meta.Instrument(Mission = mag.meta.Mission.IMAP);
    primarySetup = mag.meta.Setup();
    secondarySetup = mag.meta.Setup();

    metadataProviders = [ ...
        mag.imap.meta.JSON(), ...
        mag.imap.meta.Word(), ...
        mag.imap.meta.Excel(), ...
        mag.imap.meta.GSEOS(), ...
        mag.imap.meta.SID15()];

    % Load instrument and science metadata.
    for mdf = this.MetadataFileNames

        for mdp = metadataProviders

            if mdp.isSupported(mdf)

                mdp.load(mdf, metadata, primarySetup, secondarySetup);
                break;
            end
        end
    end

    % Assign value.
    this.Results.Metadata = metadata;
end
