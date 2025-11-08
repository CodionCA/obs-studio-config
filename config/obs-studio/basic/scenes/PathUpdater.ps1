# OBS Studio Path Fixer - Auto-detect version
$ErrorActionPreference = "Stop"

Write-Host "OBS Path Fixer Starting..." -ForegroundColor Cyan
Write-Host ""

# Try to find OBS config by looking in common locations
$possiblePaths = @(
    "$PSScriptRoot",  # Current script location
    "$PSScriptRoot\..",
    "$PSScriptRoot\..\..",
    "$PSScriptRoot\..\..\..",
    "$env:USERPROFILE\scoop\persist\obs-studio\config\obs-studio"
)

$obsConfig = $null
foreach ($path in $possiblePaths) {
    $testPath = Resolve-Path $path -ErrorAction SilentlyContinue
    if ($testPath -and (Test-Path "$testPath\basic\scenes\*.json")) {
        $obsConfig = $testPath.Path
        break
    }
}

if (-not $obsConfig) {
    Write-Host "Could not auto-detect OBS config location" -ForegroundColor Red
    Write-Host "Please drag and drop this script into your OBS config folder" -ForegroundColor Yellow
    Write-Host "Location should be: scoop\persist\obs-studio\config\obs-studio" -ForegroundColor Yellow
    pause
    exit
}

Write-Host "OBS config found at: $obsConfig" -ForegroundColor Green

# Find a JSON file with paths to detect old Scoop location
$sampleFile = Get-ChildItem -Path $obsConfig -Recurse -Filter "*.json" | Select-Object -First 1
if (-not $sampleFile) {
    Write-Host "No JSON files found!" -ForegroundColor Red
    pause
    exit
}

# Read sample file and extract old scoop path
$content = Get-Content $sampleFile.FullName -Raw
if ($content -match '([A-Z]:/[^/]+/scoop)/persist/obs-studio') {
    $oldScoopPath = $matches[1]
} elseif ($content -match '([A-Z]:\\[^\\]+\\scoop)\\persist\\obs-studio') {
    $oldScoopPath = $matches[1].Replace('\', '/')
} else {
    Write-Host "Could not detect old Scoop path from config files" -ForegroundColor Red
    Write-Host "Your files may already be using relative paths or have no hardcoded paths" -ForegroundColor Yellow
    pause
    exit
}

Write-Host "Detected old Scoop path: $oldScoopPath" -ForegroundColor Yellow

# Determine new Scoop path from OBS config location
if ($obsConfig -match '(.+[/\\]scoop)[/\\]persist') {
    $newScoopPath = $matches[1].Replace('\', '/')
} else {
    Write-Host "Could not determine new Scoop path" -ForegroundColor Red
    pause
    exit
}

Write-Host "New Scoop path will be: $newScoopPath" -ForegroundColor Green
Write-Host ""

# Create backup folder
$backup = "$obsConfig\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $backup -Force | Out-Null
Write-Host "Backup folder: $backup" -ForegroundColor Yellow
Write-Host ""

# New base path for OBS
$newBasePath = "$newScoopPath/persist/obs-studio"

# Process all JSON files
$files = Get-ChildItem -Path $obsConfig -Recurse -Filter "*.json"
Write-Host "Processing $($files.Count) files..." -ForegroundColor Cyan
Write-Host ""

$changedCount = 0
foreach ($file in $files) {
    # Backup
    Copy-Item $file.FullName -Destination "$backup\$($file.Name)" -Force
    
    # Read and replace
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $original = $content
    
    # Replace the old scoop path with new one
    $content = $content -replace [regex]::Escape($oldScoopPath) + '/persist/obs-studio', $newBasePath
    $content = $content -replace [regex]::Escape($oldScoopPath.Replace('/', '\')) + '\\persist\\obs-studio', $newBasePath.Replace('/', '\')
    
    # Save if changed
    if ($content -ne $original) {
        $content | Set-Content $file.FullName -Encoding UTF8 -NoNewline
        Write-Host "Updated: $($file.Name)" -ForegroundColor Green
        $changedCount++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Complete! Updated $changedCount files" -ForegroundColor Green
Write-Host "Old path: $oldScoopPath/persist/obs-studio" -ForegroundColor Yellow
Write-Host "New path: $newBasePath" -ForegroundColor Green
Write-Host "Backup: $backup" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
pause