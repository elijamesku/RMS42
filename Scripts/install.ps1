$ZipPath = "$PSScriptRoot\RMSLauncher42Ktr.zip"
$ExtractPath = "$env:TEMP\RMS42Install"

# Extract the ZIP
Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

# Run the installer
$ExePath = Join-Path $ExtractPath "RMSLauncher42Ktr.exe"

if (Test-Path $ExePath) {
    Write-Output "Installer found. Launching..."
    Start-Process -FilePath $ExePath -ArgumentList "/VERYSILENT /MERGETASKS=!desktopicon /DIR=`"C:\Program Files\RMS3`"" -Wait -NoNewWindow
} else {
    Write-Output "Installer not found at $ExePath"
}
