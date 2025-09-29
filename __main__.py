import subprocess
import sys
import ensurepip
import os

def ensure_pip():
    try:
        import pip  # noqa
    except ImportError:
        print("pip not found, bootstrapping with ensurepip...")
        ensurepip.bootstrap()
        subprocess.check_call([sys.executable, "-m", "pip", "install", "--upgrade", "pip"])


def install_requirements():
    pkgs = ["streamlit", "mutagen", "beautifulsoup4"]
    subprocess.check_call([sys.executable, "-m", "pip", "install", "--upgrade"] + pkgs)


if __name__ == "__main__":
    ensure_pip()
    install_requirements()

    app_path = os.path.join("app", "main.py")
    subprocess.run([sys.executable, "-m", "streamlit", "run", app_path])
