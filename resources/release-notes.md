## App

- (All) Add "Health" tab to display health check results
- (All) Exported MAT file is renamed to "Analysis (dd-MMM-yyyy HHmmss).mat"

## Software

- (IMAP) Add health checks for secondary currents and voltages, temperatures, saturation, missed ITFs, and activation
- (All) `mag.Instrument/crop` method crops data based on input timerange, not science timerange
- (All) `mag.version` should not return a `datetime`-like string
