function export(data, options)
% EXPORT Export data to specified files with specified format.

    arguments
        data (1, :)
        options.Location (1, 1) string {mustBeFolder}
        options.Provider (1, 1) mag.io.out.provide.Provider
    end

    writer = options.Provider.Writer;
    writer.write(data, Location = options.Location, Provider = options.Provider);
end
