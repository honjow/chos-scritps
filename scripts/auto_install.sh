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

pacman -U /home/gamer/pkgs/python/*.zst --noconfirm --overwrite \*
#cd /home/gamer/git/HandyGCCS
#sudo -u gamer sed -i "s/handycon.CAPTURE_CONTROLLER = True/handycon.CAPTURE_CONTROLLER = False/" src/handycon/handhelds/ally_gen1.py
#sudo -u gamer sed -i "s/handycon.CAPTURE_KEYBOARD = True/handycon.CAPTURE_KEYBOARD = False/" src/handycon/handhelds/ally_gen1.py
#sudo ./build.sh

systemctl enable --now ayaled
systemctl restart ayaled
systemctl enable --now onedrive@gamer

systemctl disable --now home-swapfile.swap

systemctl restart plugin_loader.service
