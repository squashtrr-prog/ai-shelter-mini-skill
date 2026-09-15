[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Disaster,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Theme,

    [string]$Root = (Join-Path (Get-Location) 'outputs')
)

$ErrorActionPreference = 'Stop'

function ConvertTo-SafeName {
    param([Parameter(Mandatory = $true)][string]$Value)

    $safe = $Value.Trim()
    foreach ($char in [System.IO.Path]::GetInvalidFileNameChars()) {
        $safe = $safe.Replace([string]$char, '_')
    }
    $safe = $safe.TrimEnd('.', ' ')
    if ([string]::IsNullOrWhiteSpace($safe)) {
        throw 'Disaster or theme is empty after filename sanitization.'
    }
    return $safe
}

$safeDisaster = ConvertTo-SafeName -Value $Disaster
$safeTheme = ConvertTo-SafeName -Value $Theme
$rootPath = [System.IO.Path]::GetFullPath($Root)
[System.IO.Directory]::CreateDirectory($rootPath) | Out-Null

$baseName = '{0}-{1}+{2}' -f (Get-Date -Format 'yyyy-MM-dd'), $safeDisaster, $safeTheme
$projectPath = Join-Path $rootPath $baseName
$suffix = 2

while (Test-Path -LiteralPath $projectPath) {
    $projectPath = Join-Path $rootPath ('{0}-{1:d2}' -f $baseName, $suffix)
    $suffix++
}

$projectPath = [System.IO.Path]::GetFullPath($projectPath)
if (-not $projectPath.StartsWith($rootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Resolved project path escapes the selected root: $projectPath"
}

$directories = @(
    $projectPath,
    (Join-Path $projectPath '01_策划'),
    (Join-Path $projectPath '02_视频提示词'),
    (Join-Path $projectPath '03_图片提示词'),
    (Join-Path $projectPath '04_参考图'),
    (Join-Path $projectPath '05_衔接说明'),
    (Join-Path $projectPath '06_发布文案'),
    (Join-Path $projectPath '07_视频成片')
)

foreach ($directory in $directories) {
    [System.IO.Directory]::CreateDirectory($directory) | Out-Null
}

$projectPath

