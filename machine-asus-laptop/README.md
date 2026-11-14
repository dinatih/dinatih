# Machine ASUS Laptop (Google Drobit / ASUS Chromebook CX9) sous Omarchy

Notes de configuration et correctifs appliqués sur cette machine (**Google Drobit rev3**, **Omarchy 4.5.0**) ainsi que les points à surveiller lors des futures mises à jour d'Omarchy.

---

## 1. Lecteur d'empreinte (`cros_fp` via `rust-fp`)

### Contexte
Le lecteur d'empreinte de ce Chromebook (`/dev/cros_fp` sur bus SPI `google,cros-ec-spi`) n'est pas supporté par `libfprint` / `fprintd`, et le script `omarchy-hw-fingerprint` ne détecte que les lecteurs USB.

Il a donc été configuré avec **[ChocolateLoverRaj/rust-fp](https://github.com/ChocolateLoverRaj/rust-fp)** (compilé avec Rust 1.80.0 via `mise`) :
- Binaires : `/usr/local/bin/rust-fp`, `/usr/local/bin/rust-fp-dbus-interface`
- Module PAM : `/usr/lib/security/librust_fp_pam_module.so`
- Config D-Bus : `/usr/share/dbus-1/system.d/org.rust_fp.RustFp.conf`
- Service systemd : `/etc/systemd/system/rust-fp-dbus-interface.service` (activé au démarrage)
- PAM écran de verrouillage : `/etc/pam.d/omarchy-lock-fingerprint`
- Wrapper pour Omarchy Shell : `/usr/local/bin/fprintd-list` (simule la sortie attendue par `/usr/share/omarchy/shell/plugins/lock/Service.qml`)
- Empreintes enregistrées : `~/.var/cros-fp-templates` (`rust-fp add <nom>`, `rust-fp list`, `rust-fp clear`)

> **Important :** Ne pas ajouter `librust_fp_pam_module.so` dans `/etc/pam.d/sudo`. Sur des appels rapprochés, `crosec-rs` peut paniquer dans le thread D-Bus et bloquer `sudo` avant même l'affichage du prompt de mot de passe.

### Ce qu'une mise à jour d'Omarchy peut casser
Lors d'une mise à jour ou migration Omarchy qui exécute **`omarchy-apply-lock`** :
- `omarchy-apply-lock` teste explicitement `/usr/bin/fprintd-list` (et non `/usr/local/bin/fprintd-list`).
- Ne le trouvant pas, il **supprime `/etc/pam.d/omarchy-lock-fingerprint`**, ce qui désactive l'empreinte sur l'écran de verrouillage (`Super + Ctrl + L`).

#### Pour restaurer après une mise à jour
Recréez `/etc/pam.d/omarchy-lock-fingerprint` et redémarrez le shell Omarchy :
```bash
sudo tee /etc/pam.d/omarchy-lock-fingerprint >/dev/null <<'EOF'
#%PAM-1.0
auth       required                    librust_fp_pam_module.so
account    include                     system-local-login
EOF
omarchy-restart-shell
```

Si jamais le service D-Bus ne répond plus après une mise en veille ou un plantage :
```bash
sudo systemctl restart rust-fp-dbus-interface
```

---

## 2. Pavé numérique sur le trackpad (`ELAN2701:00 04F3:31C6`)

### Contexte
Par défaut, Omarchy active `numlock_by_default = true` dans `/usr/share/omarchy/default/hypr/input.lua`, ce qui active le mode NumberPad sur le trackpad ELAN. De plus, le trackpad expose un périphérique clavier virtuel (`elan2701:00-04f3:31c6-keyboard`) qui envoie des chiffres lors de touches accidentelles.

### Correctif appliqué
Dans `~/.config/hypr/input.lua` :
```lua
hl.config({
  input = {
    -- Disable NumLock by default so the ASUS NumberPad on the trackpad doesn't activate automatically.
    numlock_by_default = false,
  },
})

-- Disable the ELAN touchpad's virtual NumberPad keyboard device so accidental touches don't type numbers.
hl.device({ name = "elan2701:00-04f3:31c6-keyboard", enabled = false })
```

### Ce qu'une mise à jour d'Omarchy peut casser
- Les mises à jour classiques d'Omarchy ne touchent pas à `~/.config/hypr/input.lua`.
- En revanche, exécuter **`omarchy refresh hyprland`** réinitialise les fichiers dans `~/.config/hypr/` (en créant une sauvegarde) et réactivera `numlock_by_default = true` ainsi que `elan2701:00-04f3:31c6-keyboard`.

#### Pour restaurer après un `omarchy refresh hyprland`
Remettez le bloc ci-dessus dans `~/.config/hypr/input.lua`, puis rechargez Hyprland :
```bash
hyprctl reload
```
