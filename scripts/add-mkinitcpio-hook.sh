#!/bin/bash

if [ $EUID -ne 0 ]; then
	echo "$(basename $0) must be run as root"
	exit 1
fi

if [ $# -lt 1 ]; then
    echo "Usage: $0 <hook_name>"
    exit 1
fi

frzr-unlock

hook_name="$1"
config_file="/etc/mkinitcpio.conf"

if ! grep -q "^HOOKS=.*\<$hook_name\>" "$config_file"; then
    sed -i "s/fsck /fsck $hook_name /" "$config_file"
    echo "Added '$hook_name' to mkinitcpio hooks."
else
    echo "'$hook_name' already exists in mkinitcpio hooks. Skipping."
fi
