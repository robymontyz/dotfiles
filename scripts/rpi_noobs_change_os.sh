#!/bin/bash
## rpi_noobs_change_os
## Change default booting OS in a Raspberry Pi with NOOBS
## Copyright (C) 2018 robymontyz
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
## Usage: rpi_noobs_change_os.sh -l|<partition>

# check number of arguments
if [[ $# -ne 1 ]]; then
	echo "Error. Usage: rpi_noobs_change_os.sh -l|<partition>" >&2
	exit 1
fi

mkdir -p ~/tmp/noobs &&\
	sudo mount /dev/mmcblk0p5 ~/tmp/noobs

if [[ $1 == "-l" ]]; then
	echo "List of available partition"
	cat ~/tmp/noobs/installed_os.json
	#sudo umount ~/tmp/noobs
	exit 0
elif [[ $1 =~ ^[0-9]* ]]; then
	sed -r -i -e "s/(default_partition_to_boot=)[0-9]+/\1$1/" ~/tmp/noobs/noobs.conf &&\
	#sudo umount ~/tmp/noobs &&\
	shutdown -r now
else
	echo "Error in the argument." >&2
	exit 1
fi

