# Changelog

All notable project changes are recorded here.

## [Unreleased]

- Verified the existing Steam client, bundled LevelEditor, and Dragonade FDS paths.
- Installed and configured GMax, RenX, and W3D Viewer, and added explicit mapping-tool configuration checks.
- Corrected the user-level Renegade installation registry path and created the `C&C_OnOeS_Test` LevelEditor package.
- Exported and verified the first RenX toolchain asset, `ONO_TestBox.w3d`, including its mesh and hierarchy.
- Switched model inspection to W3D Hub Viewer 1.9.0 after the legacy viewer produced a blank viewport, and documented the 15-character W3D identifier limit.
- Installed Tiberian Technologies LevelEdit 4.8.4 side-by-side, imported `ONO_TestBox`, and saved the first `.lvl/.lsd/.ldd/.ddb` project set.
- Exported `C&C_OnOeS_Test.mix`, passed project validation with zero errors, and deployed the test package to the configured client and FDS data folders.
- Passed the first live FDS/client smoke test: the server loaded the map, the client joined, and the player stood on the untextured test mesh with physical collision.
- Recorded the observed Dragonade version mismatch for investigation.

## [v0.1] - 2026-07-19

- Created the initial project structure, safety rules, documentation, configuration template, and PowerShell automation.
