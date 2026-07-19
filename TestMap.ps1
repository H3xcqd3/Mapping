[CmdletBinding()]
param(
    [switch]$ServerOnly,
    [switch]$ClientOnly,
    [switch]$VerboseOutput
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'tools\MapTools.psm1') -Force

$projectRoot = Get-ProjectRoot
$logPath = New-ProjectLog -ProjectRoot $projectRoot -Name 'test'

try {
    if ($ServerOnly -and $ClientOnly) {
        throw 'ServerOnly and ClientOnly cannot be used together.'
    }

    $config = Get-ProjectConfiguration -CreateIfMissing
    $mapName = Get-ConfigValue $config 'Map' 'Name' '' -Required
    $extension = (Get-ConfigValue $config 'Build' 'PackageExtension' 'mix').TrimStart('.')
    $releasesDirectory = Join-Path $projectRoot 'releases'
    $builtMaps = @(Get-ChildItem -LiteralPath $releasesDirectory -File -Recurse -Filter "$mapName.$extension" | Sort-Object LastWriteTime -Descending)
    if ($builtMaps.Count -eq 0) {
        throw "No built map named $mapName.$extension was found under $releasesDirectory."
    }
    Write-ProjectLog $logPath OK "Using build: $($builtMaps[0].FullName)" -VerboseOutput:$VerboseOutput

    $startServer = -not $ClientOnly
    $startClient = -not $ServerOnly
    if ($startServer) {
        $serverRaw = Get-ConfigValue $config 'Test' 'ServerExecutable'
        if ([string]::IsNullOrWhiteSpace($serverRaw)) { $serverRaw = Get-ConfigValue $config 'Paths' 'FDS' }
        $serverExecutable = Resolve-ConfigPath $config $serverRaw
        if ($null -eq $serverExecutable -or -not (Test-Path -LiteralPath $serverExecutable -PathType Leaf)) {
            throw "Configured server executable was not found: $serverExecutable"
        }
        $serverArguments = Get-ConfigValue $config 'Test' 'ServerArguments'
        $serverProcess = Start-Process -FilePath $serverExecutable -ArgumentList $serverArguments -WorkingDirectory ([System.IO.Path]::GetDirectoryName($serverExecutable)) -PassThru
        Write-ProjectLog $logPath OK "Started server process $($serverProcess.Id): $serverExecutable" -VerboseOutput:$VerboseOutput
    }

    if ($startClient) {
        $delayText = Get-ConfigValue $config 'Test' 'ClientLaunchDelaySeconds' '5'
        $delay = 0
        if (-not [int]::TryParse($delayText, [ref]$delay) -or $delay -lt 0) {
            throw "ClientLaunchDelaySeconds must be a non-negative integer; received '$delayText'."
        }
        if ($startServer -and $delay -gt 0) {
            Write-ProjectLog $logPath INFO "Waiting $delay second(s) before starting the client." -VerboseOutput:$VerboseOutput
            Start-Sleep -Seconds $delay
        }

        $clientRaw = Get-ConfigValue $config 'Test' 'ClientExecutable'
        if ([string]::IsNullOrWhiteSpace($clientRaw)) { $clientRaw = Get-ConfigValue $config 'Paths' 'RenegadeClient' }
        $clientExecutable = Resolve-ConfigPath $config $clientRaw
        if ($null -eq $clientExecutable -or -not (Test-Path -LiteralPath $clientExecutable -PathType Leaf)) {
            throw "Configured client executable was not found: $clientExecutable"
        }
        $clientArguments = Get-ConfigValue $config 'Test' 'ClientArguments'
        $clientProcess = Start-Process -FilePath $clientExecutable -ArgumentList $clientArguments -WorkingDirectory ([System.IO.Path]::GetDirectoryName($clientExecutable)) -PassThru
        Write-ProjectLog $logPath OK "Started client process $($clientProcess.Id): $clientExecutable" -VerboseOutput:$VerboseOutput
    }

    Write-Host "Test launch complete. Existing game and server processes were not changed. Log: $logPath"
    exit 0
} catch {
    Write-ProjectLog $logPath ERROR $_.Exception.Message -VerboseOutput
    Write-Host "Test launch failed. Log: $logPath"
    exit 1
}
