# Changelog

All notable project changes are recorded here.

## [Unreleased]

- Selected 450 by 320 W3D units as the v0.3 expansion target after the v0.2 scale study showed that 300 by 220 would become compact once each team has four or five buildings and vehicle infrastructure.

## [v0.2] - 2026-07-19

- Built the east-west Three-Lane Valley terrain study at 300 by 220 W3D units with two vehicle lanes, a contested centre route, ramps, segmented banks, and perimeter walls.
- Added four nonfunctional building-scale proxies to judge base footprint, sightlines, and travel distance.
- Added dedicated GDI and Nod startup spawners on the west and east base pads, replacing the obstructed fallback spawn at world origin.
- Verified `ONO_ValleyB.W3D` at 256 triangles and 208 exported vertices with physical, projectile, and camera collision flags.
- Exported a 28,304-byte MIX, passed 27 automated checks with zero errors, and deployed it to the Steam client and Dragonade FDS with backups.
- Passed live GDI and Nod spawn, full-map infantry traversal, terrain collision, ramp, lane, and boundary smoke tests without falling through the map.
- Concluded that the terrain should grow rather than shrink when real buildings and vehicle infrastructure replace the scale proxies.

## [v0.1.1] - 2026-07-19

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
