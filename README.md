# Lazy Arch Updater (LAU)

A minimal user-level systemd service and timer that automatically updates an Arch Linux system using `pacman` and `yay`.

---

## Overview

This script daily updates your system either if your using Arch Linux or an arch based distro will work the way its supposed to.
---

## Compatibility

Confirmed and likely compatibility based on standard notification daemons:

| Environment          | Status      | Notes                               |
|----------------------|-------------|-------------------------------------|
| DWM + dunst          | Confirmed   | Tested                              |
| Openbox + dunst      | Confirmed   | Tested                              |
| KDE Plasma           | Likely      | Unknown                             |
| GNOME                | Likely      | Gnome is garbage use something else |
| XFCE                 | Likely      | Unknown                             |
| Cinnamon             | Likely      | Unknown                             |
| i3 / Sway            | Likely      | Unknown                             |
| MATE                 | Untested    | Unknown                             |


---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/QuantumMapleQC/Lazy-Arch-Updater.git
cd Lazy-Arch-Updater
```
```bash
chmod +x LAU.sh
```

This script will:

    Detect your window manager or desktop environment

    Check for required dependencies (git, yay, or fallback)

    Clone or update the repository in ~/.local/share/lazy-arch-updater

    Run sudo pacman -Syu and yay -Syu automatically

    Log all update output to ~/.local/share/lazy-arch-updater/log.txt



