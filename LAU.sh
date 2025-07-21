#!/bin/bash

# Lazy Arch Updater - LAU.sh
# Enhanced with WM/DE detection, error handling, systemd support, and combined logging/output.

# Constants
LAU_DIR="$HOME/Lazy-Arch-Updater"
LOG_FILE="$LAU_DIR/log.txt"
REPO_URL="https://github.com/QuantumMapleQC/Lazy-Arch-Updater.git"

# Globals
WM_DE="Unknown"

pause() { read -rp "Press Enter to continue..."; }

ascii_header() {
cat << "EOF"
╭───────────────────────────────╮
│       Lazy Arch Updater       │
╰───────────────────────────────╯
EOF
}

detect_wm_de() {
  if [[ $XDG_CURRENT_DESKTOP ]]; then
    WM_DE=$XDG_CURRENT_DESKTOP
  elif [[ $DESKTOP_SESSION ]]; then
    WM_DE=$DESKTOP_SESSION
  else
    for w in i3 sway dwm; do
      if pgrep -x "$w" > /dev/null 2>&1; then
        WM_DE=$w
        break
      fi
    done
  fi
}

ask_install() {
  local pkg="$1"
  echo -e "\e[33m[WARNING]\e[0m Required package '$pkg' is missing."
  read -rp "Would you like to install '$pkg' now? [Y/n]: " yn
  case "$yn" in
    [Yy]*|"")
      sudo pacman -S --noconfirm "$pkg"
      if [[ $? -ne 0 ]]; then
        echo -e "\e[31m[ERROR]\e[0m Failed to install '$pkg'. Please install it manually."
        pause
        exit 1
      fi
      ;;
    *)
      echo "Cannot continue without '$pkg'. Exiting."
      pause
      exit 1
      ;;
  esac
}

