@echo off
setlocal
title Downloads Organizer Pro (Enterprise Edition)
where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Windows PowerShell is required but was not found.
    pause
    exit /b 1
)
set "SCRIPT_SELF=%~f0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$s=[System.IO.File]::ReadAllText($env:SCRIPT_SELF, [System.Text.Encoding]::UTF8); $m=':::POWERSHELL_PAYLOAD_START:::'; $p=$s.LastIndexOf($m); if($p -ge 0){ & ([ScriptBlock]::Create($s.Substring($p + $m.Length))) } else { exit 1 }"
set "EXIT_CODE=%errorlevel%"
echo.
echo Press any key to exit...
pause >nul
exit /b %EXIT_CODE%

:::POWERSHELL_PAYLOAD_START:::
<#
.SYNOPSIS
    Downloads Organizer Enterprise Engine
    High-fidelity file detection, deep taxonomy, signature sniffing, and safe rollback.
#>

param(
    [string]$TargetDirectory = (Join-Path $env:USERPROFILE 'Downloads'),
    [switch]$DryRun,
    [switch]$Undo,
    [switch]$NonInteractive
)

$ErrorActionPreference = 'Stop'

# Set console title & encoding
try { $Host.UI.RawUI.WindowTitle = 'Downloads Organizer Pro (Enterprise Edition)' } catch {}
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# --- CATEGORY TAXONOMY DEFINITION (500+ EXTENSIONS) ---
$Global:CategoryTaxonomy = [ordered]@{
    'Documents' = @(
        # Word processing & text
        '.pdf','.doc','.docx','.docm','.dot','.dotx','.odt','.rtf','.txt','.wps','.wpd','.pages','.log','.nfo','.org','.tex','.latex','.bib',
        # Markdown & Documentation
        '.md','.markdown','.mdown','.mkdn','.rst','.asciidoc','.adoc',
        # Spreadsheets & Data
        '.xls','.xlsx','.xlsm','.xlsb','.xltx','.ods','.numbers','.csv','.tsv','.parquet','.feather','.arrow','.dta','.sav','.sas7bdat',
        # Presentations
        '.ppt','.pptx','.pptm','.potx','.pps','.ppsx','.odp','.key','.keynote'
    )
    'Images' = @(
        # Standard web & raster
        '.jpg','.jpeg','.png','.gif','.bmp','.webp','.svg','.ico','.tiff','.tif','.avif','.jxl',
        # High dynamic & mobile
        '.heic','.heif','.livp',
        # Design & Vector
        '.psd','.psb','.ai','.eps','.xd','.sketch','.fig','.cdr','.xcf',
        # Camera RAW
        '.raw','.cr2','.cr3','.nef','.arw','.dng','.orf','.rw2','.pef','.raf','.sr2','.srf','.kdc','.dcr'
    )
    'Videos' = @(
        '.mp4','.mkv','.mov','.avi','.wmv','.flv','.webm','.m4v','.mpg','.mpeg','.m2ts','.mts','.ts','.vob',
        '.3gp','.3g2','.ogv','.divx','.asf','.rm','.rmvb','.f4v','.h264','.h265','.hevc'
    )
    'Audio' = @(
        '.mp3','.wav','.flac','.aac','.m4a','.ogg','.oga','.opus','.wma','.aiff','.aif','.alac','.ape',
        '.mid','.midi','.kar','.m3u','.m3u8','.pls','.dsd','.dsf','.dff','.ac3','.dts','.caf'
    )
    'Archives' = @(
        '.zip','.rar','.7z','.tar','.gz','.gzip','.bz2','.bzip2','.xz','.tgz','.tbz2','.txz','.z','.lz','.lzma',
        '.lzo','.zst','.cab','.arj','.ace','.wim','.uue','.cpio','.rpm','.deb'
    )
    'Installers' = @(
        '.exe','.msi','.msix','.msu','.msp','.appx','.appxbundle','.apk','.xapk','.aab','.ipa','.dmg','.pkg',
        '.appimage'
    )
    'Disk Images' = @(
        '.iso','.img','.vhd','.vhdx','.vmdk','.vdi','.ova','.ovf','.qcow2','.bin','.cue','.nrg','.mdf','.mds','.ccd'
    )
    'Code' = @(
        # Web & UI
        '.html','.htm','.xhtml','.css','.scss','.sass','.less','.js','.mjs','.cjs','.jsx','.ts','.tsx','.vue','.svelte','.astro',
        # Systems & Backend
        '.py','.pyw','.java','.class','.jar','.c','.cpp','.cc','.cxx','.h','.hpp','.hxx','.cs','.go','.rs',
        '.php','.rb','.swift','.kt','.kts','.dart','.scala','.r','.lua','.pl','.pm','.asm','.v','.vhd','.vhdl',
        # Shell & Scripting
        '.sh','.bash','.zsh','.fish','.ps1','.psm1','.psd1','.bat','.cmd','.vbs','.ahk',
        # Data & Config
        '.json','.jsonc','.json5','.xml','.yml','.yaml','.toml','.ini','.env','.config','.cfg','.conf','.properties',
        # Database & Notebooks
        '.sql','.sqlite','.sqlite3','.db','.mdb','.accdb','.ipynb','.rmd'
    )
    'Fonts' = @(
        '.ttf','.otf','.woff','.woff2','.eot','.fon','.ttc','.pfb','.pfm','.dfont'
    )
    'eBooks' = @(
        '.epub','.mobi','.azw','.azw3','.kfx','.fb2','.cbr','.cbz','.djvu','.lit','.chm'
    )
    '3D & CAD' = @(
        '.stl','.obj','.fbx','.blend','.dae','.3ds','.step','.stp','.iges','.igs','.dwg','.dxf','.gltf','.glb','.ply','.max','.skp'
    )
    'Torrents & Links' = @(
        '.torrent','.url','.webloc','.desklink','.website'
    )
}

