#!/bin/bash
## Pwnage search
## Search for an hashed password in a huge sorted database (haveibeenpwned)
## Copyright (C) 2019 robymontyz
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
## Usage: pwnage_search.sh <psw>

# check number of arguments
if [[ $# -ne 1 ]]; then
  echo "Error. You should specify the password to look for."
	exit 1
fi

# Variables
line=551509767
psw_to_check=$(echo -n "$1" | shasum -a 1 | awk '{print $1}')
file=""

# password hash
hash=$(echo -n "${psw}" | shasum -a 1 | awk '{print $1}')"

while [ $line -ge 0 ]; do
	line=$(( $line / 2 ))
	IFS=:; read -a psw <<<"$(sed -n "${line}p" "${file}")"
	
	if [ "${psw[0]}" > "$psw_to_check" ]; then
		
	elif [ "${psw[0]}" < "$psw_to_check" ]; then
		
	elif [ "${psw[0]}" == "$psw_to_check" ]; then
		echo "FOUND! ${psw[0]} used ${psw[1]} times."
	fi
done

