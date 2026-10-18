# MAG Data Visualization Toolbox

[![Imperial College Space Magnetometer Laboratory](https://img.shields.io/badge/Author-Space%20Magnetometer%20Laboratory-ff69b4.svg)][sml]
[![MATLAB Tests](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization-Toolbox/actions/workflows/test.yml/badge.svg)](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization-Toolbox/actions/workflows/test.yml)
[![MATLAB Toolbox](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization-Toolbox/actions/workflows/package.yml/badge.svg)](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization-Toolbox/actions/workflows/package.yml)
[![View MAG Data Visualization Toolbox on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/169568)

MATLAB toolbox for processing, exporting and visualizing magnetometer (MAG) science and housekeeping (HK) data. It includes an app for interactive analysis, as well as functions and classes for scripting.

Supported missions and instruments:

| Mission      | Data processing | Export formats |
| ------------ | :-------------: | -------------- |
| Bartington   | ✓               | –              |
| HelioSwarm   | ✓               | MAT            |
| HENON        | ✓               | –              |
| IMAP         | ✓               | MAT, CDF       |
| Vigil        | ✓               | –              |

## Requirements

MATLAB R2024b or later, with:

* Signal Processing Toolbox
* Statistics and Machine Learning Toolbox
* Text Analytics Toolbox

Optional MATLAB toolboxes:

* **Wavelet Toolbox**: enables the "Wavelet Analyzer" view in the app.
* **Parallel Computing Toolbox**: allows IMAP processing to run in the background (see [Background Processing](#background-processing)).

External libraries, required for IMAP data:

* MATLAB SPICE (MICE): <https://naif.jpl.nasa.gov/naif/toolkit_MATLAB.html>
* MATLAB SPDF CDF: <https://cdf.gsfc.nasa.gov/html/sw_and_docs.html>

## Installation

Install the toolbox from [File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/169568), or from the MATLAB Add-On Explorer by searching for "MAG Data Visualization".

## Getting Started

### App

Open the app from the MATLAB Command Window, optionally specifying the mission:

``` matlab
DataVisualization()        % asks which mission to analyze
DataVisualization("IMAP")  % opens the app for IMAP
```

The app guides you through the workflow, one tab at a time:

1. **Analyze**: select the folder containing the data, adjust the settings and click "Process Data".
2. **Results** and **Health**: check metadata, a preview of the science data, and the results of health checks.
3. **Export**: save the analysis to the MATLAB Workspace, to a MAT file, or to a mission-specific format.
4. **Visualize**: select the views to plot, then show, save or close the figures.

Use the toolbar to change mission, import a previously exported analysis, or report an issue.

### Scripting

All functionality is available under the `mag` namespace; use tab-completion to explore it:

``` matlab
mag.<TAB>
```

For example, to process IMAP data and export it to MAT files:

``` matlab
analysis = mag.imap.Analysis.start(Location = "path/to/data");
analysis.export("MAT", Location = "path/to/results");
```

Each mission provides an equivalent `Analysis` class (`mag.bart.Analysis`, `mag.henon.Analysis`, `mag.hs.Analysis`, `mag.vigil.Analysis`).

### Background Processing

The app processes, imports and exports data in the background, so MATLAB and the app remain responsive. While a task runs, its button changes to "Cancel", and the outcome is shown next to it when it completes. Any output from the processing, such as health check results and warnings, is printed to the Command Window when it completes.

Background tasks run on a thread-based worker. Thread-based workers cannot use MEX files, which IMAP relies on (SPICE and CDF). In that case:

* if Parallel Computing Toolbox is available, the task runs on a process-based worker; a parallel pool with one worker is started the first time, which can take some time;
* otherwise, the task runs in the foreground, blocking the app until it completes.

### Settings

Toolbox settings are stored in the `MAG.Toolbox` group of the MATLAB [settings](https://www.mathworks.com/help/matlab/ref/matlab.settings.settingsgroup.html):

| Setting                | Default | Description                                         |
| ---------------------- | ------- | --------------------------------------------------- |
| `BackgroundProcessing` | `true`  | Whether the app runs processing in the background.  |
| `FigureResolution`     | `300`   | Resolution (in DPI) of saved figures.               |
| `Sound`                | `true`  | Whether to play a sound when app tasks complete.    |

Settings are created the first time they are used. For example, to disable background processing:

``` matlab
mag.internal.ToolboxSettings.getSettingValue("BackgroundProcessing");  % make sure setting exists

s = settings();
s.MAG.Toolbox.BackgroundProcessing.PersonalValue = false;
```

## User Manual

See [internal documentation](https://imperialcollege.atlassian.net/wiki/spaces/PMLSD/pages/453279745/Data+Visualization) on Confluence.

## Development

### Install

Clone this repository and install the package for development:

``` matlab
mpminstall(pwd(), Authoring = true);
```

When developing new features or fixing issues, create a new branch, and write tests to cover any new changes.

### Build and Test

The repository uses the MATLAB build tool. From the repository root, run:

``` matlab
buildtool                           % run default tasks: "check", "test:parallel", "test:serial" and "coverage"
buildtool check                     % check code issues
buildtool test                      % run all unit and system tests serially, including UI tests
buildtool test:parallel -parallel   % run tests tagged "Parallel" on a parallel pool
buildtool test:serial               % run tests that must run serially, excluding UI tests
buildtool test:ui                   % run tests tagged "Interactive", which open UI windows
buildtool install                   % install support packages (".mltbx" files) in the root folder
buildtool coverage                  % merge code coverage of test tasks
buildtool perf                      % measure performance
buildtool package                   % package code into toolbox
```

Only use `-parallel` with `test:parallel`, as other tests (e.g., app tests) cannot run on parallel workers.

Tests are tagged by category, so that they can be selected with any MATLAB test tool:

| Tag           | Description                                                                |
| ------------- | -------------------------------------------------------------------------- |
| `Unit`        | Unit tests, in `tests/unit`.                                               |
| `System`      | System tests, in `tests/system`.                                           |
| `Performance` | Performance tests, in `tests/performance`.                                 |
| `Parallel`    | Tests that do not depend on shared state, and can run on parallel workers. |
| `Interactive` | Tests that interact with visible UI windows, which take focus.             |

For example, to run unit tests, or system tests in parallel where possible:

``` matlab
runtests("tests", IncludeSubfolders = true, Tag = "Unit")
mag.test.runTests(Tag = "System", UseParallel = true)
```

UI gestures (e.g., pressing a button) require visible windows, which bring MATLAB to the front. To avoid disrupting other work, tests tagged `Interactive` are excluded from the default build tasks and from `mag.test.runTests`, unless `Interactive = true` is specified.

Performance tests can be measured with `runperf("tests/performance", IncludeSubfolders = true)`.

IMAP tests require the SPICE and CDF external libraries; tests of the "Wavelet Analyzer" view require Wavelet Toolbox.

### Release

1. Update the version in the package definition file, `resources/mpackage.json`. The toolbox version is derived from it.
2. Describe the changes in `resources/release-notes.md`.

### Uninstall

``` matlab
mpmuninstall("MAGDataVisualization");
```

## License

MAG Data Visualization Toolbox is released under the [MIT license][license].

[license]: LICENSE.md
[sml]: http://www.imperial.ac.uk/space-and-atmospheric-physics/research/areas/space-magnetometer-laboratory/
