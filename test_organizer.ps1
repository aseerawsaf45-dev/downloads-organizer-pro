# Automated Verification Test Suite for Downloads Organizer Pro
$ErrorActionPreference = 'Stop'
$testDir = "C:\Users\Awsaf\.gemini\antigravity-ide\scratch\downloads-organizer\test_sandbox"

if (Test-Path -LiteralPath $testDir) {
    Remove-Item -LiteralPath $testDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

Write-Host "Creating mock downloads sandbox at: $testDir" -ForegroundColor Cyan

# 1. Create standard test files
Set-Content (Join-Path $testDir 'report.pdf') "PDF document content"
Set-Content (Join-Path $testDir 'financials.xlsx') "Excel spreadsheet"
Set-Content (Join-Path $testDir 'song.flac') "FLAC audio content"
Set-Content (Join-Path $testDir 'clip.mp4') "MP4 video content"
Set-Content (Join-Path $testDir 'backup.tar.gz') "GZ archive"
Set-Content (Join-Path $testDir 'setup.msi') "Installer package"
Set-Content (Join-Path $testDir 'ubuntu.iso') "Disk image"
Set-Content (Join-Path $testDir 'script.py') "Python code"
Set-Content (Join-Path $testDir 'font.woff2') "Font file"
Set-Content (Join-Path $testDir 'book.epub') "Ebook"
Set-Content (Join-Path $testDir 'bracket.stl') "3D model"
Set-Content (Join-Path $testDir 'distro.torrent') "Torrent file"

# 2. In-progress download files (MUST BE PRESERVED/SKIPPED)
Set-Content (Join-Path $testDir 'huge_movie.mp4.crdownload') "Active chrome download"
Set-Content (Join-Path $testDir 'tempfile.tmp') "Temporary lock file"

# 3. Extensionless file with PNG magic bytes (\x89PNG)
$pngBytes = [byte[]](0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D)
[System.IO.File]::WriteAllBytes((Join-Path $testDir 'mystery_image_no_ext'), $pngBytes)

# 4. Codebase folder (with package.json)
$codeDir = Join-Path $testDir 'my-web-app'
New-Item -ItemType Directory -Path $codeDir -Force | Out-Null
Set-Content (Join-Path $codeDir 'package.json') '{"name": "test-app"}'
Set-Content (Join-Path $codeDir 'index.js') 'console.log("hello");'

# 5. Pure Photos folder (two jpgs)
$photoDir = Join-Path $testDir 'VacationPhotos'
New-Item -ItemType Directory -Path $photoDir -Force | Out-Null
Set-Content (Join-Path $photoDir 'beach.jpg') "image 1"
Set-Content (Join-Path $photoDir 'sunset.jpg') "image 2"

# 6. Mixed folder
$mixedDir = Join-Path $testDir 'RandomStuff'
New-Item -ItemType Directory -Path $mixedDir -Force | Out-Null
Set-Content (Join-Path $mixedDir 'notes.txt') "text"
Set-Content (Join-Path $mixedDir 'binary.bin') "binary"

Write-Host "Sandbox populated. Running Organizer Engine..." -ForegroundColor Cyan

# Run engine in non-interactive mode
& "C:\Users\Awsaf\.gemini\antigravity-ide\scratch\downloads-organizer\Downloads_Organizer_Engine.ps1" -TargetDirectory $testDir -NonInteractive

Write-Host "`n--- VERIFYING ASSERTIONS ---" -ForegroundColor Cyan

$assertions = @(
    @{ Path = (Join-Path $testDir 'Documents\report.pdf'); Expected = $true; Name = "Documents: report.pdf" }
    @{ Path = (Join-Path $testDir 'Documents\financials.xlsx'); Expected = $true; Name = "Documents: financials.xlsx" }
    @{ Path = (Join-Path $testDir 'Audio\song.flac'); Expected = $true; Name = "Audio: song.flac" }
    @{ Path = (Join-Path $testDir 'Videos\clip.mp4'); Expected = $true; Name = "Videos: clip.mp4" }
    @{ Path = (Join-Path $testDir 'Archives\backup.tar.gz'); Expected = $true; Name = "Archives: backup.tar.gz" }
    @{ Path = (Join-Path $testDir 'Installers\setup.msi'); Expected = $true; Name = "Installers: setup.msi" }
    @{ Path = (Join-Path $testDir 'Disk Images\ubuntu.iso'); Expected = $true; Name = "Disk Images: ubuntu.iso" }
    @{ Path = (Join-Path $testDir 'Code\script.py'); Expected = $true; Name = "Code: script.py" }
    @{ Path = (Join-Path $testDir 'Fonts\font.woff2'); Expected = $true; Name = "Fonts: font.woff2" }
    @{ Path = (Join-Path $testDir 'eBooks\book.epub'); Expected = $true; Name = "eBooks: book.epub" }
    @{ Path = (Join-Path $testDir '3D & CAD\bracket.stl'); Expected = $true; Name = "3D & CAD: bracket.stl" }
    @{ Path = (Join-Path $testDir 'Torrents & Links\distro.torrent'); Expected = $true; Name = "Torrents: distro.torrent" }
    @{ Path = (Join-Path $testDir 'Images\mystery_image_no_ext'); Expected = $true; Name = "Magic Bytes Sniffer: mystery_image_no_ext -> Images" }
    @{ Path = (Join-Path $testDir 'Codebases\my-web-app'); Expected = $true; Name = "Codebases: my-web-app" }
    @{ Path = (Join-Path $testDir 'Images\VacationPhotos'); Expected = $true; Name = "Pure photo folder -> Images" }
    @{ Path = (Join-Path $testDir 'Other\RandomStuff'); Expected = $true; Name = "Mixed folder -> Other" }
    # Active downloads MUST stay at root of testDir
    @{ Path = (Join-Path $testDir 'huge_movie.mp4.crdownload'); Expected = $true; Name = "Safety Guard: .crdownload left untouched" }
    @{ Path = (Join-Path $testDir 'tempfile.tmp'); Expected = $true; Name = "Safety Guard: .tmp left untouched" }
)

$passed = 0
$failed = 0

foreach ($a in $assertions) {
    $exists = Test-Path -LiteralPath $a.Path
    if ($exists -eq $a.Expected) {
        Write-Host "  [PASS] $($a.Name)" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "  [FAIL] $($a.Name) (Expected: $($a.Expected), Got: $exists)" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`n--- TESTING ROLLBACK / UNDO ---" -ForegroundColor Cyan
& "C:\Users\Awsaf\.gemini\antigravity-ide\scratch\downloads-organizer\Downloads_Organizer_Engine.ps1" -TargetDirectory $testDir -Undo

# Verify that files are restored back to root of testDir
$undoChecks = @(
    (Join-Path $testDir 'report.pdf'),
    (Join-Path $testDir 'financials.xlsx'),
    (Join-Path $testDir 'song.flac'),
    (Join-Path $testDir 'clip.mp4'),
    (Join-Path $testDir 'my-web-app'),
    (Join-Path $testDir 'VacationPhotos')
)

$undoPassed = $true
foreach ($p in $undoChecks) {
    if (-not (Test-Path -LiteralPath $p)) {
        Write-Host "  [FAIL UNDO] Did not restore: $p" -ForegroundColor Red
        $undoPassed = $false
    }
}

if ($undoPassed) {
    Write-Host "  [PASS] Rollback restored all items to their original locations!" -ForegroundColor Green
}

# Cleanup testDir
Remove-Item -LiteralPath $testDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`nTest Suite Summary: $passed passed, $failed failed."
if ($failed -gt 0 -or -not $undoPassed) {
    throw "Verification tests failed!"
}
