> [!WARNING]  
> Starting v7.2.0, [MATLAB SPICE (MICE)](https://naif.jpl.nasa.gov/naif/toolkit_MATLAB.html) is required.
> Starting v7.2.0, MATLAB R2023b is no longer supported.

## Software

- Update `README` to include required Support Packages
- Remove `mag.Science/computePSD` method (use `mag.psd` instead)
- Fix issues with plotting IMAP HK and timestamp analysis with one sensor data missing
- Fix issues with methods of `mag.Science` with no data
- Add tests for `mag.Spectrum` and `mag.spectrogram`