system_check() {
  echo "Checking system compatibility and dependencies..."

  if [[ ! -f /etc/arch-release ]]; then
    echo -e "\e[31m[ERROR]\e[0m This script is only intended for Arch Linux."
    pause
    exit 1
  fi

  echo "Detected Window Manager / Desktop Environment: $WM_DE"

  # Required dependencies
  local needed=(sudo systemctl)
  local missing_pkgs=()

  for cmd in "${needed[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing_pkgs+=("$cmd")
    fi
  done

  if ! command -v git >/dev/null 2>&1; then
    missing_pkgs+=("git")
  fi

  if ! command -v yay >/dev/null 2>&1; then
    missing_pkgs+=("yay")
  fi

  if ((${#missing_pkgs[@]} > 0)); then
    echo -e "\nSome required packages are missing:"
    for pkg in "${missing_pkgs[@]}"; do
      echo " - $pkg"
    done

    for pkg in "${missing_pkgs[@]}"; do
      ask_install "$pkg"
    done
  else
    echo "System check passed. All dependencies found."
  fi
}

run_update() {
  local mode="$1"
  mkdir -p "$LAU_DIR"

  echo "[*] Cloning or updating repo at $LAU_DIR ..."
  if [[ -d "$LAU_DIR/.git" ]]; then
    if git -C "$LAU_DIR" pull --quiet; then
      echo "Repo updated successfully."
    else
      echo -e "\e[31m[ERROR]\e[0m Failed to update repo. Please check your network or repo status."
      [[ "$mode" != "--systemd" ]] && pause
      return
    fi
  else
    if git clone --quiet "$REPO_URL" "$LAU_DIR"; then
      echo "Repo cloned successfully."
    else
      echo -e "\e[31m[ERROR]\e[0m Failed to clone repo. Please check your network or repo URL."
      [[ "$mode" != "--systemd" ]] && pause
      return
    fi
  fi

  cd "$LAU_DIR" || { echo "[ERROR] Failed to cd into $LAU_DIR"; [[ "$mode" != "--systemd" ]] && pause; return; }

  echo "[*] Running system update... Logs are saved in $LOG_FILE"

  {
    echo "===== Update run at $(date) ====="
    echo "[*] Running sudo pacman -Syu ..."
    sudo pacman -Syu --noconfirm

    echo "[*] Running yay -Syu ..."
    yay -Syu --noconfirm

    # Check and run paru update if installed
    if command -v paru >/dev/null 2>&1; then
      echo "[*] Running paru -Syu ..."
      paru -Syu --noconfirm
    else
      echo "[*] paru not found; skipping paru update."
    fi

    # Check and run flatpak update if installed
    if command -v flatpak >/dev/null 2>&1; then
      echo "[*] Running flatpak update ..."
      flatpak update -y
    else
      echo "[*] flatpak not found; skipping flatpak update."
    fi

    echo "===== Update completed ====="
    echo
  } 2>&1 | tee -a "$LOG_FILE"

  if [[ ${PIPESTATUS[0]} -eq 0 && ${PIPESTATUS[1]} -eq 0 ]]; then
    echo "[SUCCESS] Update finished without errors."
    [[ "$mode" == "--systemd" ]] && echo "System updated automatically."
  else
    echo -e "\e[31m[ERROR]\e[0m Update finished with errors. Check logs."
  fi

  [[ "$mode" != "--systemd" ]] && pause
}

view_log() {
  if [[ -f "$LOG_FILE" ]]; then
    echo "[INFO] Loading log file: $LOG_FILE"
    pause
    less "$LOG_FILE"
  else
    echo "[!] No log file found at $LOG_FILE."
    pause
  fi
}

manual_instructions() {
  clear
  ascii_header
  cat <<EOF

Lazy Arch Updater (LAU) is a lightweight bash-based tool designed to help Arch Linux
users keep their system up to date.

Detected environment: $WM_DE

Features:
- Auto clones/updates its repo.
- Runs 'sudo pacman -Syu' and 'yay -Syu' with logging.
- Supports paru and flatpak updates if installed.
- Supports various window managers and desktop environments.
- Simple arrow-key navigated terminal interface.
- Installable systemd user timer for auto updates every 3 to 5 hours.

Make sure required dependencies are installed before use.

EOF
  pause
}

install_systemd_units() {
  SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
  mkdir -p "$SYSTEMD_USER_DIR"

  echo "Cleaning up any existing Lazy Arch Updater timers..."

  # Stop and disable any existing timer (old or new)
  systemctl --user disable --now arch-auto-update.timer 2>/dev/null || true

  # Reload systemd user daemon to pick up changes
  systemctl --user daemon-reload

  echo "Installing systemd user units..."

  cat > "$SYSTEMD_USER_DIR/arch-auto-update.service" << EOF
[Unit]
Description=Lazy Arch Updater Service

[Service]
Type=simple
ExecStart=/bin/bash $HOME/Lazy-Arch-Updater/LAU.sh --run-update
EOF

  cat > "$SYSTEMD_USER_DIR/arch-auto-update.timer" << EOF
[Unit]
Description=Run Lazy Arch Updater every 3 to 5 hours

[Timer]
OnBootSec=5min
OnUnitActiveSec=3h
RandomizedDelaySec=2h
Persistent=true

[Install]
WantedBy=timers.target
EOF

  systemctl --user daemon-reload
  systemctl --user enable --now arch-auto-update.timer
  systemctl --user status arch-auto-update.timer --no-pager

  if ! systemctl --user show-environment >/dev/null 2>&1; then
    echo -e "\e[33m[WARNING]\e[0m systemd user instance does not appear to be running."
    echo "Timers may not work until you log out and back in or reboot."
  fi

  echo "Systemd timer installed and started."
  echo "This timer will run automatically every 3 to 5 hours and persist across reboots."
  pause
}

# Call detect_wm_de ONCE at script start
detect_wm_de

# Run update directly if called by systemd timer
if [[ "$1" == "--run-update" ]]; then
  run_update --systemd
  exit 0
fi

# Menu options
options=(
  "Run update now"
  "Show update logs"
  "Manual instructions"
  "Install systemd timer for auto updates"
  "Exit"
)

selected=0

draw_menu() {
  clear
  ascii_header
  echo
  echo "Detected WM/DE: $WM_DE"
  echo "Use arrow keys to navigate, Enter to select."
  echo
  for i in "${!options[@]}"; do
    if [[ $i -eq $selected ]]; then
      echo -e " > \e[1;32m${options[$i]}\e[0m"
    else
      echo "   ${options[$i]}"
    fi
  done
}

read_key() {
  read -rsn1 key
  if [[ $key == $'\x1b' ]]; then
    read -rsn2 -t 0.1 key
  fi
  echo "$key"
}

main_menu() {
  system_check
  while true; do
    draw_menu
    key=$(read_key)
    case "$key" in
      '[A') ((selected--));;
      '[B') ((selected++));;
      '') # enter
        case $selected in
          0) run_update;;
          1) view_log;;
          2) manual_instructions;;
          3) install_systemd_units;;
          4) clear; echo "Goodbye!"; exit 0;;
        esac
        ;;
    esac
    (( selected < 0 )) && selected=0
    (( selected >= ${#options[@]} )) && selected=$((${#options[@]} - 1))
  done
}

# MAIN
main_menu
