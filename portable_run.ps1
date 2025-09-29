# Create temporary directory
$tempDir = Join-Path $env:TEMP "sclib_temp"
New-Item -ItemType Directory -Path $tempDir -Force

# Download and install Python 3.12
$pythonInstaller = Join-Path $tempDir "python-installer.exe"
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe" -OutFile $pythonInstaller
Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet InstallAllUsers=0 PrependPath=0 TargetDir=$tempDir\Python" -Wait

# Set Python path
$pythonPath = Join-Path $tempDir "Python\python.exe"
$pipPath = Join-Path $tempDir "Python\Scripts\pip.exe"

# Download and unzip sclib
$zipFile = Join-Path $tempDir "sclib-main.zip"
Invoke-WebRequest -Uri "https://github.com/xEm1rald/sclib/archive/refs/heads/main.zip" -OutFile $zipFile
Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
$sclibDir = Join-Path $tempDir "sclib-main"

# Install pip
& $pythonPath -m ensurepip --upgrade
& $pythonPath -m pip install --upgrade pip

# Install requirements
$requirementsPath = Join-Path $sclibDir "requirements.txt"
& $pipPath install -r $requirementsPath

# Run main.py
$mainScript = Join-Path $sclibDir "__main__.py"
Start-Process -FilePath $pythonPath -ArgumentList $mainScript -Wait

# Clean up
Remove-Item -Path $tempDir -Recurse -Force
Remove-Item -Path $PSCommandPath -Force
