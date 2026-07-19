[CmdletBinding()]
param(
    [switch]$VerboseOutput,
    [switch]$SkipClientDeploymentCheck,
    [switch]$SkipServerDeploymentCheck
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'tools\MapTools.psm1') -Force

$projectRoot = Get-ProjectRoot
$logPath = New-ProjectLog -ProjectRoot $projectRoot -Name 'validate'
$results = New-Object System.Collections.Generic.List[object]

function Add-ValidationResult {
    param(
        [ValidateSet('OK', 'WARN', 'ERROR')][string]$Level,
        [string]$Message
    )
    $script:results.Add([pscustomobject]@{ Level = $Level; Message = $Message })
    Write-ProjectLog -Path $script:logPath -Level $Level -Message $Message -VerboseOutput:$VerboseOutput
}

try {
    $config = Get-ProjectConfiguration -CreateIfMissing
    $mapName = Get-ConfigValue -Configuration $config -Section 'Map' -Key 'Name' -Required
    if ($mapName -match '^C&C_[A-Za-z0-9_]+$') {
        Add-ValidationResult OK "Map name is valid: $mapName"
    } else {
        Add-ValidationResult ERROR "Map name must start with C&C_ and use only letters, digits, and underscores: $mapName"
    }

    $requiredDirectories = @(
        'config', 'docs', 'source\renx', 'source\textures', 'source\level_edit',
        'export\w3d', 'export\textures', 'package', 'releases', 'backups', 'logs', 'tools'
    )
    foreach ($relativePath in $requiredDirectories) {
        $path = Join-Path $projectRoot $relativePath
        if (Test-Path -LiteralPath $path -PathType Container) {
            Add-ValidationResult OK "Required directory exists: $relativePath"
        } else {
            Add-ValidationResult ERROR "Required directory is missing: $relativePath"
        }
    }

    $pathKeys = @(
        'RenegadeClient', 'RenegadeClientData', 'FDS', 'FDSData',
        'LevelEditProject', 'LevelEditOutput', 'ExportW3D', 'ExportTextures'
    )
    $resolvedPaths = @{}
    foreach ($key in $pathKeys) {
        $rawValue = Get-ConfigValue -Configuration $config -Section 'Paths' -Key $key
        $resolved = Resolve-ConfigPath -Configuration $config -Value $rawValue
        $resolvedPaths[$key] = $resolved
        if ($null -eq $resolved) {
            Add-ValidationResult WARN "Path is not configured: [Paths] $key"
        } elseif (Test-Path -LiteralPath $resolved) {
            Add-ValidationResult OK "Configured path exists: $key = $resolved"
        } elseif (($key -eq 'RenegadeClientData' -and $SkipClientDeploymentCheck) -or
                  ($key -eq 'FDSData' -and $SkipServerDeploymentCheck)) {
            Add-ValidationResult WARN "Skipped deployment path does not exist: $key = $resolved"
        } else {
            Add-ValidationResult ERROR "Configured path does not exist: $key = $resolved"
        }
    }

    $copyToClient = ConvertTo-ConfigBoolean (Get-ConfigValue $config 'Build' 'CopyToClient' 'true')
    $copyToServer = ConvertTo-ConfigBoolean (Get-ConfigValue $config 'Build' 'CopyToServer' 'true')
    if ($copyToClient -and -not $SkipClientDeploymentCheck -and $null -eq $resolvedPaths.RenegadeClientData) {
        Add-ValidationResult ERROR 'CopyToClient is true but RenegadeClientData is empty.'
    }
    if ($copyToServer -and -not $SkipServerDeploymentCheck -and $null -eq $resolvedPaths.FDSData) {
        Add-ValidationResult ERROR 'CopyToServer is true but FDSData is empty.'
    }

    $w3dFiles = @()
    if ($null -ne $resolvedPaths.ExportW3D -and (Test-Path -LiteralPath $resolvedPaths.ExportW3D -PathType Container)) {
        $w3dFiles = @(Get-ChildItem -LiteralPath $resolvedPaths.ExportW3D -File -Recurse -Filter '*.w3d')
    }
    if ($w3dFiles.Count -gt 0) {
        Add-ValidationResult OK ("Found {0} exported W3D file(s)." -f $w3dFiles.Count)
    } else {
        Add-ValidationResult ERROR 'No exported W3D files were found.'
    }

    $textureFiles = @()
    if ($null -ne $resolvedPaths.ExportTextures -and (Test-Path -LiteralPath $resolvedPaths.ExportTextures -PathType Container)) {
        $textureFiles = @(Get-ChildItem -LiteralPath $resolvedPaths.ExportTextures -File -Recurse | Where-Object { $_.Name -ne '.gitkeep' })
    }
    $supportedTextureExtensions = @('.dds', '.tga', '.png', '.jpg', '.jpeg', '.bmp')
    foreach ($file in $textureFiles) {
        if ($supportedTextureExtensions -notcontains $file.Extension.ToLowerInvariant()) {
            Add-ValidationResult ERROR "Unsupported texture extension: $($file.FullName)"
        }
    }
    if ($textureFiles.Count -eq 0) {
        Add-ValidationResult WARN 'No exported textures were found.'
    } else {
        Add-ValidationResult OK ("Checked {0} exported texture file(s)." -f $textureFiles.Count)
    }

    $contentFiles = @($w3dFiles) + @($textureFiles)
    if ($null -ne $resolvedPaths.LevelEditOutput -and (Test-Path -LiteralPath $resolvedPaths.LevelEditOutput -PathType Container)) {
        $contentFiles += @(Get-ChildItem -LiteralPath $resolvedPaths.LevelEditOutput -File -Recurse)
    }
    foreach ($file in $contentFiles) {
        if ($file.Length -eq 0) {
            Add-ValidationResult ERROR "Zero-byte file: $($file.FullName)"
        }
        if ($file.Name -notmatch '^[A-Za-z0-9_.&-]+$') {
            Add-ValidationResult WARN "Filename contains spaces or unusual characters: $($file.Name)"
        }
    }
    foreach ($group in ($contentFiles | Group-Object { $_.Name.ToLowerInvariant() } | Where-Object Count -gt 1)) {
        Add-ValidationResult WARN ("Duplicate filename '{0}' found at: {1}" -f $group.Name, (($group.Group.FullName) -join ', '))
    }

    $extension = (Get-ConfigValue $config 'Build' 'PackageExtension' 'mix').TrimStart('.')
    $expectedFile = "$mapName.$extension"
    if ($null -eq $resolvedPaths.LevelEditOutput -or -not (Test-Path -LiteralPath $resolvedPaths.LevelEditOutput -PathType Container)) {
        Add-ValidationResult ERROR 'The LevelEdit output directory does not exist.'
    } else {
        $finalMap = Join-Path $resolvedPaths.LevelEditOutput $expectedFile
        if (Test-Path -LiteralPath $finalMap -PathType Leaf) {
            Add-ValidationResult OK "Final map output exists and matches the configured name: $expectedFile"
        } else {
            Add-ValidationResult ERROR "Expected LevelEdit output was not found: $finalMap"
        }
    }

    $packagingToolRaw = Get-ConfigValue $config 'Paths' 'PackagingTool'
    $packagingTool = Resolve-ConfigPath $config $packagingToolRaw
    if ($null -eq $packagingTool) {
        Add-ValidationResult WARN 'No verified packaging tool is configured; builds will create staging output only unless a completed LevelEdit map exists.'
    } elseif (Test-Path -LiteralPath $packagingTool -PathType Leaf) {
        Add-ValidationResult OK "Configured packaging tool exists: $packagingTool"
        Add-ValidationResult WARN 'Packaging tool invocation is not enabled until its command-line interface is verified.'
    } else {
        Add-ValidationResult ERROR "Configured packaging tool does not exist: $packagingTool"
    }
} catch {
    Add-ValidationResult ERROR $_.Exception.Message
}

$errorCount = @($results | Where-Object Level -eq 'ERROR').Count
$warningCount = @($results | Where-Object Level -eq 'WARN').Count
$successCount = @($results | Where-Object Level -eq 'OK').Count
$summary = "Validation summary: $successCount successful, $warningCount warning(s), $errorCount error(s). Log: $logPath"
Write-Host $summary
    [System.IO.File]::AppendAllText($logPath, $summary + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
if ($errorCount -gt 0) { exit 1 }
exit 0
