# Map build workflow

1. Confirm the next change is an approved design decision or a tooling task.
2. Edit terrain or models in RenX.
3. Export W3D geometry into `export/w3d`.
4. Copy approved texture exports into `export/textures`.
5. Import or update assets in LevelEdit.
6. Configure terrain, collision, spawners, building controllers, and waypaths manually.
7. Save the LevelEdit project and final output.
8. Run `ValidateMap.ps1`.
9. Run `BackupMap.ps1`.
10. Run `BuildMap.ps1` to stage and, when a finished map exists, deploy it.
11. Package manually with a verified utility if no approved integration is configured.
12. Run `TestMap.ps1`, first locally and then against the dedicated server.
13. Record defects in `KnownIssues.md`, update `Todo.md` and `Changelog.md`, and repeat.

Every completed milestone is committed and tagged according to `Roadmap.md`. Generated packages, releases, logs, and backups are not committed.