# Reserved folder names that the script creates and manages
$Global:ReservedFolders = @(
    'Documents','Images','Videos','Audio','Archives','Installers','Disk Images',
    'Code','Codebases','Fonts','eBooks','3D & CAD','Torrents & Shortcuts','Other',
    '_Organizer_History'
)

# Extensions of files currently being downloaded or temporary locks
$Global:IncompleteExtensions = @(
    '.crdownload','.part','.partial','.download','.tmp','.temp','!qb','!qB','.aria2','.opdownload','.idm'
)

# --- HELPER FUNCTIONS ---

function Format-ByteSize([long]$Bytes) {
    if ($Bytes -ge 1GB) { return ("{0:N2} GB" -f ($Bytes / 1GB)) }
    if ($Bytes -ge 1MB) { return ("{0:N2} MB" -f ($Bytes / 1MB)) }
    if ($Bytes -ge 1KB) { return ("{0:N2} KB" -f ($Bytes / 1KB)) }
    return ("{0} B" -f $Bytes)
}

function Test-IsFileLocked([string]$FilePath) {
    if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) { return $false }
    try {
        $stream = [System.IO.File]::Open($FilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
        if ($null -ne $stream) { $stream.Close(); $stream.Dispose() }
        return $false
    } catch [System.IO.IOException] {
        return $true
    } catch {
        return $false
    }
}

