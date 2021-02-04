#!/bin/bash
## macOS Software Updater
## This program call some scripts to update Homebrew formulae and casks
## and Mac App Store (MAS) applications.
## Then sends a mail to the current user containing the results.
## Copyright (C) 2020 robymontyz
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
## Usage: software_updater.sh

out_tmp=$(mktemp)
err_tmp=$(mktemp)

~/.scripts/homebrew_update.sh 1>$out_tmp 2>$err_tmp
if [[ $? -ne 0 ]]; then
	mail -s "SUp: Homebrew-ERROR" $(whoami) <$err_tmp
else
	mail -s "SUp: Homebrew-OK" $(whoami) <$out_tmp
fi

/usr/local/bin/mas upgrade 1>$out_tmp 2>$err_tmp
if [[ $? -ne 0 ]]; then
	mail -s "SUp: MAS-ERROR" $(whoami) <$err_tmp
else
	mail -s "SUp: MAS-OK" $(whoami) <$out_tmp
fi

rm $out_tmp
rm $err_tmp

exit 0
