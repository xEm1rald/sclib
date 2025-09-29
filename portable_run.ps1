# Download Python 3.13.7 installer
$pythonUrl = "https://www.python.org/ftp/python/3.13.7/python-3.13.7-amd64.exe"
$installerPath = "$env:TEMP\python-3.13.7-amd64.exe"
Invoke-WebRequest -Uri $pythonUrl -OutFile $installerPath

# Run the installer silently with default settings and add Python to PATH
Start-Process -FilePath $installerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

# Delete the installer file
Remove-Item -Path $installerPath -Force

# Create temporary directory "sclib_tmp" in system's TEMP directory
$tempDir = Join-Path $env:TEMP "sclib_tmp"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Set working directory to temp
Set-Location $tempDir

# Download the ZIP file
$zipUrl = "https://github.com/xEm1rald/sclib/archive/refs/heads/main.zip"
$zipPath = Join-Path $tempDir "sclib-main.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

# Unzip the archive
Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

# Change to the extracted directory
Set-Location "$tempDir\sclib-main"

# Install dependencies from requirements.txt
pip install -r requirements.txt

# Run the main script
py __main__.py

# Optional: Cleanup (uncomment if you want to delete the temp dir after execution)
# Set-Location $PSScriptRoot
# Remove-Item $tempDir -Recurse -Force
