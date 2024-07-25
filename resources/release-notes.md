# Software

- Add support for MAG Science HK (SID5)
- Add support for compression width in science CSV
- Use FM5 calibration for any FM and EM sensor, if specific calibration does not exist
- Do not apply `mag.process.Separate`, if data is empty
- Force data to be `double`s after processing in `mag.process.Range`
- Fix [#63](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization-Toolbox/issues/63)
