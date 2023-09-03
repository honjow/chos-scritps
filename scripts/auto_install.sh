#!/bin/bash

# Check if the script is running with root or sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

DEVICENAME=$(cat /sys/devices/virtual/dmi/id/product_name)
VENDOR=$(cat /sys/devices/virtual/dmi/id/sys_vendor)

frzr-unlock

pacman -Sy

pacman -U /home/gamer/pkgs/*.zst --noconfirm --overwrite \* 2>/dev/null
#pacman -U /home/gamer/pkgs/gparted/*.zst --noconfirm --overwrite \*

pacman -U /home/gamer/pkgs/python/*.zst --noconfirm --overwrite \* 2>/dev/null


if [[ "$VENDOR" == "AYANEO" ]]; then
    systemctl enable --now ayaled
    systemctl restart ayaled
fi

home_swap_status=$(systemctl is-enabled home-swapfile.swap 2>/dev/null)
if [[ "$home_swap_status" == "enabled" ]]; then
    systemctl disable --now home-swapfile.swap
fi

decky_status=$(systemctl is-active plugin_loader.service 2>/dev/null)
if [[ "$decky_status" == "active" ]]; then
    systemctl restart plugin_loader.service
fi

./vim_config_update.sh

systemctl enable --now onedrive@gamer
