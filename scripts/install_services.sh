#!/bin/bash

# Check if the script is running with root or sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

cp ./system/* /etc/systemd/system/

systemctl enable resume.service
systemctl enable update_boot_config.service
