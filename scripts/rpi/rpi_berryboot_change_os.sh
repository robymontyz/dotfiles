#!/bin/bash
## rpi_berryboot_change_os
## Change default booting OS in a Raspberry Pi with Berryboot
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
## Usage: rpi_berryboot_change_os.sh -l|<image_name>

# check number of arguments
if [[ $# -ne 1 ]]; then
	echo "Error. Usage: rpi_berryboot_change_os.sh -l|<image_name>" >&2
	exit 1
fi

sudo mount /dev/mmcblk0p2 /mnt
cd /mnt/images
shopt -s nullglob
array=(*.img*)
shopt -u nullglob # Turn off nullglob to make sure it doesn't interfere with anything later

if [[ "${1}" == "-l" ]]; then
	echo "List of available images"
	printf "%s\n" "${array[@]}"  # Note double-quotes to avoid extra parsing of funny characters in filenames
	#sudo umount /mnt/*
	exit 0
else
	for img in "${array[@]}"
	do
		shopt -s nocasematch
		if [[ "${img}" == *"${1}"* ]]; then
			echo "OS choosed:"
			echo -n "${img}" | sudo tee /mnt/data/default
			echo
			echo "Restart to change OS."
			exit 0
		fi
	done
	echo "No images found using \'$1\'".
	#sudo umount /mnt/* &&\
	#shutdown -r now
fi

