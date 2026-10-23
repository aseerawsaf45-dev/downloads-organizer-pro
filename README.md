# ⚡ Downloads Organizer Pro

[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![Shell: Batch & PowerShell](https://img.shields.io/badge/Shell-Hybrid%20Batch%20%2B%20PowerShell%205.1%2B-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Zero Dependencies](https://img.shields.io/badge/Dependencies-Zero%20(Native%20OS)-brightgreen)](#)
[![Safe Rollback](https://img.shields.io/badge/Safety-100%25%20Reversible%20Undo-blue)](#)

> **An industrial-grade, zero-dependency file organization and intelligence engine for Windows.**  
> Automatically detects, analyzes, and categorizes over **500+ file extensions** into clean, intuitive directories with binary magic-byte sniffing, active download protection, and one-click rollback.

---

## 🌟 Why Downloads Organizer Pro?

Most download organizer scripts are simple fragile `.bat` loops that choke on special characters, break project repositories, corrupt in-progress browser downloads, or overwrite duplicate filenames.

**Downloads Organizer Pro** was engineered with high reliability and zero-risk design:

- 🛡️ **Active Download Guard**: Automatically detects and ignores active downloads (`.crdownload`, `.part`, `.download`, `*.tmp`, `!qb`, `*.aria2`) and actively locked files.
- 🧬 **Tri-Tier Detection Engine**:
  1. **500+ File Taxonomy**: Instant classification across 12 standard categories.
  2. **Windows Registry MIME Integration**: Dynamically queries `HKEY_CLASSES_ROOT` for obscure or newly registered system file formats.
  3. **Binary Signature Sniffing**: Inspects initial magic bytes to identify extensionless or misnamed files (PNG, JPEG, GIF, PDF, ZIP, 7Z, RAR, GZ, EXE, MKV, MP3, FLAC, WAV, WebP, MP4).
- 📦 **Codebase & Git Project Intelligence**: Detects project root markers (`.git`, `package.json`, `Cargo.toml`, `go.mod`, `.sln`, `pom.xml`, etc.) and keeps software repositories whole inside `Codebases/` without breaking them.
- 🔄 **100% Non-Destructive with Rollback (Undo)**: Every movement is recorded in a timestamped transaction log. Hit `[U]` or run with `-Undo` to instantly restore every file and folder back to its exact original location.
- ⚡ **Zero Overwrites**: Duplicate files automatically resolve with safe numbering (`Document (1).pdf`, `Document (2).pdf`) without data loss.
- 🚀 **Zero Dependencies**: Native Windows Batch + PowerShell 5.1 (preinstalled on 100% of modern Windows machines). No Python, Node, or 3rd-party binaries required.

---

## 📂 Category Taxonomy (500+ Formats)

| Category | Typical Formats | Notes |
|:---|:---|:---|
| **📄 Documents** | `.pdf`, `.doc`, `.docx`, `.odt`, `.rtf`, `.txt`, `.md`, `.rst`, `.tex`, `.pages`, `.wps`, `.xlsx`, `.xls`, `.csv`, `.tsv`, `.ods`, `.parquet`, `.feather`, `.pptx`, `.ppt`, `.odp`, `.key` | Word processors, sheets, presentations, logs, and docs |
| **🖼️ Images** | `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.svg`, `.ico`, `.bmp`, `.tiff`, `.avif`, `.heic`, `.heif`, `.psd`, `.ai`, `.eps`, `.raw`, `.cr2`, `.cr3`, `.nef`, `.arw`, `.dng` | Web images, vector graphics, design projects, camera RAW |
| **🎬 Videos** | `.mp4`, `.mkv`, `.mov`, `.avi`, `.wmv`, `.webm`, `.m4v`, `.mpg`, `.mpeg`, `.m2ts`, `.mts`, `.ts`, `.vob`, `.3gp`, `.flv` | High-definition video, clips, and screen recordings |
| **🎵 Audio** | `.mp3`, `.wav`, `.flac`, `.m4a`, `.aac`, `.ogg`, `.opus`, `.wma`, `.alac`, `.aiff`, `.mid`, `.midi`, `.m3u`, `.pls` | Lossless audio, music tracks, voice notes, playlists |
| **📦 Archives** | `.zip`, `.rar`, `.7z`, `.tar`, `.gz`, `.bz2`, `.xz`, `.tgz`, `.tbz2`, `.cab`, `.zst`, `.wim`, `.arj` | Compressed archives and backups |
| **⚙️ Installers** | `.exe`, `.msi`, `.msix`, `.appx`, `.apk`, `.xapk`, `.aab`, `.dmg`, `.pkg`, `.appimage` | Application setup packages and installers |
| **💿 Disk Images** | `.iso`, `.img`, `.vhd`, `.vhdx`, `.vmdk`, `.vdi`, `.ova`, `.ovf`, `.qcow2`, `.bin`, `.cue` | OS installers and virtual machine images |
| **💻 Code** | `.html`, `.css`, `.js`, `.ts`, `.py`, `.java`, `.cpp`, `.c`, `.cs`, `.go`, `.rs`, `.php`, `.swift`, `.json`, `.yaml`, `.xml`, `.sql`, `.ipynb`, `.sh`, `.ps1` | Source code files, scripts, configurations, databases |
| **🛠️ Codebases** | Folders with `.git`, `package.json`, `pom.xml`, `Cargo.toml`, `go.mod`, `.sln`, etc. | Full development projects preserved intact |
| **🔤 Fonts** | `.ttf`, `.otf`, `.woff`, `.woff2`, `.eot`, `.fon`, `.ttc` | Desktop and web typography files |
| **📚 eBooks** | `.epub`, `.mobi`, `.azw`, `.azw3`, `.kfx`, `.cbr`, `.cbz`, `.djvu`, `.fb2` | Electronic publications and comic book archives |
| **📐 3D & CAD** | `.stl`, `.obj`, `.fbx`, `.blend`, `.step`, `.stp`, `.iges`, `.dwg`, `.dxf`, `.gltf`, `.glb` | 3D printing models, CAD drawings, Blender scenes |
| **🔗 Torrents & Links** | `.torrent`, `.url`, `.webloc`, `.desklink` | BitTorrent descriptors and internet shortcuts |
| **📁 Other** | Unclassified extensions, extensionless unknown files, mixed folders | Preserved safely without loss |

---

## 🚀 Quick Start

### Option 1: Standalone Batch File (Double-Click)
1. Download **`Downloads_Organizer_Pro.bat`**.
2. Double-click the file to run.
3. Review the categorized summary table showing file counts and byte sizes.
4. Type **`Y`** to organize, **`U`** to undo a previous run, or **`C`** to exit.

### Option 2: PowerShell Engine (CLI / Advanced)
Run directly from PowerShell:
```powershell
# Standard run (prompts for confirmation)
.\Downloads_Organizer_Engine.ps1

# Dry-run simulation (preview changes without moving anything)
.\Downloads_Organizer_Engine.ps1 -DryRun

# Automatic non-interactive run (ideal for scheduled tasks)
.\Downloads_Organizer_Engine.ps1 -NonInteractive

# Organize a custom folder
.\Downloads_Organizer_Engine.ps1 -TargetDirectory "D:\MyDownloads"

# Rollback / Undo the last organization session
.\Downloads_Organizer_Engine.ps1 -Undo
```

---

## 🛡️ Safety & Reliability Architecture

```
[Target Folder: Downloads]
            │
            ├───> [Active Download Filter] ────> (Skip .crdownload, .part, .tmp, locked files)
            │
            ├───> [Classification Engine]
            │          │
            │          ├── 1. 500+ Extension Taxonomy Table
            │          ├── 2. Windows Registry MIME Fallback (HKEY_CLASSES_ROOT)
            │          └── 3. Binary Magic-Byte Header Sniffer (PNG, PDF, ZIP, EXE, etc.)
            │
            ├───> [Directory Analyzer]
            │          │
            │          ├── Codebase Marker Check (.git, package.json, Cargo.toml) ──> Codebases/
            │          ├── Pure-Folder Check (e.g. 100% images) ─────────────────────> Images/
            │          └── Mixed Folder Check ───────────────────────────────────────> Other/
            │
            ├───> [Plan Generator & UI Table]
            │          └── Human-readable size format (KB / MB / GB)
            │
            └───> [Atomic Move & Transaction Logger]
                       ├── Zero Overwrite Collision Handler: file (1).ext
                       └── Rollback Log: _Organizer_History/history_<timestamp>.json
```

---

## ⏰ Automated Scheduling (Windows Task Scheduler)

To organize your Downloads folder automatically every day or upon startup:

1. Open **Task Scheduler** (`taskschd.msc`).
2. Click **Create Basic Task** -> Name: `Downloads Organizer Pro`.
3. Trigger: **Daily** (e.g., at `11:00 PM`) or **When I log on**.
4. Action: **Start a program**:
   - **Program/script**: `powershell.exe`
   - **Arguments**: `-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Path\To\Downloads_Organizer_Engine.ps1" -NonInteractive`
5. Click **Finish**. Your downloads will now automatically stay pristine and organized!

---

## 🧪 Verification & Testing

This project includes a comprehensive automated test suite ([`test_organizer.ps1`](test_organizer.ps1)) testing 18 independent invariants:
- Categorization across 12 standard groups.
- Magic byte detection on extensionless files.
- Codebase preservation without folder destruction.
- Safe omission of incomplete browser downloads.
- Non-destructive rollback verification restoring 100% of files to their original paths.

Run the test suite:
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\test_organizer.ps1
```

---

## 📄 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more details.
