$sclib_dir = $env:temp + "\sclib"
$temp_dir = $env:temp + "\" + [GUID]::NewGuid().ToString("N") 

# make dirs
New-Item -ItemType Directory -Path $temp_dir -Force
if (-not (Test-Path $sclib_dir)) {
    mkdir $sclib_dir
}

# download
iwr https://github.com/xEm1rald/sclib/archive/refs/heads/main.zip -OutFile ($temp_dir + "/main.zip")

# unpack
Expand-Archive -Path ($temp_dir + "/main.zip") -DestinationPath $sclib_dir -Force

# clean
Remove-Item -Path $temp_dir -Recurse -Force

# update && run
cd ($sclib_dir + "/sclib-main")
python -m pip install -r requirements.txt
python __main__.py
