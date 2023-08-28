#!/bin/bash

AUTO_INSTALL=1

# Check if the script is running with root or sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

echo $(ls /boot/)
echo $(ls /frzr_root/deployments)

echo "start frzr-unlock"

frzr-unlock
sleep 5


echo $(ls /boot/)
echo $(ls /frzr_root/deployments)

# swap uuid
swap_dev=$(awk '$2 == "partition" && $1 ~ "^/dev/" {print $1}' /proc/swaps)
if [[ -n "$swap_dev" ]]; then
  SWAP_PARTUUID=$(lsblk -no PARTUUID -f "$swap_dev")
fi

echo "SWAP_PARTUUID=$SWAP_PARTUUID"
RESUME_CMD=""
if [[ -n "${SWAP_PARTUUID}" ]]; then
    RESUME_CMD="resume=PARTUUID=${SWAP_PARTUUID}"
else
    exit 0
fi

# 检查 /boot/loader/entries/frzr.conf 文件是否存在
if [ -f "/boot/loader/entries/frzr.conf" ]; then
    curr_sys=$(grep -o "title [^[:space:]]*" "/boot/loader/entries/frzr.conf"|sed "s/title //")

    # 检查文件中是否已存在 resume=，如果不存在，则在最后一行添加
    if ! grep -q "resume=" "/boot/loader/entries/frzr.conf"; then
        #echo "${RESUME_CMD}" >> "/boot/loader/entries/frzr.conf"
	sed -i "s/ splash / splash ${RESUME_CMD} /" "/boot/loader/entries/frzr.conf"
        echo "Added RESUME_CMD to frzr.conf"

	sed -i "s/ quiet / /" "/boot/loader/entries/frzr.conf"
	#sed -i "s/ amd_pstate=active / /" "/boot/loader/entries/frzr.conf"
	
	/home/gamer/scripts/add-mkinitcpio-hook.sh resume
	/home/gamer/scripts/mkinitcpio-update.sh

    if [[ "x$AUTO_INSTALL" == "x1" ]]; then
        /home/gamer/scripts/auto_install.sh
    fi
    else
        # 获取已存在的 resume= 行的内容
        existing_resume=$(grep -o "resume=[^[:space:]]*" "/boot/loader/entries/frzr.conf")
	echo "existing resume: ${existing_resume}"
        
        # 如果现有的 resume= 行与 RESUME_CMD 不匹配，则进行替换
        if [ "${existing_resume}" != "${RESUME_CMD}" ]; then
            sed -i "s/${existing_resume}/${RESUME_CMD}/" "/boot/loader/entries/frzr.conf"
            echo "Replaced existing RESUME_CMD in frzr.conf"
            
            /home/gamer/scripts/add-mkinitcpio-hook.sh resume
	        /home/gamer/scripts/mkinitcpio-update.sh
        else
            echo "RESUME_CMD already present and matches in frzr.conf"
        fi
    fi

else
    echo "frzr.conf not found"
fi