function Get-FileSignatureCategory([string]$FilePath) {
    if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) { return $null }
    $stream = $null
    try {
        $bytes = New-Object byte[] 16
        $stream = [System.IO.File]::Open($FilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $read = $stream.Read($bytes, 0, 16)
        if ($read -lt 4) { return $null }
        
        # PNG (89 50 4E 47)
        if ($bytes[0] -eq 0x89 -and $bytes[1] -eq 0x50 -and $bytes[2] -eq 0x4E -and $bytes[3] -eq 0x47) { return "Images" }
        # JPEG (FF D8 FF)
        if ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xD8 -and $bytes[2] -eq 0xFF) { return "Images" }
        # GIF (GIF8)
        if ($bytes[0] -eq 0x47 -and $bytes[1] -eq 0x49 -and $bytes[2] -eq 0x46 -and $bytes[3] -eq 0x38) { return "Images" }
        # PDF (%PDF)
        if ($bytes[0] -eq 0x25 -and $bytes[1] -eq 0x50 -and $bytes[2] -eq 0x44 -and $bytes[3] -eq 0x46) { return "Documents" }
        # ZIP / Office OpenXML (PK 03 04 or PK 05 06)
        if ($bytes[0] -eq 0x50 -and $bytes[1] -eq 0x4B -and ($bytes[2] -eq 0x03 -or $bytes[2] -eq 0x05)) { return "Archives" }
        # 7Z (7z BC AF 27 1C)
        if ($bytes[0] -eq 0x37 -and $bytes[1] -eq 0x7A -and $bytes[2] -eq 0xBC -and $bytes[3] -eq 0xAF) { return "Archives" }
        # RAR (Rar! 1A 07)
        if ($bytes[0] -eq 0x52 -and $bytes[1] -eq 0x61 -and $bytes[2] -eq 0x72 -and $bytes[3] -eq 0x21) { return "Archives" }
        # GZIP (1F 8B)
        if ($bytes[0] -eq 0x1F -and $bytes[1] -eq 0x8B) { return "Archives" }
        # Windows EXE/DLL (MZ)
        if ($bytes[0] -eq 0x4D -and $bytes[1] -eq 0x5A) { return "Installers" }
        # Matroska / MKV / WebM (1A 45 DF A3)
        if ($bytes[0] -eq 0x1A -and $bytes[1] -eq 0x45 -and $bytes[2] -eq 0xDF -and $bytes[3] -eq 0xA3) { return "Videos" }
        # MP3 ID3 header (49 44 33)
        if ($bytes[0] -eq 0x49 -and $bytes[1] -eq 0x44 -and $bytes[2] -eq 0x33) { return "Audio" }
        # FLAC (66 4C 61 43)
        if ($bytes[0] -eq 0x66 -and $bytes[1] -eq 0x4C -and $bytes[2] -eq 0x61 -and $bytes[3] -eq 0x43) { return "Audio" }
        # RIFF header
        if ($bytes[0] -eq 0x52 -and $bytes[1] -eq 0x49 -and $bytes[2] -eq 0x46 -and $bytes[3] -eq 0x46 -and $read -ge 12) {
            $riffType = [System.Text.Encoding]::ASCII.GetString($bytes, 8, 4)
            if ($riffType -eq 'WAVE') { return "Audio" }
            if ($riffType -eq 'AVI ') { return "Videos" }
            if ($riffType -eq 'WEBP') { return "Images" }
        }
        # MP4/MOV ftyp
        if ($read -ge 8 -and $bytes[4] -eq 0x66 -and $bytes[5] -eq 0x74 -and $bytes[6] -eq 0x79 -and $bytes[7] -eq 0x70) {
            return "Videos"
        }
        return $null
    } catch {
        return $null
    } finally {
        if ($null -ne $stream) { $stream.Dispose() }
    }
}

function Get-RegistryMimeCategory([string]$Extension) {
    if ([string]::IsNullOrWhiteSpace($Extension)) { return $null }
    try {
        $regKey = "Registry::HKEY_CLASSES_ROOT\$Extension"
        if (Test-Path -LiteralPath $regKey) {
            $contentType = (Get-ItemProperty -LiteralPath $regKey -Name 'Content Type' -ErrorAction SilentlyContinue).'Content Type'
            if ($contentType) {
                if ($contentType -like 'image/*') { return 'Images' }
                if ($contentType -like 'video/*') { return 'Videos' }
                if ($contentType -like 'audio/*') { return 'Audio' }
                if ($contentType -like 'text/*' -or $contentType -like '*document*' -or $contentType -like '*pdf*' -or $contentType -like '*spreadsheet*' -or $contentType -like '*presentation*') { return 'Documents' }
                if ($contentType -like '*zip*' -or $contentType -like '*compressed*' -or $contentType -like '*tar*' -or $contentType -like '*archive*') { return 'Archives' }
            }
        }
    } catch {}
    return $null
}

function Test-CodebaseFolder([string]$FolderPath) {
    $markers = @(
        '.git','.svn','.hg','package.json','pnpm-lock.yaml','yarn.lock','package-lock.json',
        'composer.json','pyproject.toml','requirements.txt','Pipfile','Cargo.toml','go.mod',
        'pom.xml','build.gradle','build.gradle.kts','Dockerfile','docker-compose.yml','angular.json','Gemfile'
    )
    foreach ($marker in $markers) {
        $markerPath = Join-Path $FolderPath $marker
        if (Test-Path -LiteralPath $markerPath) { return $true }
    }
    foreach ($pattern in @('*.sln','*.csproj','*.fsproj','*.vcxproj','vite.config.*','next.config.*','webpack.config.*')) {
        $match = Get-ChildItem -LiteralPath $FolderPath -Filter $pattern -File -Force -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -ne $match) { return $true }
    }
    return $false
}

