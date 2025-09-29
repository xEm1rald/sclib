# === Portable sclib runner ===

# Create temp folder
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
$installArgs = "/quiet InstallAllUsers=0 PrependPath=0 TargetDir=$pythonDir Include_pip=1"
Start-Process -FilePath $pythonInstaller -ArgumentList $installArgs -Wait -NoNewWindow

# Set Python and pip paths
$pythonPath = Join-Path $pythonDir "python.exe"
$pipPath = Join-Path $pythonDir "Scripts\pip.exe"

# Verify Python installation
if (-not (Test-Path $pythonPath)) {
    Write-Host "Python installation failed."
    Remove-Item -Path $tempDir -Recurse -Force
    exit 1
}
Write-Host "Python installed at: $pythonPath"

# Upgrade pip
Write-Host "Upgrading pip..."
& $pythonPath -m pip install --upgrade pip

# Download sclib project
$zipFile = Join-Path $tempDir "sclib-main.zip"
$sclibUrl = "https://github.com/xEm1rald/sclib/archive/refs/heads/main.zip"
Write-Host "Downloading sclib project..."
Invoke-WebRequest -Uri $sclibUrl -OutFile $zipFile -ErrorAction Stop
Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
$sclibDir = Join-Path $tempDir "sclib-main"
Write-Host "sclib extracted to: $sclibDir"

# Install Python requirements
$requirementsPath = Join-Path $sclibDir "requirements.txt"
if (Test-Path $requirementsPath) {
    Write-Host "Installing Python requirements..."
    & $pythonPath -m pip install -r $requirementsPath
}

# Run sclib __main__.py
$mainScript = Join-Path $sclibDir "__main__.py"
if (Test-Path $mainScript) {
    Write-Host "Running sclib..."
    Start-Process -FilePath $pythonPath -ArgumentList $mainScript -Wait
} else {
    Write-Host "Main script not found: $mainScript"
}

# Clean up temp folder
Write-Host "Cleaning up temp folder..."
Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

# Self-delete
if ($PSCommandPath) {
    Write-Host "Deleting self..."
    Remove-Item -Path $PSCommandPath -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "Script run via iex; cannot delete self."
}

Write-Host "Done!"
