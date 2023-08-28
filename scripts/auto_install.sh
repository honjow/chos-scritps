#!/bin/bash

# Check if the script is running with root or sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

set -e

frzr-unlock

pacman -Sy

pacman -U /home/gamer/pkgs/*.zst --noconfirm --overwrite \*
pacman -U /home/gamer/pkgs/gparted/*.zst --noconfirm --overwrite \*

systemctl enable --now ayaled
systemctl restart ayaled
systemctl enable --now onedrive@gamer

systemctl disable --now home-swapfile.swap

systemctl restart plugin_loader.service
