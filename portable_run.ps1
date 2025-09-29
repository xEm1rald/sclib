# === Portable sclib runner (Python embeddable + pip) ===

$tempDir = Join-Path $env:TEMP "sclib_temp"
$pythonDir = Join-Path $tempDir "Python"
New-Item -ItemType Directory -Path $pythonDir -Force | Out-Null
Write-Host "Created temp directory: $tempDir"

# Download Python embeddable
$pythonZip = Join-Path $tempDir "python-312-embed-amd64.zip"
$pythonUrl = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
Write-Host "Downloading Python embeddable..."
Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonZip -ErrorAction Stop
Expand-Archive -Path $pythonZip -DestinationPath $pythonDir -Force

$pythonPath = Join-Path $pythonDir "python.exe"
$pipPath = Join-Path $pythonDir "Scripts\pip.exe"

# Download get-pip.py
$getPip = Join-Path $tempDir "get-pip.py"
Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile $getPip -ErrorAction Stop

# Install pip
Write-Host "Installing pip..."
& $pythonPath $getPip

# Upgrade pip
& $pythonPath -m pip install --upgrade pip

# Download sclib
$zipFile = Join-Path $tempDir "sclib-main.zip"
$sclibUrl = "https://github.com/xEm1rald/sclib/archive/refs/heads/main.zip"
Write-Host "Downloading sclib project..."
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

# Cleanup
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
