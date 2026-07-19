[CmdletBinding()]
param(
    [switch]$VerboseOutput
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'tools\MapTools.psm1') -Force

$projectRoot = Get-ProjectRoot
$logPath = New-ProjectLog -ProjectRoot $projectRoot -Name 'backup'

try {
    $config = Get-ProjectConfiguration -CreateIfMissing
    $mapName = Get-ConfigValue $config 'Map' 'Name' '' -Required
    $retentionText = Get-ConfigValue $config 'Build' 'BackupRetention' '20'
    $retention = 0
    if (-not [int]::TryParse($retentionText, [ref]$retention) -or $retention -lt 1) {
        throw "BackupRetention must be a positive integer; received '$retentionText'."
    }

    $backupDirectory = Join-Path $projectRoot 'backups'
    Assert-SafeProjectChildPath $projectRoot $backupDirectory
    [System.IO.Directory]::CreateDirectory($backupDirectory) | Out-Null
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
    $archivePath = Join-Path $backupDirectory ("{0}-source-{1}.zip" -f $mapName, $timestamp)
    $items = @('source', 'config', 'export') | ForEach-Object { Join-Path $projectRoot $_ } | Where-Object { Test-Path -LiteralPath $_ }
    if (@($items).Count -eq 0) { throw 'No source, configuration, or export directories were found to back up.' }

    Compress-Archive -LiteralPath $items -DestinationPath $archivePath -CompressionLevel Optimal -ErrorAction Stop
    Write-ProjectLog $logPath OK "Created backup: $archivePath" -VerboseOutput:$VerboseOutput

    $archives = @(Get-ChildItem -LiteralPath $backupDirectory -File -Filter "$mapName-source-*.zip" | Sort-Object LastWriteTime -Descending)
    if ($archives.Count -gt $retention) {
        foreach ($oldArchive in ($archives | Select-Object -Skip $retention)) {
            Assert-SafeProjectChildPath $projectRoot $oldArchive.FullName
            Remove-Item -LiteralPath $oldArchive.FullName -Force
            Write-ProjectLog $logPath INFO "Removed expired backup: $($oldArchive.Name)" -VerboseOutput:$VerboseOutput
        }
    }
    Write-Host "Backup complete: $archivePath"
    exit 0
} catch {
    Write-ProjectLog $logPath ERROR $_.Exception.Message -VerboseOutput
    Write-Host "Backup failed. Log: $logPath"
    exit 1
}
