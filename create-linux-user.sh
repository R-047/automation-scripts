#!/usr/bin/env bash
set -e

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
RESET="\e[0m"

print_step() { echo -e "${BLUE}==>${RESET} $1"; }
print_success() { echo -e "${GREEN}✔${RESET} $1"; }
print_error() { echo -e "${RED}✖${RESET} $1"; }

if [[ $EUID -ne 0 ]]; then
    print_error "Run as root (sudo)."
    exit 1
fi

if ! command -v pacman &>/dev/null; then
    print_error "This script requires Arch Linux (pacman)."
    exit 1
fi

echo
echo "Linux User Setup Installer"
echo

read -rp "Enter new username: " USERNAME < /dev/tty

if id "$USERNAME" &>/dev/null; then
    print_error "User already exists."
    exit 1
fi

read -rsp "Enter password: " PASSWORD < /dev/tty
echo
read -rsp "Confirm password: " PASSWORD_CONFIRM < /dev/tty
echo

if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
    print_error "Passwords do not match."
    exit 1
fi

print_step "Installing packages..."
pacman -Sy --noconfirm sudo base-devel

print_step "Creating user..."
useradd -m -G wheel -s /bin/bash "$USERNAME"

echo "$USERNAME:$PASSWORD" | chpasswd

print_step "Enabling sudo..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

print_success "User $USERNAME created successfully!"
