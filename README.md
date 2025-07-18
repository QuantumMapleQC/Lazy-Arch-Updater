# Lazy Arch Updater

A minimal user-level systemd service and timer that automatically updates an Arch Linux system using `pacman` and `yay`, with desktop notifications on success or failure.

## Overview

This script automates daily system updates for both official and AUR packages and sends desktop notifications at the start and end of the process. It is designed to work on setups that support standard desktop notifications through `notify-send`.

## Compatibility

Confirmed and likely compatibility based on standard notification daemons:

| Environment          | Status      | Notes                                 |
|----------------------|-------------|---------------------------------------|
| DWM + dunst          | Confirmed   | Tested                                |
| Openbox + dunst      | Confirmed   | Tested                                |
| KDE Plasma           | Likely      | Uses built-in notification support    |
| GNOME                | Likely      | Uses native notification system       |
| XFCE                 | Likely      | Requires `xfce4-notifyd`              |
| Cinnamon             | Likely      | Default daemon supports notifications |
| i3 / Sway            | Likely      | Requires something like `dunst`       |
| MATE                 | Untested    | Should work if notification daemon present |

> You’ll need a working notification daemon such as `dunst`, `xfce4-notifyd`, or your DE’s built-in one.

## Installation

### 1. Clone the repository

```bash
https://github.com/QuantumMapleQC/Lazy-Arch-Updater.git
cd arch-auto-update-notifier
