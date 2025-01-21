function export(data, options)
% EXPORT Export data to specified files with specified format.

    arguments
        data (1, :)
        options.Location (1, 1) string {mustBeFolder}
        options.OverwriteFileName string {mustBeScalarOrEmpty} = string.empty()
        options.Provider (1, 1) mag.io.out.format.Provider
    end

    writer = options.Provider.Writer;
    writer.write(data, options.Provider, Location = options.Location);
end
