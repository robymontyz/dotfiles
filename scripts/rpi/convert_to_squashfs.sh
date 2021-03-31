#!/bin/bash -e
## Convert To SquashFS
## Converts OS images to SquashFS format, to use with Berryboot in RPi
## Copyright (C) 2021 robymontyz
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.
##
##
## Usage: convert_to_squashfs.sh <img_name>

# check number of arguments
if [[ $# -ne 1 ]]; then
  echo "Error. Usage: convert_to_squashfs.sh <img_name>"
else
  IMG=$1
fi

sudo kpartx -av "${IMG}"
sudo mount /dev/mapper/loop0p2 /mnt
sudo sed -i 's/^\/dev\/mmcblk/#\0/g' /mnt/etc/fstab
sudo sed -i 's/^PARTUUID/#\0/g' /mnt/etc/fstab
sudo rm -f /mnt/etc/console-setup/cached_UTF-8_del.kmap.gz
sudo rm -f /mnt/etc/systemd/system/multi-user.target.wants/apply_noobs_os_config.service
sudo rm -f /mnt/etc/systemd/system/multi-user.target.wants/raspberrypi-net-mods.service
sudo rm -f /mnt/etc/rc3.d/S01resize2fs_once
sudo mksquashfs /mnt converted_"${IMG}" -comp lzo -e lib/modules
sudo umount /mnt
sudo kpartx -d "${IMG}"

