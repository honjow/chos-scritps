#!/bin/bash
DEVICENAME=$(cat /sys/devices/virtual/dmi/id/product_name)
VENDOR=$(cat /sys/devices/virtual/dmi/id/sys_vendor)

ayaled_status=$(systemctl is-enabled ayaled.service 2>/dev/null)
if [[ "$ayaled_status" == "enabled" ]]; then
    sudo systemctl restart ayaled.service
fi
