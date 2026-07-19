# Known issues

| ID | Status | Area | Description | Workaround |
|---|---|---|---|---|
| KI-001 | Resolved | Setup | Renegade client, FDS, GMax, RenX, LevelEditor, W3D Viewer, and the test mod package are configured locally. | None. |
| KI-002 | Resolved | Content | The first RenX source, W3D export, and LevelEdit project output now exist; textures remain intentionally absent from the untextured toolchain box. | None. |
| KI-003 | Open | Packaging | No verified MIX packaging integration has been supplied. | Use the generated staging directory and an approved manual packaging workflow. |
| KI-004 | Investigate | Compatibility | The brief targets Dragonade 1.11.1, while inspected server binaries report `Scripts.dll` 1.11.0 and `da.dll` 1.10.8. | Confirm the intended DA deployment and upgrade path before compatibility testing or replacing any server files. |
| KI-005 | Resolved | Spawning | The fallback world-origin spawn intersected the raised central platform during the first v0.2 traversal test. | Added dedicated GDI and Nod startup spawners on clear base-pad positions. |
