#!/usr/bin/env bash

set -e

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

print_step() {
    echo -e "${BLUE}==>${RESET} $1"
}

print_success() {
    echo -e "${GREEN}✔${RESET} $1"
}

print_error() {
    echo -e "${RED}✖${RESET} $1"
}

print_warn() {
    echo -e "${YELLOW}!${RESET} $1"
}

# Root check
if [[ $EUID -ne 0 ]]; then
    print_error "This installer must be run as root."
    echo "Run with: sudo bash"
    exit 1
fi

# Detect Arch Linux
if ! command -v pacman &>/dev/null; then
    print_error "This script only supports Arch-based systems (pacman required)."
    exit 1
fi

echo
echo "--------------------------------------"
echo " Linux User Setup Installer"
echo "--------------------------------------"
echo

# Ask for username
while true; do
    read -rp "Enter new username: " USERNAME
    
    if [[ -z "$USERNAME" ]]; then
        print_warn "Username cannot be empty."
        continue
    fi
    
    if id "$USERNAME" &>/dev/null; then
        print_error "User already exists."
        exit 1
    fi
    
    break
done

# Password input
while true; do
    read -rsp "Enter password: " PASSWORD
    echo
    read -rsp "Confirm password: " PASSWORD_CONFIRM
    echo
    
    if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
        print_warn "Passwords do not match. Try again."
    else
        break
    fi
done

print_step "Updating package database..."
pacman -Sy --noconfirm

print_step "Installing required packages..."
pacman -S --noconfirm sudo base-devel

print_success "Packages installed"

print_step "Creating user $USERNAME..."
useradd -m -G wheel -s /bin/bash "$USERNAME"

echo "$USERNAME:$PASSWORD" | chpasswd

print_success "User created"

print_step "Configuring sudo access..."

if ! grep -q "^%wheel ALL=(ALL:ALL) ALL" /etc/sudoers; then
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
fi

print_success "Sudo enabled for wheel group"

echo
print_success "Installation complete!"
echo
echo "User: $USERNAME"
echo "Groups: wheel"
echo
echo "You can now login using:"
echo "su - $USERNAME"
echo
