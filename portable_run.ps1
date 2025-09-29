# sclib-launcher.ps1
$ErrorActionPreference = "Stop"

# === Create Temp Directory ===
$tempDir = Join-Path $env:TEMP ("sclib_" + [guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $tempDir | Out-Null
Write-Host "Temp dir: $tempDir"

# === Define URLs ===
$pythonUrl = "https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip"
$sclibUrl  = "https://github.com/xEm1rald/sclib/archive/refs/heads/main.zip"

# === Download Files ===
$pythonZip = Join-Path $tempDir "python.zip"
$sclibZip  = Join-Path $tempDir "sclib.zip"

Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonZip
Invoke-WebRequest -Uri $sclibUrl -OutFile $sclibZip

# === Extract Archives ===
Expand-Archive -Path $pythonZip -DestinationPath $tempDir\python
Expand-Archive -Path $sclibZip -DestinationPath $tempDir\sclib

# === Paths ===
$pythonDir = Join-Path $tempDir "python"
$sclibDir  = Get-ChildItem -Path (Join-Path $tempDir "sclib") | Where-Object { $_.PsIsContainer } | Select-Object -First 1
$pythonExe = Join-Path $pythonDir "python.exe"
$mainFile  = Join-Path $sclibDir.FullName "__main__.py"

# === Run __main__.py ===
Write-Host "Running $mainFile"
& $pythonExe $mainFile

# === Cleanup ===
Remove-Item -Recurse -Force $tempDir
Write-Host "Cleanup done!"
