# Dotfiles

Configuration files for my Omarchy (Arch Linux + Hyprland) setup.

## Structure

```
dotfiles/
├── bash/          # ~/.bashrc
├── hypr/          # ~/.config/hypr/bindings.conf
├── packages.txt   # Explicitly installed packages (pacman/yay)
```

## Setup on a new machine

### 1. Install packages

```bash
yay -S --needed - < dotfiles/packages.txt
```

### 2. Link config files

```bash
# Bash
ln -sf ~/Projects/dinatih/dotfiles/bash/.bashrc ~/.bashrc

# Hyprland bindings
ln -sf ~/Projects/dinatih/dotfiles/hypr/.config/hypr/bindings.conf ~/.config/hypr/bindings.conf
```

## Updating packages.txt

After installing new packages, regenerate the list:

```bash
pacman -Qqe > dotfiles/packages.txt
```