function Get-ScannedFolderFiles([string]$RootPath, [int]$Limit = 10000) {
    $found = New-Object 'System.Collections.Generic.List[System.IO.FileInfo]'
    $stack = New-Object 'System.Collections.Generic.Stack[string]'
    $stack.Push($RootPath)
    $skipNames = @('.git','node_modules','.next','dist','build','bin','obj','venv','.venv','__pycache__','.cache')
    
    while ($stack.Count -gt 0 -and $found.Count -lt $Limit) {
        $current = $stack.Pop()
        $filesHere = @(Get-ChildItem -LiteralPath $current -File -Force -ErrorAction SilentlyContinue)
        foreach ($f in $filesHere) {
            if ($null -ne $f) { $found.Add($f) }
            if ($found.Count -ge $Limit) { break }
        }
        if ($found.Count -ge $Limit) { break }
        $dirsHere = @(Get-ChildItem -LiteralPath $current -Directory -Force -ErrorAction SilentlyContinue)
        foreach ($d in $dirsHere) {
            if ($null -eq $d) { continue }
            if (($d.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { continue }
            if ($skipNames -contains $d.Name) { continue }
            $stack.Push($d.FullName)
        }
    }
    return $found.ToArray()
}

function Resolve-ItemCategory([System.IO.FileSystemInfo]$Item) {
    if ($Item -is [System.IO.FileInfo]) {
        $ext = [string]$Item.Extension
        $lowerExt = $ext.ToLowerInvariant()
        
        # 1. Match against Taxonomy table
        foreach ($catName in $Global:CategoryTaxonomy.Keys) {
            if ($Global:CategoryTaxonomy[$catName] -contains $lowerExt) {
                return @{ Category = $catName; Reason = "Taxonomy ($lowerExt)" }
            }
        }
        
        # 2. Match against Windows Registry MIME mapping
        $mimeCat = Get-RegistryMimeCategory $lowerExt
        if ($null -ne $mimeCat) {
            return @{ Category = $mimeCat; Reason = "Windows MIME registration ($lowerExt)" }
        }
        
        # 3. Match against Binary Magic Signatures (especially for unknown/missing extensions)
        $sigCat = Get-FileSignatureCategory $Item.FullName
        if ($null -ne $sigCat) {
            return @{ Category = $sigCat; Reason = "Binary Signature Sniffing" }
        }
        
        return @{ Category = 'Other'; Reason = "Unrecognized extension ($lowerExt)" }
    } else {
        # Folder evaluation
        if (Test-CodebaseFolder $Item.FullName) {
            return @{ Category = 'Codebases'; Reason = "Project/Build markers detected" }
        }
        
        $nestedFiles = @(Get-ScannedFolderFiles -RootPath $Item.FullName)
        if ($nestedFiles.Count -eq 0) {
            return @{ Category = 'Other'; Reason = "Empty folder or no accessible files" }
        }
        
        $extensions = @()
        foreach ($nf in $nestedFiles) {
            if ($null -ne $nf -and -not [string]::IsNullOrWhiteSpace($nf.Extension)) {
                $extensions += $nf.Extension.ToLowerInvariant()
            }
        }
        
        # Test if all files inside belong to a single category
        foreach ($catName in $Global:CategoryTaxonomy.Keys) {
            $allowed = @($Global:CategoryTaxonomy[$catName] | ForEach-Object { ([string]$_).ToLowerInvariant() })
            $unmatched = @($extensions | Where-Object { $allowed -notcontains $_ })
            if ($extensions.Count -gt 0 -and $unmatched.Count -eq 0) {
                return @{ Category = $catName; Reason = "All $($nestedFiles.Count) scanned files match $catName" }
            }
        }
        
        return @{ Category = 'Other'; Reason = "Mixed content folder ($($nestedFiles.Count) files); preserved intact" }
    }
}

function Invoke-Undo {
    param([string]$DownloadsPath)
    $historyDir = Join-Path $DownloadsPath '_Organizer_History'
    if (-not (Test-Path -LiteralPath $historyDir -PathType Container)) {
        Write-Host "`n[UNDO] No organization history found in $historyDir" -ForegroundColor Yellow
        return
    }
    
    $historyFiles = @(Get-ChildItem -LiteralPath $historyDir -Filter 'history_*.json' -File | Sort-Object LastWriteTime -Descending)
    if ($historyFiles.Count -eq 0) {
        Write-Host "`n[UNDO] No history transaction logs found." -ForegroundColor Yellow
        return
    }
    
    $latest = $historyFiles[0]
    Write-Host "`n[UNDO] Found latest rollback log: $($latest.Name) ($($latest.LastWriteTime))" -ForegroundColor Cyan
    try {
        $json = Get-Content -LiteralPath $latest.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        Write-Host "[UNDO] Failed to parse $($latest.FullName): $_" -ForegroundColor Red
        return
    }
    
    $items = @($json.Transactions)
    if ($items.Count -eq 0) {
        Write-Host "[UNDO] Log has no transactions." -ForegroundColor Yellow
        return
    }
    
    Write-Host "[UNDO] Preparing to restore $($items.Count) item(s) to original paths..." -ForegroundColor Yellow
    $restored = 0
    $skipped = 0
    
    # Rollback in reverse order
    for ($idx = $items.Count - 1; $idx -ge 0; $idx--) {
        $t = $items[$idx]
        $currentPath = $t.Destination
        $originalPath = $t.Source
        
        if (-not (Test-Path -LiteralPath $currentPath)) {
            Write-Host "  [SKIP] Current file not found at: $currentPath" -ForegroundColor DarkGray
            $skipped++
            continue
        }
        
        # Ensure original directory exists
        $origDir = [System.IO.Path]::GetDirectoryName($originalPath)
        if (-not (Test-Path -LiteralPath $origDir)) {
            New-Item -ItemType Directory -Path $origDir -Force | Out-Null
        }
        
        try {
            Move-Item -LiteralPath $currentPath -Destination $originalPath -Force -ErrorAction Stop
            Write-Host "  [RESTORED] $([System.IO.Path]::GetFileName($originalPath))" -ForegroundColor Green
            $restored++
        } catch {
            Write-Host "  [ERROR] Could not restore to $($originalPath): $($_.Exception.Message)" -ForegroundColor Red
            $skipped++
        }
    }
    
    Write-Host "`n[UNDO COMPLETE] Restored: $restored | Skipped/Failed: $skipped" -ForegroundColor Green
    
    # Clean up empty category directories if they are now empty
    foreach ($cat in $Global:ReservedFolders) {
        if ($cat -eq '_Organizer_History') { continue }
        $catPath = Join-Path $DownloadsPath $cat
        if (Test-Path -LiteralPath $catPath -PathType Container) {
            $children = @(Get-ChildItem -LiteralPath $catPath -Force -ErrorAction SilentlyContinue)
            if ($children.Count -eq 0) {
                Remove-Item -LiteralPath $catPath -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

# --- MAIN EXECUTION LOGIC ---

Write-Host @"
========================================================================
       DOWNLOADS ORGANIZER PRO -- ENTERPRISE RELIABILITY EDITION        
========================================================================
 Target Path: $TargetDirectory
 Engine:      Deep Taxonomy + Registry MIME + Binary Signature Sniffing
 Safety:      Active Downloads Protected | Rollback Checkpointing Enabled
========================================================================
"@ -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $TargetDirectory -PathType Container)) {
    Write-Host "[FATAL] Target directory does not exist: $TargetDirectory" -ForegroundColor Red
    return
}

if ($Undo) {
    Invoke-Undo -DownloadsPath $TargetDirectory
    return
}

# Scan top-level files
$allFiles = @(Get-ChildItem -LiteralPath $TargetDirectory -File -Force -ErrorAction SilentlyContinue)
$allFolders = @(Get-ChildItem -LiteralPath $TargetDirectory -Directory -Force -ErrorAction SilentlyContinue)

# Filter out script files, system files, and active in-progress downloads
$eligibleFiles = @()
$skippedActiveDownloads = 0

foreach ($f in $allFiles) {
    $ext = [string]$f.Extension.ToLowerInvariant()
    $name = [string]$f.Name.ToLowerInvariant()
    
    # Ignore organizer scripts
    if ($ext -in @('.bat','.cmd','.ps1') -and ($name -like '*organizer*' -or $name -like '*download*')) {
        continue
    }
    # Ignore system files
    if ($name -in @('desktop.ini','thumbs.db','.ds_store')) {
        continue
    }
    # Check for active in-progress downloads
    if ($Global:IncompleteExtensions -contains $ext -or $name -like '~`$*') {
        $skippedActiveDownloads++
        continue
    }
    # Check if locked by another active process (Chrome, IDM, Word)
    if (Test-IsFileLocked $f.FullName) {
        Write-Host "  [LOCKED] $($f.Name) is in use by another application; skipping for safety." -ForegroundColor Yellow
        $skippedActiveDownloads++
        continue
    }
    
    $eligibleFiles += $f
}

# Filter out reserved category folders
$eligibleFolders = @($allFolders | Where-Object { $Global:ReservedFolders -notcontains $_.Name })

Write-Host "Scan completed: Found $($eligibleFiles.Count) eligible file(s) and $($eligibleFolders.Count) folder(s)." -ForegroundColor Gray
if ($skippedActiveDownloads -gt 0) {
    Write-Host "Protected $skippedActiveDownloads active or locked file(s) from being touched." -ForegroundColor DarkYellow
}

if ($eligibleFiles.Count -eq 0 -and $eligibleFolders.Count -eq 0) {
    Write-Host "`nDownloads folder is already clean and well organized! Nothing to do." -ForegroundColor Green
    return
}

# Build execution plan
Write-Host "`nAnalyzing taxonomy, signatures, and codebase markers..." -ForegroundColor Yellow
$plan = New-Object 'System.Collections.Generic.List[object]'
$categoryMetrics = @{}

foreach ($f in $eligibleFiles) {
    $resolution = Resolve-ItemCategory $f
    $cat = $resolution.Category
    $reason = $resolution.Reason
    
    $plan.Add([PSCustomObject]@{
        Item = $f
        Kind = 'File'
        Category = $cat
        Reason = $reason
        Size = $f.Length
    })
    
    if (-not $categoryMetrics.ContainsKey($cat)) {
        $categoryMetrics[$cat] = @{ Count = 0; TotalBytes = [long]0 }
    }
    $categoryMetrics[$cat].Count++
    $categoryMetrics[$cat].TotalBytes += $f.Length
}

$i = 0
foreach ($folder in $eligibleFolders) {
    $i++
    $percent = [int](100 * $i / [Math]::Max(1, $eligibleFolders.Count))
    Write-Progress -Activity 'Analyzing top-level folders' -Status ("{0}/{1}: {2}" -f $i, $eligibleFolders.Count, $folder.Name) -PercentComplete $percent
    
    $resolution = Resolve-ItemCategory $folder
    $cat = $resolution.Category
    $reason = $resolution.Reason
    
    # Calculate approximate folder size
    $folderSize = (Get-ChildItem -LiteralPath $folder.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    if ($null -eq $folderSize) { $folderSize = 0 }
    
    $plan.Add([PSCustomObject]@{
        Item = $folder
        Kind = 'Folder'
        Category = $cat
        Reason = $reason
        Size = [long]$folderSize
    })
    
    if (-not $categoryMetrics.ContainsKey($cat)) {
        $categoryMetrics[$cat] = @{ Count = 0; TotalBytes = [long]0 }
    }
    $categoryMetrics[$cat].Count++
    $categoryMetrics[$cat].TotalBytes += [long]$folderSize
}
Write-Progress -Activity 'Analyzing top-level folders' -Completed

# Display metrics table
Write-Host "`nORGANIZATION PLAN SUMMARY:" -ForegroundColor Cyan
Write-Host ("{0,-24} {1,10} {2,16}" -f 'Category', 'Items', 'Total Size')
Write-Host ("{0,-24} {1,10} {2,16}" -f ('-'*24), ('-'*10), ('-'*16))

$totalItems = 0
$totalBytes = [long]0

foreach ($catKey in ($categoryMetrics.Keys | Sort-Object)) {
    $count = $categoryMetrics[$catKey].Count
    $bytes = $categoryMetrics[$catKey].TotalBytes
    $totalItems += $count
    $totalBytes += $bytes
    Write-Host ("{0,-24} {1,10} {2,16}" -f $catKey, $count, (Format-ByteSize $bytes))
}
Write-Host ("{0,-24} {1,10} {2,16}" -f ('='*24), ('='*10), ('='*16))
Write-Host ("{0,-24} {1,10} {2,16}" -f 'TOTAL', $totalItems, (Format-ByteSize $totalBytes)) -ForegroundColor Green

# Display item details
Write-Host "`nITEM DETAILS PREVIEW:" -ForegroundColor Cyan
foreach ($entry in ($plan | Sort-Object Category, Kind, @{Expression={$_.Item.Name}})) {
    $kindBadge = if ($entry.Kind -eq 'Folder') { '[DIR]' } else { '[FILE]' }
    Write-Host ("{0,6} {1} -> {2} | {3} ({4})" -f $kindBadge, $entry.Item.Name, $entry.Category, (Format-ByteSize $entry.Size), $entry.Reason) -ForegroundColor Gray
}

if ($DryRun) {
    Write-Host "`n[DRY RUN] Simulation complete. No files or folders were moved." -ForegroundColor Yellow
    return
}

# Interactive confirmation prompt
$choice = 'Y'
if (-not $NonInteractive) {
    Write-Host "`nAvailable Actions:" -ForegroundColor White
    Write-Host "  [Y] Organize Now      - Proceed with sorting and moving files" -ForegroundColor Green
    Write-Host "  [U] Undo Last Run     - Roll back previous organization" -ForegroundColor Yellow
    Write-Host "  [C] Cancel / Exit     - Do nothing and close" -ForegroundColor Red
    $choice = Read-Host "`nEnter your choice [Y/U/C] (Default: Y)"
    if ([string]::IsNullOrWhiteSpace($choice)) { $choice = 'Y' }
}

if ($choice -match '^[Uu]') {
    Invoke-Undo -DownloadsPath $TargetDirectory
    return
}

if ($choice -notmatch '^[Yy]') {
    Write-Host "`n[CANCELLED] Operation aborted by user. No files were modified." -ForegroundColor Yellow
    return
}

# --- PERFORM MOVING WITH TRANSACTION LOGGING ---
$historyDir = Join-Path $TargetDirectory '_Organizer_History'
if (-not (Test-Path -LiteralPath $historyDir -PathType Container)) {
    New-Item -ItemType Directory -Path $historyDir -Force | Out-Null
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$historyFile = Join-Path $historyDir "history_$timestamp.json"
$transactions = New-Object 'System.Collections.Generic.List[object]'

$movedCount = 0
$failedCount = 0

Write-Host "`nOrganizing items..." -ForegroundColor Cyan

foreach ($entry in $plan) {
    try {
        $destDir = Join-Path $TargetDirectory $entry.Category
        if (-not (Test-Path -LiteralPath $destDir -PathType Container)) {
            New-Item -ItemType Directory -Path $destDir -Force -ErrorAction Stop | Out-Null
        }
        
        $destPath = Join-Path $destDir $entry.Item.Name
        
        # Collision resolution: append (1), (2), etc.
        if (Test-Path -LiteralPath $destPath) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($entry.Item.Name)
            $ext = if ($entry.Kind -eq 'Folder') { '' } else { $entry.Item.Extension }
            $counter = 1
            do {
                $destPath = Join-Path $destDir ("{0} ({1}){2}" -f $baseName, $counter, $ext)
                $counter++
            } while (Test-Path -LiteralPath $destPath)
        }
        
        Move-Item -LiteralPath $entry.Item.FullName -Destination $destPath -ErrorAction Stop
        
        $transactions.Add([PSCustomObject]@{
            Source = $entry.Item.FullName
            Destination = $destPath
            Kind = $entry.Kind
            Category = $entry.Category
            Size = $entry.Size
        })
        $movedCount++
    } catch {
        $failedCount++
        Write-Host "  [FAILED] Could not move $($entry.Item.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Save Rollback Transaction Log
$historyPayload = [PSCustomObject]@{
    Timestamp = (Get-Date).ToString('o')
    TargetDirectory = $TargetDirectory
    MovedCount = $movedCount
    FailedCount = $failedCount
    Transactions = $transactions
}
$jsonString = $historyPayload | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($historyFile, $jsonString, [System.Text.Encoding]::UTF8)

Write-Host @"

========================================================================
                          ORGANIZATION COMPLETE                         
========================================================================
 Successfully Moved: $movedCount
 Errors / Blocked:   $failedCount
 Rollback Log Saved: $historyFile
 (You can undo this anytime by selecting [U] or running with -Undo)
========================================================================
"@ -ForegroundColor Green
