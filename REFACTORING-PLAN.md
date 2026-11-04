# Refactoring and Packaging Plan

Review of the MAG Data Visualization repository on 2026-11-02, at commit `2d3be2e3` (version 10.0.1), using MATLAB R2026b.

Findings are marked as one of:

- **Reproduced**: the behavior was seen by running the code in R2026b.
- **By reading**: found in the code, not run.

## Summary

- **Bugs come first.** 11 bugs were reproduced, including crashes in time-windowed export, IMAP CDF export and I-ALiRT import.
- **The schema upgrade is blocked by one line.** On R2025a, `matlab.mpm.Package` at [buildfile.m:16](buildfile.m#L16) rejects schema 1.2.0. Building once on R2026b and installing on older releases removes that constraint, but the install step has never been tested.
- **Duplication is concentrated in the smaller missions.** 10.9% of `src` and `app` code lines are in clones of 8 or more lines. The HENON and Vigil app layers are 97% duplicated, Vigil and HENON source about 60%, and IMAP source only 1%.
- **Complexity is an IMAP problem.** Only 12 of 1,007 functions exceed a cyclomatic complexity of 10, and 9 of those are IMAP. `loadEventsData` is at 44; the next highest is 16.
- **Code style is in good shape.** Code Analyzer reports 23 info-level notes, with the repository's configuration.

## Order of work

| Phase | Work | Why in this position |
| ----- | ---- | -------------------- |
| 1 | Test installing an R2026b-built toolbox on older releases | The packaging plan depends on the result |
| 2 | Fix bugs | They affect users today |
| 3 | Add the test safety net | Refactoring needs it |
| 4 | Move to a single-build pipeline and schema 1.2.0 | Unblocks the manifest and gates releases |
| 5 | Remove mission and app duplication | Low risk, removes the most code |
| 6 | Simplify IMAP | Highest risk, so it needs phase 3 |
| 7 | Performance and cleanup | Can be done at any time |

## Phase 1: Test the install on older releases

**Done, and passed on 2026-11-02.** A throwaway workflow packaged the commit under test with R2026b, then installed that `.mltbx` with `matlab.addons.install` on GitHub's Windows runners, so the result applies to the current code and not to a published release. The toolbox embeds a schema 1.2.0 manifest in both runs below. The second run also bumped `resources/mpackage.json` in the checkout to schema 1.2.0, to match the state after phase 4.

| Release | Installed to | Listed by MPM | Checkout on 1.1.0 ([run](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization/actions/runs/41455765137)) | Checkout on 1.2.0 ([run](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization/actions/runs/41462781733)) |
| ------- | ------------ | ------------- | ----- | ----- |
| R2025a | `Toolboxes` add-on folder | No | Passed | Passed |
| R2025b | `Toolboxes` add-on folder | No | Passed | Passed |
| R2026a | `Toolboxes` add-on folder | No | Passed | Passed |
| R2026b (control) | `MAGDataVisualization@<version>` | Yes | Passed | Passed |

- [x] Add a throwaway workflow that installs a toolbox built with R2026b on R2025a, R2025b and R2026a. It installs the toolbox built from the commit under test, instead of a release asset.
- [x] On each release, check `mag.version()`, object creation for each mission, and that no manifest warnings appear. The check also processed HENON and Vigil data, plotted a figure and opened the app, with the code resolving to the add-on folder.

Releases before R2026b install the toolbox as a classic add-on and do not read the embedded manifest with MPM, so the schema error from `matlab.mpm.Package` does not apply. This means phase 4 can go ahead as planned, and the `jsondecode` fallback is not needed.

This covers Windows only, and did not exercise IMAP processing, which needs the SPICE and CDF support packages. Phase 4 runs the full test suite against the installed toolbox, which covers those.

## Phase 2: Fix bugs

### Reproduced

- [x] [export.m:38](src/mission/imap/+mag/+imap/@Analysis/export.m#L38): a time-windowed export crashes when any mode is outside the window, because the cropped mode has a `NaT` timestamp and `datestr` fails.
- [x] [export.m:13](src/mission/imap/+mag/+imap/@Analysis/export.m#L13) and [ExportManager.m:34](app/mission/imap/+mag/+app/+imap/ExportManager.m#L34): IMAP CDF export cannot work. `mag.imap.out.HKCDF` does not exist, the app passes a `<missing>` format, as `extractBefore("CDF", " ")` finds no space, and `ScienceCDF` needs a `mag.Science` and a skeleton file, but `Analysis.export` provides neither. The option was removed from `Analysis.export` and the app; `ScienceCDF` is kept. If CDF export is needed, it should be implemented as a new feature.
- [x] [bart Analysis.m:93](src/mission/bart/+mag/+bart/Analysis.m#L93) and [hs Analysis.m:134](src/mission/hs/+mag/+hs/Analysis.m#L134): validators accept formats with no class (Bartington MAT, HelioSwarm CDF).
- [x] [export.m:45](src/mission/imap/+mag/+imap/@Analysis/export.m#L45): export permanently crops the I-ALiRT data of the analysis (65 rows became 54), as `crop` runs on the original handle rather than a copy.
- [x] [ScienceCSV.m:54](src/mission/imap/+mag/+imap/+in/ScienceCSV.m#L54): the date regex runs on the full path. A hyphenated path crashed I-ALiRT import, and a folder such as `2024-05-07` gives the same two regex matches.
- [x] [loadScienceData.m:22](src/mission/imap/+mag/+imap/@Analysis/loadScienceData.m#L22): L1b data with only one sensor crashes.
- [x] [EventFilter.m:136](src/analyze/+mag/+process/EventFilter.m#L136): a range change in the last 5 samples adds fake rows (20 in, 23 out), as there is no upper bound check.
- [x] [findModeChanges.m:114](src/mission/imap/+mag/+imap/@Analysis/findModeChanges.m#L114): slow-to-fast mode changes are not located, because `ddt` is signed (true change at t=100, estimate stayed at t=112). Fast-to-slow works. This is likely related to issue #34, and the fix will change baselines.
- [x] [findModeChanges.m:108](src/mission/imap/+mag/+imap/@Analysis/findModeChanges.m#L108): index 0 crash when the first time step in the search window is unconventional.
- [x] [JSON.m:74](src/mission/imap/+mag/+imap/+meta/JSON.m#L74): the error path uses an undefined `fileName`, so the real message is lost.
- [x] [Analysis.m:66](src/mission/imap/+mag/+imap/@Analysis/Analysis.m#L66): `start(Processing = ...)` is silently overwritten.

### By reading

- [x] [export.m:54](src/mission/imap/+mag/+imap/@Analysis/export.m#L54): range-cycling and ramp exports ignore the time window.
- [x] `load()` in [Analysis.m](src/mission/imap/+mag/+imap/@Analysis/Analysis.m) never clears `PrimaryRamp` and `SecondaryRamp`, so a reload can keep stale data.
- [x] [Analysis.m:212](src/mission/imap/+mag/+imap/@Analysis/Analysis.m#L212): `getAllModes` assumes both sensors have the same number of periods. Reproduced: it crashed with fewer secondary modes, and silently mislabeled data with fewer primary modes. It now warns and does not split by mode.
- [x] [updateRampModeTimestamps.m](src/mission/imap/+mag/+imap/@Analysis/updateRampModeTimestamps.m): a ramp as the last logged event, or ending with the data, would index past the table.
- [x] [DataVisualization.m:261](app/DataVisualization.m#L261): `selectMission` adds another `Figures` listener on every mission change.
- [x] [Spectrogram.m:20](src/mission/imap/+mag/+imap/+view/Spectrogram.m#L20) and [PSD.m:17](src/visualize/+mag/+graphics/+view/PSD.m#L17): `Transformation` is a handle default shared by all instances. Reproduced in both views.

## Phase 3: Add the test safety net

- [x] Find out why baseline comparisons were disabled on GitHub in March 2025. They are skipped in 6 places, in `tIMAPAnalysis` and `tExport`. Locally, all 132 analysis and I/O tests pass with baselines on R2026b. The March 2025 records were gone: the skips came from PR #142, the commits have no message body, and the run logs have expired. **Re-running them on GitHub found the cause:** IMAP results from CSV data differ there, on all four releases. The first differences are in `FOB_TEMP` HK, for `full_analysis` and `fob_only`, and in the first Z sample of science data, for `sc_test`. Both are computed values, and the timestamps and other HK columns match, so this is probably rounding that depends on the CPU. The size of the difference was not measured. IMAP CDF data and the other missions match.
- [x] Re-enable baselines on at least one runner. **Partly:** baselines now run on GitHub for IMAP CDF data and for app export of Bartington, HelioSwarm and Vigil, but are still skipped there for IMAP CSV data and IMAP app export. `verifyEqualsBaseline` ignores tolerances for objects, and `PublicPropertyComparator` does not apply them inside timetables, so a tolerance needs its own comparison. A failing baseline now names the first value that differs, using `mag.test.isequalTraversal`.
- [x] Add tests for `mag.imap.Analysis/export` (issue #40). It had 0% coverage in the 14 October report. Tests cover export without a window, file contents, HK cropping, range cycling and a single sensor. Ramp mode export is not covered, as no test data has a ramp. They found a crash, now fixed: range and mode cycling, and so export, failed when the pattern occurred more than once, as in `fob_only`, or ended with the last event.
- [x] Add tests for `loadEventsData` based on log excerpts, before splitting it. `tIMAPEvents` covers normal, burst and config modes, range changes, default and unchanged rates, response matching and multiple files. Ramp commands are not covered, as no log has one. Two oddities were kept as they are: `ModeChangeTimestamp` stays in ground time while the other times are corrected to spacecraft time, and `CompleteTimestamp` stays `NaT` when no completion follows the command, whereas acknowledgment falls back to the command time. `Timestamp` hides the second one.
- [x] Re-run coverage, as the report predates the split test tasks. It showed 82% overall, HENON source at 36.8% and `+view/HK` at 22.9%. **Now 84.5% overall**, merged from all three test tasks on R2026b: `src` at 83.1%, `app` at 90.7%, `export` at 97.2%, `loadEventsData` at 94.7% and IMAP `+view/HK` at 72.7%. HENON source stays at 37.3%, as `tVisualize` has no HENON leg, so its `Field` and `Spectrogram` views are at 0%. Phase 5 merges them with the Vigil views, which are covered.
- [x] Parameterize the Bartington, HENON and Vigil app system tests, which are near-copies. They are now `tMissionApp`, and `tVigilApp` keeps its two single-sensor tests.

### UI test stall

The UI tests stalled locally, in the same place as on GitHub. `tVisualize/showFigures` calls `signalAnalyzer(data)` from the "Show Figures" button. Signal Analyzer opened but never imported the data, and MATLAB waited idle with no dialog open. Closing Signal Analyzer did not unblock it. The pool shut down at the same time, but on GitHub run 39108660614 the stall began 26 min before that, so the pool is not the cause. Signal Analyzer is p-coded, so the cause inside it is unknown.

It stalled in 1 of 2 full UI runs, and never in 6 runs of `tVisualize` alone, which opened Signal Analyzer 24 times. `tVisualize` now excludes Signal Analyzer, as it already did for Wavelet Analyzer, and `tSignalAnalyzer` still tests the command. Users could hit the same stall from the app, which is not addressed.

## Phase 4: Single-build pipeline and schema 1.2.0

**Done, and passed on 2026-11-02.** The toolbox was built once on R2026b, and the full test suite passed against the installed toolbox on all older releases ([push run](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization/actions/runs/41502633433), [pull request run](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization/actions/runs/41502646289)).

| Release | Tests run on | Parallel | Serial | UI |
| ------- | ------------ | -------- | ------ | -- |
| R2025a | Installed toolbox | 751 passed | 28 passed, 7 filtered | 109 passed, 2 filtered |
| R2025b | Installed toolbox | 751 passed | 28 passed, 7 filtered | 109 passed, 2 filtered |
| R2026a | Installed toolbox | 751 passed | 28 passed, 7 filtered | 109 passed, 2 filtered |
| R2026b | Source | 750 passed, 1 filtered | 35 passed | 109 passed, 2 filtered |

All filtered tests are by design: `tToolbox` needs R2026b, `tInstalledToolbox` needs an older release, and `tExport` skips missions with no export formats.

The first CI run passed too, but older releases ran 615 parallel tests instead of 750. Test tasks find their tests before running any action, so the `install` action was too late: 30 test classes could not load without the toolbox, and were excluded with only a warning. `buildfile.m` now installs the toolbox on older releases when it loads, and fails the build if any test cannot be loaded.

Not yet exercised:

- The `release` job and the tag check, until the next tag is pushed.
- The failure path of the excluded test check on older releases. It was only seen failing on R2026b.
- macOS and Linux installs. Test runs are Windows only.

A UI test stall now blocks a release, as `release` needs every test job. Re-run the failed job, which reuses the same toolbox. Phase 3 found the most common stall, and `tVisualize` no longer opens Signal Analyzer.

### Background

Commit `29610d73` moved the manifest to schema 1.2.0, and `90b9a9f7` rolled it back after R2025a failed with `Schema version '1.2.0' is newer than what is supported by the current version of MATLAB`. The R2025b and R2026a jobs were cancelled, so their behavior is unknown. MathWorks' documentation says any schema works in any release since R2024b, which does not match this result.

### Target pipeline

```text
build (R2026b):    check, package, upload .mltbx
test  (matrix):    R2026b tests source with coverage; older releases download .mltbx to repo root, install it, and run tests
release (on tag):  needs test; publishes that same .mltbx
```

R2026b does not install the `.mltbx`. Coverage needs source, and `tToolbox` already packages and installs the toolbox on that release.

### Changes

- [x] In `buildfile.m`, only open the manifest on R2026b. Older releases add just `tests/tool`, and must not add `src`, or they test source instead of the install.
- [x] Drop coverage and `RunOnlyImpactedTests` on older releases, as there is no source to measure.
- [x] Reuse the existing `install` task, which already picks up any `.mltbx` in the repository root.
- [x] Raise `tToolbox` to R2026b. It is the only test that needs the source tree for packaging.
- [x] Add a test that `which("mag.version")` resolves to the add-on folder on older releases.
- [x] Restore the 1.2.0 manifest fields from `29610d73`: `tags`, `readme` and `supportedPlatforms`, without `description`.
- [x] Remove the `isprop` guard in `PackageTask` and the `getAddOnVersion` datetime workaround.
- [x] Update the README: development will need R2026b, as older releases will reject the manifest.

### Other packaging and CI fixes

| Problem | Fix | Outcome |
| ------- | --- | ------- |
| Releases are not gated on tests: v10.0.0 was published about 90 s in, while its tests ran for 40 min | The `release` job above | Done, in `test.yml`. `package.yml` is removed, and the tag is checked against the manifest in `build` |
| The minimum release differs by file: R2024a (`PackageTask`, Copilot instructions), R2024b (README, manifest), R2025a (CI, `tToolbox`) | Use R2025a everywhere, as that is what is tested, unless R2024b is needed | Done, as nothing tests R2024b. Release checks that became unreachable were removed too |
| The v10 add-on description is empty, as R2026b ignores the `description` field | Set `Summary` in the task | Done, but `Summary` was already set. The empty field comes from `Description`, which is hidden in `ToolboxOptions` since R2026b, so the task sets both |
| `PackageTask` builds the path from `path()` and drops anything containing "test", so a repository under a `test` folder loses all its paths | Use `Package.Folders` | Done, keeping only folders that are packaged, as `Package.Folders` includes `tests/tool` |
| `PackageTask` ships to users, and a local build also packaged stale `.asv` files | Move it out of `src`, and filter the files | Done. Moved to `tests/tool`, which is on the development path and is not packaged |
| `Maci64` is deprecated, and R2026b warns about it | Use `Mac` | Done |
| `workflow_dispatch` in `package.yml` cannot pass from a branch, as the tag check fails | Remove it or gate the check | Done, removed with `package.yml` |
| Four releases run for 30 to 60 min on every branch push | Run older releases only on PRs, `main` and tags | Done. Pull requests now also run on `opened`, `reopened` and `synchronize`, or pushes to an open PR would never reach older releases. They skip R2026b, which the branch push covers |
| `RunOnlyImpactedTests` is probably a no-op, as `.buildtool` is not cached | Cache it or remove it | Removed, as a release gate must run every test. Local runs no longer select impacted tests |
| `@master` and `@main` actions, and no `permissions:` blocks | Pin to SHAs, and add least-privilege permissions | Done. Both actions are pinned to their latest tag, which only differs from the branch by a GitHub Enterprise fix and a documentation change |

### To check

- [x] MathWorks' documentation says `UseLicenseBSD` must be true for File Exchange uploads. The license is MIT and the task does not set it, so check this against PR #287. **Not needed:** v10.0.1 was built without it, and File Exchange picked it up from the GitHub release. PR #287 did not touch it. Setting it would add a BSD license to an MIT project, so it stays unset.

Do not adopt the built-in `matlab.buildtool.tasks.PackageTask` yet, because it requires migrating to `matlab.toml`. Revisit it once only R2026b reads the project.

## Phase 5: Remove mission and app duplication

**Done on 2026-11-03.** Code in `src` and `app` went from 20,595 to 19,690 lines (−905). Duplication was not measured again. All unit and system tests pass on R2026b, including the app tests for every mission and the baselines, and Code Analyzer still reports 23 info-level notes. Older releases were not tested locally.

Found along the way:

- **Shared processing steps (bug):** all analyses shared one `Processing` object, as a handle default is created once. Vigil wrote its science steps to it, so a new `mag.imap.Analysis()` or `mag.henon.Analysis()` used them too. Each analysis now creates its own, and `tAnalysis` covers it.
- **File names before detection (bug):** all missions except IMAP failed to read their file names before `detect`, as the structs have no fields.
- **Bartington options (bug):** `mag.bart.Instrument` validated its options against `mag.imap.Instrument`.
- **HENON spectrogram (not fixed):** it fails on the HENON test data, with the same error before and after this phase. The data has only 6 samples at 1 Hz, so its spectrum is empty and `linkaxes` fails. Any mission with data this short fails in the same way.

### Analysis and data

- [x] Move the export-window block (4 copies), the science and HK file-name getters, and the empty-sensor fallback into `mag.Analysis`. The window is now `mag.time.closedTimerange`, which the app also uses, and IMAP's `cropAndExport` is shared. Vigil and HelioSwarm no longer export data that is empty after cropping, as IMAP already did.
- [x] Make Bartington, HENON and HelioSwarm use the inherited `Processing`, keeping forwarding properties for the public API. Bartington, HENON and Vigil now import through `importScience`, which applies per-file, whole data and science steps. HelioSwarm defined whole data steps but never applied them. It now does, and its baselines still match.

### Views

- [x] Create shared dual-sensor `Field`, `Spectrogram` and `Instrument` classes. They are `mag.graphics.view.DualSensorField`, `DualSensorSpectrogram` and `mag.DualSensorInstrument`. The mission classes remain as thin subclasses, and `mag.bart.Instrument` keeps `Input1` and `Input2`. Figures match the old ones, compared by name, title, axes and labels. The exception is Bartington titles: they now list only sensors with data, and no longer add "Hz" for a single sensor, as no other mission does. Before, a sensor without data showed a frequency of NaN.
- [x] Move the chart block repeated in all 5 spectrogram views into `mag.graphics.view.View`.

### App

- [x] Replace the 5 `Provider` and 5 `Model` classes, which differ only by name, with one class driven by `mag.meta.Mission`. This also removes the `switch` in `selectMission`. `Mission` has a new `PackageName`. A mission customizes a manager by defining a class with the same name in its namespace, such as `mag.app.imap.AnalysisManager`, and uses the shared manager otherwise.
- [x] Move location, browse and validation into the base `AnalysisManager`, so that HENON and Vigil no longer need their own. Subclasses override `instantiateSettings`, `resetSettings` and `getSettingsOptions`.
- [x] Merge the Bartington, HENON and Vigil `ExportManager` classes. The base class shows start and end times when the mission has export formats, so IMAP and HelioSwarm only set their format.
- [x] Share the three-branch preview in the `ResultsManager` classes. HENON and Vigil use the base class, and Bartington only sets its sensor names.
- [x] Remove the IMAP `visualize` override, which only changes one argument. Controls now choose their data with `getVisualizeData`, which AT and CPT override.
- [x] In `DataVisualization.m`, replace `evalin`, `eval` and `assignin("caller")`, which the repository's analyzer rules forbid, with `save -struct`. **Partly:** one `evalin` remains, as only it can check whether the variable already exists in the base workspace. `eval` and `assignin("caller")` are gone.
- [x] Add `try/catch` to the Workspace and MAT exports, and stop the `ResultsLocation` getter creating folders. The folder is now created only when saving to it.

### Remove core dependencies on IMAP

- [x] [import.m:118](src/io/+mag/+io/import.m#L118) hard-codes the IMAP HK dispatch. HelioSwarm only avoids it because its type is empty. Combined HK data now keeps the class of the imported data.
- [x] `mag.app.Model`, `mag.app.Control` and `DataVisualization` default to IMAP classes. The model now starts with an empty analysis of its mission, as `mag.Analysis` is abstract and has no empty array.
- [x] The HelioSwarm `Field` view uses `mag.imap.chart.Event`. The chart moved to `mag.graphics.chart.Event`, and `mag.imap.chart.Event` is now a subclass that labels missing values as ramp mode. HelioSwarm uses the shared chart.

`MAG-Sensor-Performance` only uses `mag.app.manage.Manager`, `NotificationHandler` and `DatetimeSlider` from this toolbox, which did not change.

## Phase 6: Simplify IMAP

**Done on 2026-11-04.** Functions in `src` and `app` with a cyclomatic complexity above 10 went from 12 to 9, and IMAP ones from 9 to 5. The highest is now 17, in `mag.graphics.chart.Event/plot`, against 44 before. Results are identical on all IMAP test data, compared with every public output of `mag.imap.Analysis` and with the health check results.

- [x] Split [loadEventsData.m](src/mission/imap/+mag/+imap/@Analysis/loadEventsData.m) (331 lines, complexity 44) into reading, parsing commands and matching responses. Its largest function is now at complexity 7.
  - The Config, Normal and Burst loops are one table-driven builder.
  - Acknowledgment and completion share one parser and one matcher. Responses that do not identify their command are dropped, instead of misaligning the other responses.
  - Timestamps are parsed once, when reading the logs.
  - A test covers ramp mode commands, with a made-up log excerpt, as no log has one.
- [x] Merge `loadScienceData` and `loadIALiRTData` into shared helpers for setup, timestamps, events and steps. **The step order differs, and was kept:** science adds events before sorting and removing duplicates, and I-ALiRT after. No commit explains it, as it comes from a work-in-progress refactor in April 2024 (`81a8072f`). Swapping it gives the same results on all test data, which may only mean the test data has no unsorted or duplicate samples near events. I-ALiRT's order looks safer, so moving science to it is worth considering, with a test that has such samples.
- [x] Split `findModeChanges`, which holds two unrelated algorithms and mixes `data.t` with `timeColumn`. **Found:** refining logged mode changes failed for data whose time variable is not named "t", such as L1b. It is now fixed and tested. `updateRampModeTimestamps` had the same problem.
- [x] Slim down [Analysis.m](src/mission/imap/+mag/+imap/@Analysis/Analysis.m), from 528 to 372 lines:
  - `findModeCyclingPeriod` and `findRangeCyclingPeriod` are one pattern finder.
  - `mag.time.emptyTimerange` replaces the 4 `timerange(NaT...)` copies.
  - The ramp detection is shared, as `findRampEvents`.
  - The stale `generateEventTable` signature is fixed.
  - Mode slicing moved to `mag.imap.Instrument`, and `mag.imap.Analysis` forwards to it. `getRampMode` stays in the analysis, which holds ramp mode data.
- [x] In [health/Power.m](src/mission/imap/+mag/+imap/+health/Power.m), merge the voltage, current and temperature checks into one method. Warnings keep their order, which is sorted when danger limits are checked first, and declared otherwise. The `isSupported` methods are now inherited from `mag.imap.health.HKCheck`.

**Found, and removed:** `splitByTimeGap` crashed when the data had no gap larger than the threshold, and dropped the data after the last gap and the samples at each boundary. Nothing used it, here or in `MAG-Sensor-Performance`, so it was removed.

**Found, not fixed:** whether a command without a matching response gets a fallback time depends on unrelated responses. If any acknowledgment or completion is logged after the command, a missing acknowledgment falls back to the command time, and a missing completion to the acknowledgment time. If none is, the timestamp stays `NaT`, which mostly affects the last commands in a log. The refactor kept this, as it comes from the original code, and Copilot flagged it in PR #290. Always using the fallback would be more consistent, but changes event times and tables, so it should be its own fix, with a test and a release note.

## Phase 7: Performance and cleanup

**Done on 2026-11-04.** All 889 non-UI tests and 111 UI tests pass on R2026b, except those filtered by design: `tInstalledToolbox` needs an older release, `tToolbox` is skipped when the toolbox is installed as a package, and `tExport` skips missions with no export formats. Code Analyzer reports 21 info-level notes, down from 23. Older releases were not tested locally.

### Performance

Measured on synthetic data, before and after. Outputs are identical, including 1,000 events with corrected command times.

| Candidate | Size | Before | After |
| --------- | ---- | ------ | ----- |
| CSV data check | 90 MB file | 5.3 s | 0.001 s |
| `Separate`, one copy per gap | 1 million rows, 1,000 gaps | 24.5 s | 0.07 s |
| `correctSequence` in `Step`, one shift per reset | 10 million samples, 610 resets | 12.8 s | 0.11 s |
| Event matching | 2,000 commands | 26.7 s | 9.6 s |
| New `Spice` object per sensor per file | 100 objects | 0.1 s | Not changed |
| Deep copy per mode in `getAllModes` | 5 modes | 6 ms of 1.1 s | Not changed |

- [x] [CSV.m](src/io/+mag/+io/+in/CSV.m) reads only the first lines to check a file has data. A header followed only by a blank CRLF line now counts as empty, like a blank LF line, instead of being read as an empty table.
- [x] Measure these likely wins at scale. The first three were worth fixing:
  - `data = [data; missingRow]` in a loop ([Separate.m](src/analyze/+mag/+process/Separate.m)). Fixed: rows are added at once.
  - The sequence loop in [Step.m](src/analyze/+mag/+process/Step.m). Fixed: shifts add up with `cumsum`, which gives the same result.
  - O(n²) matching in `loadEventsData`. Fixed: event properties are gathered once. Most of the remaining time is building events, which is linear: each `ModeChange` takes 4 ms to construct, mostly in `options.?Class` argument validation, which every event and step class uses.
  - A new `Spice` object per sensor per file. Not changed: SPICE kernels are loaded once, so each object costs about 1 ms.
  - A deep copy per mode in `applyTimeRangeToInstrument`. Not changed: copies take 6 ms of the 1.1 s that `getAllModes` takes on `full_analysis`.

`mag.imap.Analysis.start` takes 2.2 s on `full_analysis` on this machine, against the 10 s measured in the review.

### Cleanup

- [x] Replace `struct(timerange)`, which reads MATLAB internals ([Crop.m](src/utility/+mag/+mixin/Crop.m)). **Partly:** `timerange` and `withtol` have no public properties in R2026b, and their only methods are `isequal`, `isequaln`, `keyHash` and `keyMatch`. `Event.crop` needs the start and end times of the filter, so the internals are still read for those two classes, in one place that fails with a clear error if the fields change. Removing it means no longer accepting `timerange` and `withtol` for cropping events.
- [x] Merge the two `Crop` converters, which repeat each other.
- [x] Remove dead code: HelioSwarm `InputSource` and `MetadataPattern`, and Bartington `Gradiometer`. Their app settings are removed too. This breaks scripts that pass these options. Saved HelioSwarm analyses still load, with a warning that `mag.hs.meta.InputSource` cannot be found.
- [x] Fix the drifted `Format.load` and `getExportOptions` signatures. `getExportOptions` was already fixed in phase 5, which merged the export managers.
- [x] Add identifiers to the errors and warnings that have none: 26 errors and 12 warnings, as `mag:<area>:<Name>`. Tests that matched an empty identifier now name the one they expect, which showed that `downsampleMethod_errorInitialFrequency` was matching a different error than its message said. The CDF export error was also missing the value for its `%s`.
- [x] Replace the 8 lines using `datestr`, which is deprecated. Export file names are unchanged.
- [x] Rename the FOB and FIB names left after #260, and update the Copilot instructions. **Mostly not needed:** OBS and IBS name the sensors, while FOB and FIB name the front-end electronics (FEE) that process each sensor's data, so they are not interchangeable. #260 renamed the sensors only. Quantities measured on the electronics, such as the FOB and FIB temperatures from thermistors on the FEE and activation attempts, correctly keep FOB and FIB, in HK properties and in health check names. Only a warning about I-ALiRT sensor data and two comments about sensors were renamed. Names from external data also keep their form: HK columns, metadata document labels, Vigil file name prefixes and MAT export fields. The Copilot instructions now explain the distinction, and describe the shared app provider from phase 5.
- [x] Move the WSL decoding out of HelioSwarm `detect`, which writes files as a side effect. It is now `mag.hs.decodeBinaryFiles`, which `start` calls before `detect`.

## Limits of this review

- **Older releases:** only R2026b was available, so nothing was run on older releases.
- **Not read line by line:** charts, styles, `BackgroundTask` and the sliders. The complexity and clone metrics still covered them.
- **Tests not run:** the UI and full app suites.
- **`MAG-Sensor-Performance`:** not checked. If it calls `mag.*`, API changes could affect it.

## Sources

- [mpackage.json schema](https://www.mathworks.com/help/matlab/ref/mpackage.json.html)
- [ToolboxOptions](https://www.mathworks.com/help/matlab/ref/matlab.addons.toolbox.toolboxoptions.html)
- [TOML project format](https://www.mathworks.com/help/matlab/matlab_prog/toml-format-for-matlab-projects.html)
- [R2026b release notes](https://www.mathworks.com/help/matlab/release-notes-R2026b.html)
- [Develop and Share Software in MATLAB](https://www.mathworks.com/help/matlab/matlab_prog/recommended-workflow-for-software-development.html)
- [mpminstall](https://www.mathworks.com/help/matlab/ref/mpminstall.html)
- [matlab.mpm.Package](https://www.mathworks.com/help/matlab/ref/matlab.mpm.package.html)
- [Create and Manage Packages](https://it.mathworks.com/help/matlab/matlab_prog/create-and-manage-packages.html)
- [Build Automation](https://www.mathworks.com/help/matlab/build-automation.html)
- [buildtool](https://www.mathworks.com/help/matlab/ref/buildtool.html)
- [MATLAB-Package-Builder](https://la.mathworks.com/matlabcentral/fileexchange/184426-matlab-package-builder)
