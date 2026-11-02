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

Nothing has installed an R2026b-built `.mltbx` on an older release, yet v10.0.0 already ships that way. The metadata layout matches an R2025b build, and the only new content seen is an embedded schema 1.2.0 manifest, `resources/mpackage.json`. That is encouraging but not proof.

- [ ] Add a throwaway workflow that installs the v10.0.0 release asset on R2025a, R2025b and R2026a.
- [ ] On each release, check `mag.version()`, object creation for each mission, and that no manifest warnings appear.

If the install fails, fall back to reading the folder list with `jsondecode` instead of `matlab.mpm.Package`. This still allows the schema upgrade, but older releases would test source rather than the released artifact.

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

- [ ] Find out why baseline comparisons were disabled on GitHub in March 2025. They are skipped in 6 places, in `tIMAPAnalysis` and `tExport`. Locally, all 132 analysis and I/O tests pass with baselines on R2026b.
- [ ] Re-enable baselines on at least one runner.
- [ ] Add tests for `mag.imap.Analysis/export` (issue #40). It had 0% coverage in the 14 October report.
- [ ] Add tests for `loadEventsData` based on log excerpts, before splitting it.
- [ ] Re-run coverage, as the report predates the split test tasks. It showed 82% overall, HENON source at 36.8% and `+view/HK` at 22.9%.
- [ ] Parameterize the Bartington, HENON and Vigil app system tests, which are near-copies.

## Phase 4: Single-build pipeline and schema 1.2.0

### Background

Commit `29610d73` moved the manifest to schema 1.2.0, and `90b9a9f7` rolled it back after R2025a failed with `Schema version '1.2.0' is newer than what is supported by the current version of MATLAB`. The R2025b and R2026a jobs were cancelled, so their behavior is unknown. MathWorks' documentation says any schema works in any release since R2024b, which does not match this result.

### Target pipeline

```text
build (R2026b):    check, package, upload .mltbx
test  (matrix):    download .mltbx to repo root, buildtool install, run tests
release (on tag):  needs test; publishes that same .mltbx
```

### Changes

- [ ] In `buildfile.m`, only open the manifest on R2026b. Older releases add just `tests/tool`, and must not add `src`, or they test source instead of the install.
- [ ] Drop coverage and `RunOnlyImpactedTests` on older releases, as there is no source to measure.
- [ ] Reuse the existing `install` task, which already picks up any `.mltbx` in the repository root.
- [ ] Raise `tToolbox` to R2026b. It is the only test that needs the source tree for packaging.
- [ ] Add a test that `which("mag.version")` resolves to the add-on folder on older releases.
- [ ] Restore the 1.2.0 manifest fields from `29610d73`: `tags`, `readme` and `supportedPlatforms`, without `description`.
- [ ] Remove the `isprop` guard in `PackageTask` and the `getAddOnVersion` datetime workaround.
- [ ] Update the README: development will need R2026b, as older releases will reject the manifest.

### Other packaging and CI fixes

| Problem | Fix |
| ------- | --- |
| Releases are not gated on tests: v10.0.0 was published about 90 s in, while its tests ran for 40 min | The `release` job above |
| The minimum release differs by file: R2024a (`PackageTask`, Copilot instructions), R2024b (README, manifest), R2025a (CI, `tToolbox`) | Use R2025a everywhere, as that is what is tested, unless R2024b is needed |
| The v10 add-on description is empty, as R2026b ignores the `description` field | Set `Summary` in the task |
| [PackageTask.m:94](src/utility/+mag/+buildtool/+task/PackageTask.m#L94) builds the path from `path()` and drops anything containing "test", so a repository under a `test` folder loses all its paths | Use `Package.Folders` |
| `PackageTask` ships to users, and a local build also packaged stale `.asv` files | Move it out of `src`, and filter the files |
| `Maci64` is deprecated, and R2026b warns about it | Use `Mac` |
| `workflow_dispatch` in `package.yml` cannot pass from a branch, as the tag check fails | Remove it or gate the check |
| Four releases run for 30 to 60 min on every branch push | Run older releases only on PRs, `main` and tags |
| `RunOnlyImpactedTests` is probably a no-op, as `.buildtool` is not cached | Cache it or remove it |
| `@master` and `@main` actions, and no `permissions:` blocks | Pin to SHAs, and add least-privilege permissions |

### To check

- [ ] MathWorks' documentation says `UseLicenseBSD` must be true for File Exchange uploads. The license is MIT and the task does not set it, so check this against PR #287.

Do not adopt the built-in `matlab.buildtool.tasks.PackageTask` yet, because it requires migrating to `matlab.toml`. Revisit it once only R2026b reads the project.

## Phase 5: Remove mission and app duplication

### Analysis and data

- [ ] Move the export-window block (4 copies), the science and HK file-name getters, and the empty-sensor fallback into `mag.Analysis`.
- [ ] Make Bartington, HENON and HelioSwarm use the inherited `Processing`, keeping forwarding properties for the public API.

### Views

- [ ] Create shared dual-sensor `Field`, `Spectrogram` and `Instrument` classes. The HENON and Vigil versions differ only by names and comments, and Bartington is close.
- [ ] Move the chart block repeated in all 5 spectrogram views into `mag.graphics.view.View`.

### App

- [ ] Replace the 5 `Provider` and 5 `Model` classes, which differ only by name, with one class driven by `mag.meta.Mission`. This also removes the `switch` in `selectMission`.
- [ ] Move location, browse and validation into the base `AnalysisManager`, so that HENON and Vigil no longer need their own.
- [ ] Merge the Bartington, HENON and Vigil `ExportManager` classes.
- [ ] Share the three-branch preview in the `ResultsManager` classes.
- [ ] Remove the IMAP `visualize` override, which only changes one argument.
- [ ] In `DataVisualization.m`, replace `evalin`, `eval` and `assignin("caller")`, which the repository's analyzer rules forbid, with `save -struct`.
- [ ] Add `try/catch` to the Workspace and MAT exports, and stop the `ResultsLocation` getter creating folders.

### Remove core dependencies on IMAP

- [ ] [import.m:118](src/io/+mag/+io/import.m#L118) hard-codes the IMAP HK dispatch. HelioSwarm only avoids it because its type is empty.
- [ ] `mag.app.Model`, `mag.app.Control` and `DataVisualization` default to IMAP classes.
- [ ] The HelioSwarm `Field` view uses `mag.imap.chart.Event`.

## Phase 6: Simplify IMAP

- [ ] Split [loadEventsData.m](src/mission/imap/+mag/+imap/@Analysis/loadEventsData.m) (331 lines, complexity 44) into reading, parsing commands and matching responses:
  - The Config, Normal and Burst loops can become one table-driven builder.
  - The acknowledge and complete blocks are the same logic written two ways, twice.
  - Timestamps can be parsed once rather than in 7 places.
- [ ] Merge `loadScienceData` and `loadIALiRTData` into shared helpers for setup, timestamps, events and steps. Check first whether their different step order is intentional.
- [ ] Split `findModeChanges`, which holds two unrelated algorithms and mixes `data.t` with `timeColumn`.
- [ ] Slim down [Analysis.m](src/mission/imap/+mag/+imap/@Analysis/Analysis.m) (476 lines):
  - Merge `findModeCyclingPeriod` and `findRangeCyclingPeriod`, which differ by one column.
  - Add a helper for the 4 `timerange(NaT...)` copies.
  - Share the ramp detection that exists twice.
  - Fix the stale signature at [line 404](src/mission/imap/+mag/+imap/@Analysis/Analysis.m#L404).
  - Move mode slicing to `mag.imap.Instrument`, keeping forwarding methods.
- [ ] In [health/Power.m](src/mission/imap/+mag/+imap/+health/Power.m), merge the voltage, current and temperature checks into one method. The `isSupported` methods of the health checks are near-identical too.

## Phase 7: Performance and cleanup

`mag.imap.Analysis.start` takes about 10 s on `full_analysis`, with no single hotspot, so measure at scale before optimizing beyond the first item below.

### Performance

- [ ] [CSV.m:13](src/io/+mag/+io/+in/CSV.m#L13) reads and splits the whole file just to count lines. On an 89 MB file this cost 3.4 s, against 1.7 to 3.2 s for the real read. Reading the first lines takes 0.003 s.
- [ ] Measure these likely wins at scale:
  - `data = [data; missingRow]` in a loop ([Separate.m:101](src/analyze/+mag/+process/Separate.m#L101)).
  - The sequence loop in [Step.m:20](src/analyze/+mag/+process/Step.m#L20).
  - O(n²) matching in `loadEventsData`.
  - A new `Spice` object per sensor per file.
  - A deep copy per mode in `applyTimeRangeToInstrument`.

### Cleanup

- [ ] Replace `struct(timerange)`, which reads MATLAB internals ([Crop.m:119](src/utility/+mag/+mixin/Crop.m#L119)).
- [ ] Merge the two `Crop` converters, which repeat each other.
- [ ] Remove dead code: HelioSwarm `InputSource` and `MetadataPattern`, and Bartington `Gradiometer`.
- [ ] Fix the drifted `Format.load` and `getExportOptions` signatures.
- [ ] Add identifiers to the 27 of 74 `error` calls and the 12 warnings that have none.
- [ ] Replace the 8 lines using `datestr`, which is deprecated.
- [ ] Rename the FOB and FIB names left after #260, and update the Copilot instructions.
- [ ] Move the WSL decoding out of HelioSwarm `detect`, which writes files as a side effect.

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
