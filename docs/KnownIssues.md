# Known issues

| ID | Status | Area | Description | Workaround |
|---|---|---|---|---|
| KI-001 | Resolved | Setup | Renegade client, FDS, GMax, RenX, LevelEditor, W3D Viewer, and the test mod package are configured locally. | None. |
| KI-002 | Expected | Content | No RenX, W3D, texture, or LevelEdit map content exists yet. | Complete toolchain setup, then begin the approved terrain milestone. |
| KI-003 | Open | Packaging | No verified MIX packaging integration has been supplied. | Use the generated staging directory and an approved manual packaging workflow. |
| KI-004 | Investigate | Compatibility | The brief targets Dragonade 1.11.1, while inspected server binaries report `Scripts.dll` 1.11.0 and `da.dll` 1.10.8. | Confirm the intended DA deployment and upgrade path before compatibility testing or replacing any server files. |
