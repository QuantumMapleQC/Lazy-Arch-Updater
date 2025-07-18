# Lazy Arch Updater (LAU)

A minimal user-level systemd service and timer that automatically updates an Arch Linux system using `pacman` and `yay`, with desktop notifications on success or failure.

---

## Overview

This script automates daily system updates for both official and AUR packages and sends desktop notifications at the start and end of the process. It is designed to work on setups that support standard desktop notifications through `notify-send`.

---

## Compatibility

Confirmed and likely compatibility based on standard notification daemons:

| Environment          | Status      | Notes                                 |
|----------------------|-------------|-------------------------------------|
| DWM + dunst          | Confirmed   | Tested                              |
| Openbox + dunst      | Confirmed   | Tested                              |
| KDE Plasma           | Likely      | Uses built-in notification support  |
| GNOME                | Likely      | Uses native notification system     |
| XFCE                 | Likely      | Requires `xfce4-notifyd`             |
| Cinnamon             | Likely      | Default daemon supports notifications |
| i3 / Sway            | Likely      | Requires something like `dunst`     |
| MATE                 | Untested    | Should work if notification daemon present |

> You’ll need a working notification daemon such as `dunst`, `xfce4-notifyd`, or your DE’s built-in one.

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

    Check for required dependencies (git, yay, sudo, notify-send or fallback)

    Clone or update the repository in ~/.local/share/lazy-arch-updater

    Run sudo pacman -Syu and yay -Syu automatically

    Log all update output to ~/.local/share/lazy-arch-updater/log.txt

    Send desktop notifications on success or failure


