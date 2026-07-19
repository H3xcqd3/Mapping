[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [switch]$ConfirmClean,
    [switch]$VerboseOutput
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'tools\MapTools.psm1') -Force

$projectRoot = Get-ProjectRoot
$logPath = New-ProjectLog -ProjectRoot $projectRoot -Name 'clean'

try {
    $preview = $PSBoundParameters.ContainsKey('WhatIf')
    if (-not $ConfirmClean -and -not $preview) {
        throw 'Cleaning requires -ConfirmClean. Use -WhatIf alone to preview safely.'
    }

    $targets = @(
        (Join-Path $projectRoot 'package\staging'),
        (Join-Path $projectRoot 'package\temp'),
        (Join-Path $projectRoot 'tmp\build')
    )
    $found = $false
    foreach ($target in $targets) {
        Assert-SafeProjectChildPath $projectRoot $target
        if (-not (Test-Path -LiteralPath $target)) {
            Write-ProjectLog $logPath INFO "Generated path does not exist: $target" -VerboseOutput:$VerboseOutput
            continue
        }
        $found = $true
        if ($PSCmdlet.ShouldProcess($target, 'Remove generated staging or temporary build files')) {
            Remove-Item -LiteralPath $target -Recurse -Force -ErrorAction Stop
            Write-ProjectLog $logPath OK "Removed generated path: $target" -VerboseOutput:$VerboseOutput
        }
    }
    if (-not $found) { Write-Host 'No generated staging or temporary build files were found.' }
    Write-Host "Clean operation complete. Source, exports, LevelEdit projects, releases, and backups were preserved. Log: $logPath"
    exit 0
} catch {
    Write-ProjectLog $logPath ERROR $_.Exception.Message -VerboseOutput
    Write-Host "Clean operation failed. Log: $logPath"
    exit 1
}
