[CmdletBinding()]
param(
    [switch]$VerboseOutput,
    [switch]$SkipClientCopy,
    [switch]$SkipServerCopy
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'tools\MapTools.psm1') -Force

$projectRoot = Get-ProjectRoot
$logPath = New-ProjectLog -ProjectRoot $projectRoot -Name 'build'

function Copy-WithExistingBackup {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$DestinationDirectory,
        [Parameter(Mandatory = $true)][string]$BackupDirectory
    )

    [System.IO.Directory]::CreateDirectory($DestinationDirectory) | Out-Null
    $destination = Join-Path $DestinationDirectory ([System.IO.Path]::GetFileName($Source))
    if (Test-Path -LiteralPath $destination -PathType Leaf) {
        [System.IO.Directory]::CreateDirectory($BackupDirectory) | Out-Null
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
        $backupName = '{0}-{1}{2}' -f [System.IO.Path]::GetFileNameWithoutExtension($destination), $timestamp, [System.IO.Path]::GetExtension($destination)
        $backupPath = Join-Path $BackupDirectory $backupName
        Copy-Item -LiteralPath $destination -Destination $backupPath -ErrorAction Stop
        Write-ProjectLog $script:logPath OK "Backed up existing deployed file to $backupPath" -VerboseOutput:$VerboseOutput
    }
    Copy-Item -LiteralPath $Source -Destination $destination -Force -ErrorAction Stop
    Write-ProjectLog $script:logPath OK "Copied completed map to $destination" -VerboseOutput:$VerboseOutput
}

try {
    $config = Get-ProjectConfiguration -CreateIfMissing
    $powerShell = Get-PowerShellExecutable
    $validationArguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $projectRoot 'ValidateMap.ps1'))
    if ($VerboseOutput) { $validationArguments += '-VerboseOutput' }
    if ($SkipClientCopy) { $validationArguments += '-SkipClientDeploymentCheck' }
    if ($SkipServerCopy) { $validationArguments += '-SkipServerDeploymentCheck' }
    & $powerShell @validationArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Validation failed with exit code $LASTEXITCODE. Build stopped before staging or deployment."
    }

    $mapName = Get-ConfigValue $config 'Map' 'Name' '' -Required
    $extension = (Get-ConfigValue $config 'Build' 'PackageExtension' 'mix').TrimStart('.')
    $w3dDirectory = Resolve-ConfigPath $config (Get-ConfigValue $config 'Paths' 'ExportW3D')
    $textureDirectory = Resolve-ConfigPath $config (Get-ConfigValue $config 'Paths' 'ExportTextures')
    $levelOutput = Resolve-ConfigPath $config (Get-ConfigValue $config 'Paths' 'LevelEditOutput')
    $clientData = Resolve-ConfigPath $config (Get-ConfigValue $config 'Paths' 'RenegadeClientData')
    $serverData = Resolve-ConfigPath $config (Get-ConfigValue $config 'Paths' 'FDSData')

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
    $stagingRoot = Join-Path $projectRoot ("package\staging\{0}-{1}" -f $mapName, $timestamp)
    Assert-SafeProjectChildPath $projectRoot $stagingRoot
    $stageW3D = Join-Path $stagingRoot 'w3d'
    $stageTextures = Join-Path $stagingRoot 'textures'
    $stageLevelEdit = Join-Path $stagingRoot 'level_edit'
    [System.IO.Directory]::CreateDirectory($stageW3D) | Out-Null
    [System.IO.Directory]::CreateDirectory($stageTextures) | Out-Null
    [System.IO.Directory]::CreateDirectory($stageLevelEdit) | Out-Null

    Get-ChildItem -LiteralPath $w3dDirectory -File -Recurse | Where-Object { $_.Name -ne '.gitkeep' } | Copy-Item -Destination $stageW3D -Force -ErrorAction Stop
    if (@(Get-ChildItem -LiteralPath $textureDirectory -File -Recurse | Where-Object { $_.Name -ne '.gitkeep' }).Count -gt 0) {
        Get-ChildItem -LiteralPath $textureDirectory -File -Recurse | Where-Object { $_.Name -ne '.gitkeep' } | Copy-Item -Destination $stageTextures -Force -ErrorAction Stop
    }
    Get-ChildItem -LiteralPath $levelOutput -File -Recurse | Where-Object { $_.Name -ne '.gitkeep' } | Copy-Item -Destination $stageLevelEdit -Force -ErrorAction Stop
    Write-ProjectLog $logPath OK "Created staging directory: $stagingRoot" -VerboseOutput:$VerboseOutput

    $finalMap = Join-Path $levelOutput ("$mapName.$extension")
    if (-not (Test-Path -LiteralPath $finalMap -PathType Leaf)) {
        Write-ProjectLog $logPath WARN "No completed $extension package was found. Staging is ready for an approved manual packaging step: $stagingRoot" -VerboseOutput
        Write-Host "Staging complete; manual packaging is required. Log: $logPath"
        exit 0
    }

    $releaseDirectory = Join-Path $projectRoot ("releases\{0}-{1}" -f $mapName, $timestamp)
    Assert-SafeProjectChildPath $projectRoot $releaseDirectory
    [System.IO.Directory]::CreateDirectory($releaseDirectory) | Out-Null
    $releaseMap = Join-Path $releaseDirectory ([System.IO.Path]::GetFileName($finalMap))
    Copy-Item -LiteralPath $finalMap -Destination $releaseMap -ErrorAction Stop
    Write-ProjectLog $logPath OK "Created release copy: $releaseMap" -VerboseOutput:$VerboseOutput

    $deploymentBackups = Join-Path $projectRoot 'backups\deployments'
    if (-not $SkipClientCopy -and (ConvertTo-ConfigBoolean (Get-ConfigValue $config 'Build' 'CopyToClient' 'true'))) {
        Copy-WithExistingBackup $releaseMap $clientData (Join-Path $deploymentBackups 'client')
    } else {
        Write-ProjectLog $logPath INFO 'Client deployment skipped.' -VerboseOutput:$VerboseOutput
    }
    if (-not $SkipServerCopy -and (ConvertTo-ConfigBoolean (Get-ConfigValue $config 'Build' 'CopyToServer' 'true'))) {
        Copy-WithExistingBackup $releaseMap $serverData (Join-Path $deploymentBackups 'server')
    } else {
        Write-ProjectLog $logPath INFO 'Server deployment skipped.' -VerboseOutput:$VerboseOutput
    }

    Write-Host "Build complete: $releaseMap"
    Write-Host "Log: $logPath"
    exit 0
} catch {
    Write-ProjectLog $logPath ERROR $_.Exception.Message -VerboseOutput
    Write-Host "Build failed. Log: $logPath"
    exit 1
}
