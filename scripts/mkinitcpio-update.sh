#!/bin/bash

if [ $EUID -ne 0 ]; then
	echo "$(basename $0) must be run as root"
	exit 1
fi

frzr-unlock

curr_boot=$(grep -o "title [^[:space:]]*" "/boot/loader/entries/frzr.conf"|sed "s/title //")

cp /boot/${curr_boot}/* /boot

mkinitcpio -p chimeraos 

cp -a /boot/*.img /boot/${curr_boot}/
