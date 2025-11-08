# OBS Path Fixer - Simple version that works in current folder
$ErrorActionPreference = "Stop"

Write-Host "OBS Path Fixer" -ForegroundColor Cyan
Write-Host ""

# Work in the same folder as the script
$workFolder = $PSScriptRoot

Write-Host "Working in: $workFolder" -ForegroundColor White

# Find where this user's Scoop is installed by looking at the current path
if ($workFolder -match '(.+[/\\]scoop)[/\\](persist|apps)') {
    $newScoopPath = $matches[1].Replace('\', '/')
} else {
    Write-Host "ERROR: Could not detect Scoop path" -ForegroundColor Red
    Write-Host "Current folder: $workFolder" -ForegroundColor Yellow
    Write-Host "This script must be run from inside a Scoop folder" -ForegroundColor Yellow
    pause
    exit
}

Write-Host "Detected Scoop at: $newScoopPath" -ForegroundColor Green

# Your old hardcoded path
$oldScoopPath = "S:/Portable/scoop"
$newBasePath = "$newScoopPath/persist/obs-studio"
$oldBasePath = "$oldScoopPath/persist/obs-studio"

Write-Host "Will replace: $oldBasePath" -ForegroundColor Yellow
Write-Host "With: $newBasePath" -ForegroundColor Green
Write-Host ""

# Find all JSON files in current folder and subfolders
$files = Get-ChildItem -Path $workFolder -Recurse -Filter "*.json" -ErrorAction SilentlyContinue

if (-not $files -or $files.Count -eq 0) {
    Write-Host "No JSON files found in this folder" -ForegroundColor Red
    pause
    exit
}

Write-Host "Found $($files.Count) JSON files" -ForegroundColor White
Write-Host ""

# Create backup
$backup = "$workFolder\path_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $backup -Force | Out-Null

$changedCount = 0
foreach ($file in $files) {
    # Backup
    $relativePath = $file.FullName.Substring($workFolder.Length + 1)
    $backupFile = Join-Path $backup $relativePath
    $backupDir = Split-Path $backupFile -Parent
    if ($backupDir -and -not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    Copy-Item $file.FullName -Destination $backupFile -Force
    
    # Read and replace
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $original = $content
    
    # Replace S:/Portable/scoop paths with new scoop path
    $content = $content -replace [regex]::Escape($oldScoopPath), $newScoopPath
    $content = $content -replace [regex]::Escape($oldScoopPath.Replace('/', '\')), $newScoopPath.Replace('/', '\')
    
    # Save if changed
    if ($content -ne $original) {
        $content | Set-Content $file.FullName -Encoding UTF8 -NoNewline
        Write-Host "  Updated: $relativePath" -ForegroundColor Green
        $changedCount++
    }
}

Write-Host ""
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "Done! Updated $changedCount files" -ForegroundColor Green
Write-Host "Backup: $backup" -ForegroundColor White
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""
pause