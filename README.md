# RMS42 Intune Deployment (System Context, Silent Install)

This documentation outlines a complete lifecycle deployment strategy for **RMSLauncher42Ktr** using PowerShell automation. The install process extracts a bundled ZIP archive, installs the EXE silently to `C:\Program Files\RMS3`, and cleans up accordingly. The uninstall script fully removes the app and associated data. Detection logic validates presence through the main executable.

```                                
       __        __   _                            _          _   _            ____  _____    _    ____  __  __ _____ 
       \ \      / /__| | ___ ___  _ __ ___   ___  | |_ ___   | |_| |__   ___  |  _ \| ____|  / \  |  _ \|  \/  | ____|
        \ \ /\ / / _ \ |/ __/ _ \| '_ ` _ \ / _ \ | __/ _ \  | __| '_ \ / _ \ | |_) |  _|   / _ \ | | | | |\/| |  _|  
         \ V  V /  __/ | (_| (_) | | | | | |  __/ | || (_) | | |_| | | |  __/ |  _ <| |___ / ___ \| |_| | |  | | |___ 
          \_/\_/ \___|_|\___\___/|_| |_| |_|\___|  \__\___/   \__|_| |_|\___| |_| \_\_____/_/   \_\____/|_|  |_|_____|
                                                                                                                                                                              
                                                                                                
```

## What Was Done (Summary)

- Created a ZIP-based deployment package for **RMSLauncher42Ktr**
- Extracted the ZIP to a temp folder and launched the EXE silently
- Installed under `C:\Program Files\RMS3` with no desktop shortcut
- Used `/VERYSILENT` to suppress UI and prompts
- Provided uninstall and detection logic for full Intune lifecycle support

---

## Folder Structure
```
RMSLauncher42Ktr/
├── RMSLauncher42Ktr.zip # ZIP archive with RMSLauncher42Ktr.exe
├── Install-RMS.ps1 # Extracts + installs EXE silently
├── Uninstall-RMS.ps1 # Deletes install and data directories
├── Detect-RMS.ps1 # Checks if RMSLauncher.exe exists
└── Output/ # Intune packaged output
```

## Installer Script (`Install-RMS.ps1`)

```powershell
$ZipPath = "$PSScriptRoot\RMSLauncher42Ktr.zip"
$ExtractPath = "$env:TEMP\RMS42Install"

# Extract the ZIP
Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

# Build path to EXE
$ExePath = Join-Path $ExtractPath "RMSLauncher42Ktr.exe"

if (Test-Path $ExePath) {
    Write-Output "Installer found. Launching..."
    Start-Process -FilePath $ExePath -ArgumentList "/VERYSILENT /MERGETASKS=!desktopicon /DIR=`"C:\Program Files\RMS3`"" -Wait -NoNewWindow
} else {
    Write-Output "Installer not found at $ExePath"
}
```

### Why This Works

- Expand-Archive extracts ZIP contents

- Start-Process runs the installer with full silent flags

- Installs to C:\Program Files\RMS3 — no desktop icon (MERGETASKS=!desktopicon)

- Waits for install to complete before continuing

- Works in System context, ideal for Intune

## Uninstaller Script (Uninstall-RMS.ps1)
```powershell

$installPath = "C:\Program Files\RMS3"
$dataPath = "C:\ProgramData\RMS3"

Write-Host "Attempting to remove: $installPath"
if (Test-Path $installPath) {
    Remove-Item -Path $installPath -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Attempting to remove: $dataPath"
if (Test-Path $dataPath) {
    Remove-Item -Path $dataPath -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Uninstall cleanup completed."
```
### What It Does
- Fully deletes install and data directories

- Silent and forceful removal

- No user confirmation prompts

## Detection Script (Detect-RMS.ps1)
```powershell

$filePath = "C:\Program Files\RMS3\RMSLauncher.exe"
if (Test-Path $filePath) {
    Write-Host "RMSLauncher.exe found."
    exit 0
} else {
    Write-Host "RMSLauncher.exe not found."
    exit 1
}
```
### Why This Works
- Verifies installation by checking for the main EXE

- Returns exit code 0 for success, 1 for failure — compatible with Intune detection logic

- Lightweight, fast, and avoids registry or MSI product codes

### Intune Packaging & Deployment
- Step 1: Package using IntuneWinAppUtil.exe

```bash
IntuneWinAppUtil.exe -c "C:\RMSLauncher42Ktr" -s "Install-RMS.ps1" -o "C:\RMSLauncher42Ktr\Output"
```
- Step 2: Upload to Intune as a new Win32 App
Configure as follows:
Install command:
```
powershell.exe -ExecutionPolicy Bypass -File .\Install-RMS.ps1
```

Uninstall command:
```
powershell.exe -ExecutionPolicy Bypass -File .\Uninstall-RMS.ps1
```

- Detection rule: Use a custom detection script

- Type: File

- Path: C:\Program Files\RMS3

- File: RMSLauncher.exe

- Install behavior: System

### Technical Design Rationale
- Silent deployment: Fully suppresses UI with /VERYSILENT

- Minimal system impact: No registry keys, no background services

- System context friendly: No need to elevate into user space

- Intune ready: Lifecycle management via install/uninstall/detect

- No bloat: Lightweight, portable design using only what’s needed

### End Result
- RMSLauncher42Ktr installs silently and reliably

- Fully removed via cleanup script

- Intune tracks deployment success via detection rule

- Admin-friendly automation and repeatability

```                                        
             |  _ \ _____      _____ _ __ ___  __| | | |__  _   _    ___ _   _ _ __(_) ___  ___(_) |_ _   _ 
             | |_) / _ \ \ /\ / / _ \ '__/ _ \/ _` | | '_ \| | | |  / __| | | | '__| |/ _ \/ __| | __| | | |
             |  __/ (_) \ V  V /  __/ | |  __/ (_| | | |_) | |_| | | (__| |_| | |  | | (_) \__ \ | |_| |_| |
             |_|   \___/_\_/\_/ \___|_|  \___|\__,_| |_.__/ \__, |  \___|\__,_|_|  |_|\___/|___/_|\__|\__, |
                   | ____| (_)                              |___/                                     |___/ 
              _____|  _| | | |                                                                              
             |_____| |___| | |                                                                              
                   |_____|_|_|                                                                              
                                                                                                
```
