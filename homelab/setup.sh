#!/usr/bin/env bash
# Run on mini PC (Omarchy/Arch) to bootstrap homelab
set -euo pipefail

STACKS_DIR="$HOME/stacks"

# ── SSH key (run from laptop first) ──────────────────────────────────────────
# ssh-copy-id user@<mini-pc-local-ip>

# ── Tailscale ─────────────────────────────────────────────────────────────────
echo ">>> Installing Tailscale..."
yay -S --noconfirm tailscale
sudo systemctl enable --now tailscaled
sudo tailscale up
# Note: opens browser for auth. On headless: tailscale up --auth-key=<key>

# ── Docker ────────────────────────────────────────────────────────────────────
echo ">>> Installing Docker..."
sudo pacman -S --noconfirm docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
echo "Docker installed. Re-login or run: newgrp docker"

# ── Samba (NAS) ───────────────────────────────────────────────────────────────
echo ">>> Installing Samba..."
sudo pacman -S --noconfirm samba

sudo mkdir -p /srv/nas
sudo chmod 777 /srv/nas

sudo tee /etc/samba/smb.conf > /dev/null <<'EOF'
[global]
   workgroup = WORKGROUP
   server string = Homelab NAS
   server role = standalone server
   log file = /var/log/samba/%m.log
   max log size = 50

[shared]
   path = /srv/nas
   browseable = yes
   writable = yes
   create mask = 0644
   directory mask = 0755
   valid users = %S
EOF

sudo systemctl enable --now smb nmb
echo "Samba running. Add user: sudo smbpasswd -a \$USER"

# ── Deploy stacks ─────────────────────────────────────────────────────────────
echo ">>> Setting up stacks directory..."
mkdir -p "$STACKS_DIR"
# rsync from laptop: rsync -av homelab/stacks/ user@mini-pc:~/stacks/

# ── Zigbee device check ───────────────────────────────────────────────────────
echo ""
echo ">>> Zigbee dongle detection:"
echo "Plug in dongle then check: ls /dev/tty{USB,ACM}*"
echo "Update stacks/homeautomation/compose.yml device path if not /dev/ttyUSB0"

echo ""
echo "=== Setup complete ==="
echo "Next:"
echo "  1. rsync -av homelab/stacks/ user@\$(tailscale ip -4):~/stacks/"
echo "  2. ssh mini-pc 'docker compose -f ~/stacks/homeautomation/compose.yml up -d'"
echo "  3. ssh mini-pc 'docker compose -f ~/stacks/webapp/compose.yml up -d'"
echo "  4. Home Assistant: http://\$(tailscale ip -4):8123"
