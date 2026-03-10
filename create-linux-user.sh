#!/usr/bin/env bash
set -e

# reconnect stdin to terminal
exec < /dev/tty

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
RESET="\e[0m"

step() { echo -e "${BLUE}==>${RESET} $1"; }
ok() { echo -e "${GREEN}✔${RESET} $1"; }
err() { echo -e "${RED}✖${RESET} $1"; }

if [[ $EUID -ne 0 ]]; then
    err "Run this script with sudo."
    exit 1
fi

if ! command -v pacman &>/dev/null; then
    err "This installer supports Arch-based systems only."
    exit 1
fi

echo
echo "--------------------------------"
echo " Linux User Installer"
echo "--------------------------------"
echo

read -rp "Enter username: " USERNAME

if id "$USERNAME" &>/dev/null; then
    err "User already exists."
    exit 1
fi

read -rsp "Enter password: " PASSWORD
echo
read -rsp "Confirm password: " PASSWORD_CONFIRM
echo

if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
    err "Passwords do not match."
    exit 1
fi

step "Installing packages..."
pacman -Sy --noconfirm sudo base-devel

step "Creating user..."
useradd -m -G wheel -s /bin/bash "$USERNAME"

echo "$USERNAME:$PASSWORD" | chpasswd

step "Enabling sudo..."

if ! grep -q "^%wheel ALL=(ALL:ALL) ALL" /etc/sudoers; then
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
fi

ok "User $USERNAME created with sudo access!"
