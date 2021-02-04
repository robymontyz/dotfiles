#!/bin/bash
## print_lscolors
## Prints set `ls` colors for each type of file/folder for macOS Terminal.app
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
## Usage: print_lscolors.sh

# error if not under macOS
if [[ $(uname -s) != "Darwin" ]]; then
	echo "OS not supported. MacOS only." >&2
	exit 1
fi

# File/Folder types
declare -a types=(
                  "directory"
                  "symbolic link"
                  "socket"
                  "pipe"
                  "executable"
                  "block special"
                  "character special"
                  "executable with setuid bit set"
                  "executable with setgid bit set"
                  "directory writable to others, with sticky bit"
                  "directory writable to others, without sticky bit"
                 )
# -------------------------
# |     ANSI Colors       |
# -------------------------
# Default
Reset='\033[0m'         # Color off (default)
# Foreground
Black='\033[30m'        # Black
Red='\033[31m'          # Red
Green='\033[32m'        # Green
Brown='\033[33m'        # Brown
Blue='\033[34m'         # Blue
Magenta='\033[35m'      # Magenta
Cyan='\033[36m'         # Cyan
Grey='\033[37m'         # White
# Background
On_Black='\033[40m'     # Black
On_Red='\033[41m'       # Red
On_Green='\033[42m'     # Green
On_Brown='\033[43m'     # Brown
On_Blue='\033[44m'      # Blue
On_Magenta='\033[45m'   # Magenta
On_Cyan='\033[46m'      # Cyan
On_Grey='\033[47m'      # White
# High Intensity foreground (bright)
IBlack='\033[90m'       # Black
IRed='\033[91m'         # Red
IGreen='\033[92m'       # Green
IBrown='\033[93m'       # Brown
IBlue='\033[94m'        # Blue
IMagenta='\033[95m'     # Magenta
ICyan='\033[96m'        # Cyan
IGrey='\033[97m'        # White
# High Intensity background (bright)
On_IBlack='\033[100m'   # Black
On_IRed='\033[101m'     # Red
On_IGreen='\033[102m'   # Green
On_IBrown='\033[103m'   # Brown
On_IBlue='\033[104m'    # Blue
On_IMagenta='\033[105m' # Magenta
On_ICyan='\033[106m'    # Cyan
On_IGrey='\033[107m'    # White

# Translate from $LSCOLORS letters to ANSI escape codes for colors
function translate {
	if [[ "$1" == "f" ]]; then
		case "$2" in
			a)
				echo $Black
				;;
			b)
				echo $Red
				;;
			c)
				echo $Green
				;;
			d)
				echo $Brown
				;;
			e)
				echo $Blue
				;;
			f)
				echo $Magenta
				;;
			g)
				echo $Cyan
				;;
			h)
				echo $Grey
				;;
			A)
				echo $IBlack
				;;
			B)
				echo $IRed
				;;
			C)
				echo $IGreen
				;;
			D)
				echo $IBrown
				;;
			E)
				echo $IBlue
				;;
			F)
				echo $IMagenta
				;;
			G)
				echo $ICyan
				;;
			H)
				echo $IGrey
				;;
			x)
				echo ""
				;;
		esac
	elif [[ "$1" == "b" ]]; then
		case "$2" in
			a)
				echo $On_Black
				;;
			b)
				echo $On_Red
				;;
			c)
				echo $On_Green
				;;
			d)
				echo $On_Brown
				;;
			e)
				echo $On_Blue
				;;
			f)
				echo $On_Magenta
				;;
			g)
				echo $On_Cyan
				;;
			h)
				echo $On_Grey
				;;
			A)
				echo $On_IBlack
				;;
			B)
				echo $On_IRed
				;;
			C)
				echo $On_IGreen
				;;
			D)
				echo $On_IBrown
				;;
			E)
				echo $On_IBlue
				;;
			F)
				echo $On_IMagenta
				;;
			G)
				echo $On_ICyan
				;;
			H)
				echo $On_IGrey
				;;
			x)
				echo ""
				;;
		esac
	fi
}

# check if you are using personalized or default colors
# (personalized if LSCOLORS is set)
if [[ "$LSCOLORS" != "" ]]; then
	colorstring="$LSCOLORS"
else
	# default colors (check man ls)
	colorstring="exfxcxdxbxegedabagacad"
fi

let i=0
for t in "${types[@]}"; do
	fore="$(translate f ${colorstring:$i:1})"
	back="$(translate b ${colorstring:$i+1:1})"

	echo -e "${fore}${back}$t${Reset}"

	let i=$i+2
done

