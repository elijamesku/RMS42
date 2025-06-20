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
