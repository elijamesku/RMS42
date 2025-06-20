$filePath = "C:\Program Files\RMS3\RMSLauncher.exe"
if (Test-Path $filePath) {
    Write-Host "RMSLauncher.exe found."
    exit 0
} else {
    Write-Host "RMSLauncher.exe not found."
    exit 1
}
