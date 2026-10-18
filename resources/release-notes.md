## App

- Process data, import existing analyses and export to file formats in the background, so that MATLAB and the app remain responsive
- Processing, import and export can be cancelled while running
- Processing runs on a thread-based worker; if not supported (e.g., for MEX files such as SPICE or CDF), it runs on a process-based worker when Parallel Computing Toolbox is available, or in the foreground otherwise
- Add `BackgroundProcessing` toolbox setting to disable processing in the background

## Analysis

- Faster decoding of dates in science file names, by trying mission-specific formats first
- Faster loading of calibration files
