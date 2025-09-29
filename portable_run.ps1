# Ensure temp directory
$tempDir = Join-Path $env:TEMP "sclib_temp"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Write-Host "Created temp directory: $tempDir"

# Download Python 3.12 installer
$pythonInstaller = Join-Path $tempDir "python-installer.exe"
try {
    Write-Host "Downloading Python 3.12..."
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe" -OutFile $pythonInstaller -ErrorAction Stop
} catch {
    Write-Host "Error downloading Python: $_"
    exit 1
}

# Install Python to temp directory
Write-Host "Installing Python to $tempDir\Python..."
$installArgs = "/quiet InstallAllUsers=0 PrependPath=0 TargetDir=$tempDir\Python"
Start-Process -FilePath $pythonInstaller -ArgumentList $installArgs -Wait -NoNewWindow

# Verify Python installation
$pythonPath = Join-Path $tempDir "Python\python.exe"
if (-not (Test-Path $pythonPath)) {
    Write-Host "Python installation failed: $pythonPath not found."
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}
Write-Host "Python installed at: $pythonPath"

# Set pip path
$pipPath = Join-Path $tempDir "Python\Scripts\pip.exe"

# Download and unzip sclib
$zipFile = Join-Path $tempDir "sclib-main.zip"
try {
    Write-Host "Downloading sclib..."
    Invoke-WebRequest -Uri "https://github.com/xEm1rald/sclib/archive/refs/heads/main.zip" -OutFile $zipFile -ErrorAction Stop
    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
} catch {
    Write-Host "Error downloading/unzipping sclib: $_"
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}
$sclibDir = Join-Path $tempDir "sclib-main"
Write-Host "sclib extracted to: $sclibDir"

# Install pip and upgrade
Write-Host "Installing pip..."
& $pythonPath -m ensurepip --upgrade
if (-not (Test-Path $pipPath)) {
    Write-Host "Pip installation failed: $pipPath not found."
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}
& $pythonPath -m pip install --upgrade pip
Write-Host "Pip upgraded."

# Install requirements
$requirementsPath = Join-Path $sclibDir "requirements.txt"
if (Test-Path $requirementsPath) {
    Write-Host "Installing requirements from $requirementsPath..."
    & $pipPath install -r $requirementsPath
} else {
    Write-Host "Requirements file not found: $requirementsPath"
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

# Run main.py
$mainScript = Join-Path $sclibDir "__main__.py"
if (Test-Path $mainScript) {
    Write-Host "Running $mainScript..."
    Start-Process -FilePath $pythonPath -ArgumentList $mainScript -Wait -NoNewWindow
} else {
    Write-Host "Main script not found: $mainScript"
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

# Clean up
Write-Host "Cleaning up..."
Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

# Self-delete (handle iex case)
if ($PSCommandPath) {
    Write-Host "Deleting script: $PSCommandPath"
    Remove-Item -Path $PSCommandPath -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "Script running via iex, no file to delete."
}
