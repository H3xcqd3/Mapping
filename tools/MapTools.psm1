Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ProjectRoot {
    [CmdletBinding()]
    param()

    return [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
}

function Read-IniFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Configuration file not found: $Path"
    }

    $result = @{}
    $sectionName = $null
    $lineNumber = 0

    foreach ($rawLine in [System.IO.File]::ReadAllLines($Path)) {
        $lineNumber++
        $line = $rawLine.Trim()
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith(';') -or $line.StartsWith('#')) {
            continue
        }

        if ($line -match '^\[(?<section>[^\]]+)\]$') {
            $sectionName = $Matches.section.Trim()
            if ($result.ContainsKey($sectionName)) {
                throw "Duplicate INI section [$sectionName] at line $lineNumber."
            }
            $result[$sectionName] = @{}
            continue
        }

        if ($null -eq $sectionName -or $line -notmatch '^(?<key>[^=]+)=(?<value>.*)$') {
            throw "Invalid INI syntax at line $lineNumber in $Path."
        }

        $key = $Matches.key.Trim()
        $value = $Matches.value.Trim()
        if ($result[$sectionName].ContainsKey($key)) {
            throw "Duplicate INI key [$sectionName] $key at line $lineNumber."
        }
        $result[$sectionName][$key] = $value
    }

    return $result
}

function Get-ProjectConfiguration {
    [CmdletBinding()]
    param(
        [switch]$CreateIfMissing
    )

    $root = Get-ProjectRoot
    $path = Join-Path $root 'config\map-build.ini'
    $example = Join-Path $root 'config\map-build.example.ini'

    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        if ($CreateIfMissing) {
            Copy-Item -LiteralPath $example -Destination $path -ErrorAction Stop
            throw "Created $path from the example. Edit its local paths, then run this command again."
        }
        throw "Configuration is missing. Copy '$example' to '$path' and edit the local paths."
    }

    return [pscustomobject]@{
        Root = $root
        Path = $path
        Data = Read-IniFile -Path $path
    }
}

function Get-ConfigValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Configuration,
        [Parameter(Mandatory = $true)][string]$Section,
        [Parameter(Mandatory = $true)][string]$Key,
        [string]$Default = '',
        [switch]$Required
    )

    $value = $Default
    if ($Configuration.Data.ContainsKey($Section) -and $Configuration.Data[$Section].ContainsKey($Key)) {
        $value = [string]$Configuration.Data[$Section][$Key]
    }

    if ($Required -and [string]::IsNullOrWhiteSpace($value)) {
        throw "Required configuration value [$Section] $Key is empty."
    }
    return $value
}

function Resolve-ConfigPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Configuration,
        [AllowEmptyString()][string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    $expanded = [Environment]::ExpandEnvironmentVariables($Value.Trim().Trim('"'))
    if ([System.IO.Path]::IsPathRooted($expanded)) {
        return [System.IO.Path]::GetFullPath($expanded)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $Configuration.Root $expanded))
}

function ConvertTo-ConfigBoolean {
    [CmdletBinding()]
    param(
        [AllowEmptyString()][string]$Value,
        [bool]$Default = $false
    )

    if ([string]::IsNullOrWhiteSpace($Value)) { return $Default }
    switch ($Value.Trim().ToLowerInvariant()) {
        'true' { return $true }
        'yes' { return $true }
        '1' { return $true }
        'false' { return $false }
        'no' { return $false }
        '0' { return $false }
        default { throw "Invalid Boolean value '$Value'. Use true or false." }
    }
}

function Assert-SafeProjectChildPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][string]$TargetPath
    )

    $root = [System.IO.Path]::GetFullPath($ProjectRoot).TrimEnd('\', '/')
    $target = [System.IO.Path]::GetFullPath($TargetPath).TrimEnd('\', '/')
    $prefix = $root + [System.IO.Path]::DirectorySeparatorChar
    if ($target.Equals($root, [StringComparison]::OrdinalIgnoreCase) -or
        -not $target.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Unsafe generated path outside the project or equal to its root: $target"
    }
}

function New-ProjectLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $logDirectory = Join-Path $ProjectRoot 'logs'
    [System.IO.Directory]::CreateDirectory($logDirectory) | Out-Null
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
    return Join-Path $logDirectory ("{0}-{1}.log" -f $Name, $timestamp)
}

function Write-ProjectLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][ValidateSet('INFO', 'OK', 'WARN', 'ERROR')][string]$Level,
        [Parameter(Mandatory = $true)][string]$Message,
        [switch]$VerboseOutput
    )

    $line = '{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    [System.IO.File]::AppendAllText($Path, $line + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
    if ($Level -in @('WARN', 'ERROR') -or $VerboseOutput) {
        Write-Host $line
    }
}

function Get-PowerShellExecutable {
    [CmdletBinding()]
    param()

    $desktopPowerShell = Get-Command powershell.exe -ErrorAction SilentlyContinue
    if ($null -ne $desktopPowerShell) { return $desktopPowerShell.Source }
    $corePowerShell = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    if ($null -ne $corePowerShell) { return $corePowerShell.Source }
    throw 'No PowerShell executable was found for running child validation scripts.'
}

Export-ModuleMember -Function @(
    'Get-ProjectRoot',
    'Read-IniFile',
    'Get-ProjectConfiguration',
    'Get-ConfigValue',
    'Resolve-ConfigPath',
    'ConvertTo-ConfigBoolean',
    'Assert-SafeProjectChildPath',
    'New-ProjectLog',
    'Write-ProjectLog',
    'Get-PowerShellExecutable'
)
