## App

- Add option to set breakpoint for error identifier (as well as error source)

## Software

- Add support for I-ALiRT data with one sensor only
- Use SPICE to convert time from MET (equivalent to SCLK, but in seconds) to UTC
- Remove unnecessary `fullfile`s in `mag.imap.Analysis` default values
- Remove unnecessary description of processing steps
- Fix issue with `mag.imap.view.Field` not coping with one sensor science data missing, but its temperature being available

## Build

- Use of `matlab.addons.toolbox.ToolboxOptions` to replace toolbox template

## CI

- Separate CI tests and packaging into separate GitHub workflows
- `main` branch is no longer "special" and is not packaged up on push
- Tags can be used to create new releases
- Install support packages required for MATLAB tests
