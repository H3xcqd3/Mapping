# C&C_OnOeS_Test

`C&C_OnOeS_Test` is the first test map for the OnOeS Command & Conquer: Renegade mapping toolkit. Its purpose is to prove a safe, repeatable workflow with RenX/GMax, LevelEdit, W3D Viewer, Renegade Scripts 4.8.4, and Dragonade 1.11.1 before production maps or custom gameplay code are attempted.

## Project boundaries

- The designer owns gameplay, layout, art-direction, and balance decisions. Multiple viable choices must be presented for approval before implementation.
- RenX terrain work and LevelEdit setup remain manual.
- The scripts automate validation, backups, staging, deployment, cleanup, and local launch testing.
- They do not edit undocumented W3D or MIX formats and do not claim to automate LevelEdit.
- No Dragonade gameplay plugin or custom map logic is planned until the map loads in both the client and a local dedicated server.

## File lifecycle

| Area | Purpose | Versioned |
|---|---|---|
| `source/` | Editable RenX files, original textures, and LevelEdit project data | Yes |
| `export/` | W3D and texture outputs exported from source tools | Normally yes |
| `package/` | Generated staging area assembled by `BuildMap.ps1` | No |
| `releases/` | Generated timestamped builds or verified final packages | No |
| `backups/` | Timestamped source and deployment backups | No |
| `logs/` | Validation, build, and test logs | No |

## Initial map scope

The approved starting brief is a small symmetrical AOW test map containing GDI Weapons Factory, Refinery, and Power Plant; Nod Airstrip, Refinery, and Power Plant; one central vehicle route; one infantry tunnel route; one central bunker; and harvester routes. Flying vehicles are excluded initially. Exact dimensions, route geometry, defensive placement, and balance values remain design decisions.

## First use

From Windows PowerShell:

```powershell
Set-Location "E:\Mapping\C&C_OnOeS_Test"
.\ValidateMap.ps1
```

On its first run, the validator creates `config/map-build.ini` from the documented example and stops. Edit that file with local paths, then run:

```powershell
.\ValidateMap.ps1 -VerboseOutput
.\BackupMap.ps1
.\BuildMap.ps1 -VerboseOutput
.\TestMap.ps1 -ServerOnly
```

If PowerShell's execution policy blocks a script, use a process-scoped invocation:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\ValidateMap.ps1
```

Without a verified packaging utility, `BuildMap.ps1` creates a clearly labelled staging directory. Create the MIX with an approved tool or save the final LevelEdit output as the configured map filename before deployment.

## Milestones

- `v0.1` - Toolchain
- `v0.2` - Terrain
- `v0.3` - Bases
- `v0.4` - Harvesters
- `v0.5` - Playable
- `v1.0` - Public beta

See `docs/Roadmap.md` for entry criteria and project direction.
