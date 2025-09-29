# === sclib portable runner with Python installer in temp folder ===

# Create temp directory
$tempDir = Join-Path $env:TEMP "sclib_temp"
$pythonDir = Join-Path $tempDir "Python"
New-Item -ItemType Directory -Path $pythonDir -Force | Out-Null
Write-Host "Created temp directory: $tempDir"

# Download full Python installer
$pythonInstaller = Join-Path $tempDir "python-312-installer.exe"
$pythonUrl = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe"
Write-Host "Downloading Python installer..."
Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller -ErrorAction Stop

# Silent install Python to temp folder
Write-Host "Installing Python to $pythonDir ..."
$installArgs = "/quiet InstallAllUsers=0 PrependPath=0 TargetDir=$pythonDir"
Start-Process -FilePath $pythonInstaller -ArgumentList $installArgs -Wait -NoNewWindow

# Set Python and pip paths
$pythonPath = Join-Path $pythonDir "python.exe"
$pipPath = Join-Path $pythonDir "Scripts\pip.exe"

# Verify installation
if (-not (Test-Path $pythonPath)) {
    Write-Host "Python installation failed."
    Remove-Item -Path $tempDir -Recurse -Force
    exit 1
}

Write-Host "Python installed at: $pythonPath"

# Upgrade pip
Write-Host "Upgrading pip..."
& $pythonPath -m pip install --upgrade pip

# Download and unzip sclib
$zipFile = Join-Path $tempDir "sclib-main.zip"
$sclibUrl = "https://github.com/xEm1rald/sclib/archive/refs/heads/main.zip"
Write-Host "Downloading sclib..."
Invoke-WebRequest -Uri $sclibUrl -OutFile $zipFile -ErrorAction Stop
Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
$sclibDir = Join-Path $tempDir "sclib-main"
Write-Host "sclib extracted to: $sclibDir"

# Install requirements
$requirementsPath = Join-Path $sclibDir "requirements.txt"
if (Test-Path $requirementsPath) {
    Write-Host "Installing Python requirements..."
    & $pythonPath -m pip install -r $requirementsPath
}

# Run sclib
$mainScript = Join-Path $sclibDir "__main__.py"
if (Test-Path $mainScript) {
    Write-Host "Running sclib..."
    Start-Process -FilePath $pythonPath -ArgumentList $mainScript -Wait
} else {
    Write-Host "Main script not found: $mainScript"
}

# Clean up everything
Write-Host "Cleaning up temp folder..."
Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Done!"
