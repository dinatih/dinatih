# Dotfiles

Configuration files for my Omarchy (Arch Linux + Hyprland) setup.

## Structure

```
dotfiles/
├── bash/          # ~/.bashrc
├── fingerprint/   # Framework 13 Goodix fingerprint monitor (udev + systemd)
├── hypr/          # ~/.config/hypr/bindings.conf
├── waybar/        # ~/.config/waybar/ (config + style)
├── webapps/       # ~/.local/share/applications/ (omarchy web apps + icons)
├── packages.txt   # Explicitly installed packages (pacman/yay)
```

## Setup on a new machine

### 1. Install packages

```bash
yay -S --needed - < dotfiles/packages.txt
```

### 2. Link config files

Symlinks are managed with [GNU Stow](https://www.gnu.org/software/stow/). From the dotfiles directory:

```bash
cd ~/Projects/dinatih/dotfiles
stow -t ~ bash
stow -t ~ hypr
stow -t ~ waybar
```

Or manually:

```bash
# Bash
ln -sf ~/Projects/dinatih/dotfiles/bash/.bashrc ~/.bashrc

# Hyprland bindings
ln -sf ~/Projects/dinatih/dotfiles/hypr/.config/hypr/bindings.conf ~/.config/hypr/bindings.conf

# Waybar
ln -sf ~/Projects/dinatih/dotfiles/waybar/.config/waybar/config.jsonc ~/.config/waybar/config.jsonc
ln -sf ~/Projects/dinatih/dotfiles/waybar/.config/waybar/style.css ~/.config/waybar/style.css

# Web apps
cp dotfiles/webapps/.local/share/applications/*.desktop ~/.local/share/applications/
cp dotfiles/webapps/.local/share/applications/icons/*.png ~/.local/share/applications/icons/

# Fingerprint monitor (Framework 13 Goodix)
sudo cp dotfiles/fingerprint/99-goodix-fingerprint.rules /etc/udev/rules.d/
sudo cp dotfiles/fingerprint/monitor_fingerprint.rb /usr/local/bin/ && sudo chmod +x /usr/local/bin/monitor_fingerprint.rb
sudo cp dotfiles/fingerprint/fingerprint-monitor.service /etc/systemd/system/
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo systemctl daemon-reload && sudo systemctl enable --now fingerprint-monitor.service
```

## Updating packages.txt

After installing new packages, regenerate the list:

```bash
pacman -Qqe > dotfiles/packages.txt
```
