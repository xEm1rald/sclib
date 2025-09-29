# Ensure temp directory
$tempDir = Join-Path $env:TEMP "sclib_temp"
$pythonDir = Join-Path $tempDir "Python"
New-Item -ItemType Directory -Path $pythonDir -Force | Out-Null
Write-Host "Created temp directory: $tempDir"

# Download Python embeddable zip
$pythonZip = Join-Path $tempDir "python-312-embed-amd64.zip"
$pythonUrl = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
Write-Host "Downloading Python embeddable..."
Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonZip -ErrorAction Stop

# Extract Python
Write-Host "Extracting Python..."
Expand-Archive -Path $pythonZip -DestinationPath $pythonDir -Force

# Set paths
$pythonPath = Join-Path $pythonDir "python.exe"
$pipPath = Join-Path $pythonDir "Scripts\pip.exe"

# Ensure pip exists (Python embedded requires ensurepip)
Write-Host "Installing pip..."
& $pythonPath -m ensurepip --upgrade

# Upgrade pip
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
    Start-Process -FilePath $pythonPath -ArgumentList $mainScript -Wait -NoNewWindow
} else {
    Write-Host "Main script not found: $mainScript"
}

# Clean up
Write-Host "Cleaning up..."
Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Done!"
