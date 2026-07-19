# Toolchain setup

Record completion dates and notes next to each item. Do not copy tool installations into this repository.

- [x] Install or locate GMax. GMax is installed and launches successfully (verified 2026-07-19).
- [x] Install RenX into the supported GMax environment. The Westwood gamepack and W3D exporter are installed (verified 2026-07-19).
- [x] Locate LevelEdit. Steam installation includes `LevelEditor/LevelEditor.exe` (verified 2026-07-19).
- [x] Locate W3D Viewer. W3D Hub Viewer 1.9.0 is installed side-by-side with the legacy 5.3.2 viewer (verified 2026-07-19).
- [ ] Confirm Renegade Scripts 4.8.4 in the test client/server environment.
- [ ] Confirm Dragonade 1.11.1 in the local FDS environment.
- [x] Find the Renegade client directory and its `Data` directory (verified 2026-07-19).
- [x] Find the local FDS directory and its data directory (verified 2026-07-19).
- [x] Create a new LevelEdit mod package named for `C&C_OnOeS_Test` (verified 2026-07-19).
- [x] Create a simple test object in RenX and export it to W3D as `ONO_TestBox.w3d` (verified 2026-07-19).
- [x] Open `ONO_TestBox.w3d` in W3D Hub Viewer 1.9.0 and confirm the mesh and hierarchy are recognized (verified 2026-07-19).
- [ ] Import the test asset into LevelEdit and save the project output.
- [ ] Copy `config/map-build.example.ini` to `config/map-build.ini`.
- [x] Record every applicable local path in `map-build.ini` (verified 2026-07-19).
- [ ] Run `ValidateMap.ps1 -VerboseOutput` and resolve every error.

Never edit original game or tool files in place. Keep map source and generated output within this repository, and deploy copies to game folders only through the build script.
