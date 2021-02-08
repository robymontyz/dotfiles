#!/bin/bash -e
## import_bash_settings
## Import shell and various settings from BACKUPDIR
## Copyright (C) 2018-2021 robymontyz
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
## Usage: import_bash_settings.sh [backupdir]

# TODO: choose your default BACKUPDIR here
BACKUPDIR="/Volumes/MacOS-HDD_500GB/Installed/bash_mods"
_OS_NAME="$(uname -s)"

# check arguments
if [[ $# -eq 0 ]] && [[ -d $BACKUPDIR ]]; then
	echo "Using default backup dir: ${BACKUPDIR}"; echo
elif [[ $# -eq 1 ]] && [[ -d $1 ]]; then
	BACKUPDIR=$1
elif ! [[ -d ${BACKUPDIR} ]] || ! [[ -d $1 ]]; then
	echo "$0: Invalid directory" >&2
	exit 1
else
	echo "Usage: $0 [backupdir]" >&2
	exit 1
fi

echo "-----------------------------------------"
echo "Backing up existing settings..."
# backup existing settings before importing
bak=bak"$(date "+%Y%m%d%H%M%S")"
mkdir -p ${BACKUPDIR}/${bak} && ${BACKUPDIR}/scripts/export_bash_settings.sh $_
echo "-----------------------------------------"

# continue only if backup has gone well
if [[ $? -eq 0 ]]; then
	echo "Importing..."; echo

	# bash settings
	rsync -a ${BACKUPDIR}/bash_profile ~/.bash_profile
	rsync -a ${BACKUPDIR}/bashrc ~/.bashrc
	rsync -a ${BACKUPDIR}/inputrc ~/.inputrc
	echo "bash settings exported if exist."; echo

# ViM settings
	rsync -a ${BACKUPDIR}/vimrc ~/.vimrc
	# NB: if the source ends in a /, the contents of the directory are copied rather than the directory itself
	rsync -a ${BACKUPDIR}/vim/ ~/.vim/
	echo "ViM settings exported if exist."; echo

	# git settings
	rsync -a ${BACKUPDIR}/gitconfig ~/.gitconfig
	mkdir -p ~/.config/git/ && rsync -a ${BACKUPDIR}/config/git/ignore $_
	echo "git settings exported if exist."; echo

	# screen settings
	rsync -a ${BACKUPDIR}/screenrc ~/.screenrc
	echo "screen settings exported if exist."; echo

	# ssh/sshd settings and keys
	rsync -a ${BACKUPDIR}/ssh/ ~/.ssh/
	echo "(Insert admin password to import sshd_config file if requested)"
	sudo rsync -a ${BACKUPDIR}/sshd/sshd_config /etc/ssh/sshd_config
	echo "SSH settings exported if exist."; echo

	# personal scripts
	rsync -a ${BACKUPDIR}/scripts/ ~/.scripts/
	echo "Personal scripts exported if exist."; echo

	# crontab file
	# TODO: comment these lines if you are using launchd
	#crontab ${backupdir}/crontab_file
	#echo "crontab exported if exist."; echo

	# install specific setting on macOS
	if [[ "${_OS_NAME}" ==  "Darwin" ]]; then
		# ======== macos only ======== #
		echo "-----------------------------------------"
		echo "macOS installed. Importing specific setting..."; echo

		# ======== CLI Tools ======== #
		xcode-select -p > /dev/null
		if [[ $? -ne 0 ]]; then
			echo "Installing Command Line Tools..."
			xcode-select --install
			echo "CLI installed"; echo
		fi

		# ======== Directories symlinks ======== #
		# make ~/Applications/, ~/Documents/, ~/Downloads/, ~/Movies/, ~/Music/ folders a link to the ones on the HDD
		echo "(Insert admin password to symlink directories if requested)"
		${BACKUPDIR}/scripts/symlinked.sh
		echo "Home directories symlinked to HDD. See scripts/symlinked.sh for more"; echo

		# ======== Homebrew ======== #
		# install homebrew and its formulae
		# check if homebrew is installed
		command -v brew > /dev/null
		if [[ $? -ne 0 ]]; then
			# install homebrew
			echo "Installing Homebrew..."
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
			echo "Homebrew installed."; echo

			# homebrew settings
			brew analytics off    # opt-out from analytics
			echo "Opted out from Homebrew analytics."; echo
		fi
		# install all formulae
		if [[ -f ${BACKUPDIR}/install/brew ]]; then
			echo "Installing brew formulae..."
			brew install $(< ${BACKUPDIR}/install/brew)
			echo "Brew formulae installed."; echo
		else
			echo "No formulae previously installed (or exported)."
			echo "Launch 'brew leaves > ${BACKUPDIR}/install/brew' to export"; echo
		fi
		# install all casks
		if [[ -f ${BACKUPDIR}/install/brew-casks ]]; then
			echo "Installing brew casks..."
			brew install --casks $(< ${BACKUPDIR}/install/brew-casks)
			echo "Brew casks installed."; echo
		else
			echo "No casks previously installed (or exported)."
			echo "Launch 'brew list --casks > ${BACKUPDIR}/install/brew-casks' to export"; echo
		fi

		# ======== MAS ======== #
		# install Mac App Store applications
		# check if mas utility is installed
		command -v mas > /dev/null
		if [[ $? -ne 0 ]]; then
			# install mas
			echo "Installing mas from Homebrew..."
			brew install mas
			echo "mas installed."; echo
		fi
		# install all applications
		if [[ -f ${BACKUPDIR}/install/mas ]]; then
			echo "Installing MAS applications..."
			mas install $(cat ${BACKUPDIR}/install/mas | cut -d " " -f 1)
			echo "MAS applications installed."; echo
		else
			echo "No MAS applications previously installed (or exported)."
			echo "Launch 'mas list > ${BACKUPDIR}/install/mas' to export"; echo
		fi
		
		# ======== Plugins ======== #
		# QuickLook plugins (macOS only)
		rsync -a ${BACKUPDIR}/plugins/QL/ ~/Library/QuickLook/
		# reload QuickLook plugin manager
		qlmanage -r
		echo "Quicklook plugins imported."; echo

		# ======== launchd ======== #
		# personal launchd agents (macOS/launchd users only)
		# TODO: comment these lines if you don't want this feature
		# no need to create dir tree, already present on default
		rsync -a ${BACKUPDIR}/LaunchAgents/com.scripts.* ~/Library/LaunchAgents/
		# load jobs
		find ~/Library/LaunchAgents -type f -name "com.scripts.*" -exec launchctl load {} \;
		# start jobs
		find ~/Library/LaunchAgents -type f -name "com.scripts.*" -exec /usr/libexec/PlistBuddy -c "Print Label" {} \; | xargs launchctl start
		echo "LaunchAgents imported."; echo

		# ======== Themes ======== #
		# Install 'Solarized Dark' color schemes
		# Color scheme for Terminal.app (macOS only)
		open ${BACKUPDIR}/themes/Solarized\ Dark.terminal
		echo "Theme for Terminal.app installed."
		echo "NB: open Terminal settings and make Solarized Dark the default theme!"; echo
		# Color scheme for Xcode (macOS only)
		mkdir -p ~/Library/Developer/Xcode/UserData/FontAndColorThemes/ && rsync -a ${BACKUPDIR}/themes/Solarized\ Dark.xccolortheme $_
		echo "Theme for Xcode installed."
		echo "NB: open Xcode settings and make Solarized Dark the default theme!"; echo
		
		# ======== Misc ======== #
		# disable default automatic creation of a webserver in macOS
		#sudo apachectl stop
		echo "End of macOS part."
		echo "-----------------------------------------"; echo
	fi

	# pip modules
	pip3 install -r ${BACKUPDIR}/install/pip
	echo "pip modules installed."; echo

	# gpg settings
	rsync -a ${BACKUPDIR}/gnupg/pubring.kbx ~/.gnupg/
	rsync -a ${BACKUPDIR}/gnupg/openpgp-revocs.d/ ~/.gnupg/openpgp-revocs.d/
	rsync -a ${BACKUPDIR}/gnupg/private-keys-v1.d/ ~/.gnupg/private-keys-v1.d/
	# check if trustdb already exist
	if [[ -f ~/gnupg/trustdb.gpg ]]; then mv ~/.gnupg/trustdb.gpg ~/.gnupg/trustdb.OLD; fi
# fix gnupg folder permissions
	chmod 700 ~/.gnupg
	chmod 600 ~/.gnupg/pubring.kbx
	gpg --import-ownertrust < ${BACKUPDIR}/gnupg/ownertrust.txt
	echo "gpg keys and settings imported."; echo

	. ~/.bashrc   # reload bash configuration

	echo "Bash settings correctly imported from ${BACKUPDIR}"

else
	echo "Backup folder cannot be created. Aborting..."
	exit 1
fi

