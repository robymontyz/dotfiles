#!/bin/bash
## check_open_ports
## Check well-known ports (0-1023) for unauthorized access
## If find something suspicious, send a mail
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
## Usage: check_open_port.sh

MYIP="$(ifconfig | grep -w "inet" | grep -v 127.0.0.1 | cut -f 2 -d " ")"

netstat -anv | grep ESTABLISHED | tr -s " " | cut -d " " -f 4,5 | \
while read line; do
	port="$(echo "$line" | cut -d " " -f 1 | cut -d . -f 5)"
	ip="$(echo "$line" | cut -d " " -f 2 | cut -d . -f 1,2,3,4)"
	#debug: echo "$ip at port:$port"
	if [[ $port -ge 0 ]] && [[ $port -le 1023 ]]; then
		if [[ "$ip" = "$MYIP" ]]; then
			# there is an intruder
			echo "$ip has access to your machine using port $port"
			# send a mail
			echo "$ip has access to your machine using port $port" | mail -s "INTRUSION" $USER
		fi
	fi
done 

