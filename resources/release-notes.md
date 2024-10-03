# App

- Add option to only visualize HK for IMAP
- Rename "AT, SFT" visualization option for IMAP to "AT/SFT"
- Rename "Field" visualization option for HelioSwarm to "Science" to match IMAP
- Show progress bar when importing data
- Do not show progress bar when creating app with input argument (for faster loading)

# Software

- Fix HK data not being shown after long gaps
- Fix `mag.Science/CompressionWidth` converted to `logical` instead of `double`
- Do not error if visualizing a figure in `mag.graphics.view.View/visualizeAll` fails, instead issue a warning
