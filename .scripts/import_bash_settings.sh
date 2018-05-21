#!/bin/bash
## import_bash_settings
## Import shell and various settings from BACKUPDIR
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
## Usage: import_bash_settings.sh [backupdir]

# TODO: choose your default BACKUDIR here
BACKUPDIR="."
_OS_NAME="$(uname -s)"

# check arguments
if [[ $# -eq 0 ]] && [[ -d $BACKUPDIR ]]; then
	echo "Using default backup dir: ${BACKUPDIR}"; echo
elif [[ $# -eq 1 ]] && [[ -d $1 ]]; then
	BACKUPDIR=$1
elif ! [[ -d ${BACKUPDIR} ]] || ! [[ -d $1 ]]; then
	echo "Invalid directory" >&2
	exit 1
else
	echo "Usage: $0 [backupdir]" >&2
	exit 1
fi

echo "Backing up existing settings..."
# backup existing settings before importing
bak=bak"$(date "+%Y%m%d%H%M%S")"
mkdir -p ${BACKUPDIR}/${bak} && ${BACKUPDIR}/.scripts/export_bash_settings.sh $_

# continue only if backup has gone well
if [[ $? -eq 0 ]]; then
	# install specific setting on macOS
	if [[ "${_OS_NAME}" ==  "Darwin" ]]; then
		# ======== macOS ONLY ======== #
		echo "macOS installed. Importing specific setting..."

		# ======== Homebrew ======== #
		# install homebrew and its formulae
		# check if homebrew is installed
		brew help > /dev/null
		if [[ $? -ne 0 ]]; then
			# install homebrew
			echo "Installing Homebrew..."
			ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		fi
		# install all formulae
		if [[ -f ${BACKUPDIR}/.install/brew ]]; then
			echo "Installing brew formulae..."
			brew install $(< ${BACKUPDIR}/.install/brew)
		else
			echo "No formulae previously installed (or exported)"
			echo "Launch 'brew leaves > ${BACKUPDIR}/.install/brew' to export"
		fi
		# homebrew settings
		brew analytics off    # opt-out from analytics

		# ======== Plugins ======== #
		# QuickLook plugins (macOS only)
		rsync -a ${BACKUPDIR}/.plugins/QL/ ~/Library/QuickLook/
		# reload QuickLook plugin manager
		qlmanage -r

		# ======== launchd ======== #
		# personal launchd agents (macOS/launchd users only)
		# TODO: comment these lines if you don't want this feature
		# no need to create dir tree, already present on default
		rsync -a ${BACKUPDIR}/LaunchAgents/com.scripts.ExportBashSettings.plist ~/Library/LaunchAgents/
		rsync -a ${BACKUPDIR}/LaunchAgents/com.scripts.HomebrewUpdate.plist ~/Library/LaunchAgents/
		rsync -a ${BACKUPDIR}/LaunchAgents/com.scripts.MagpiDownload.plist ~/Library/LaunchAgents/

		# ======== Themes ======== #
		# Install 'Solarized Dark' color schemes
		# Color scheme for Terminal.app (macOS only)
		open ${BACKUPDIR}/.themes/Solarized\ Dark.terminal
		echo; echo "NB: open Terminal settings and make Solarized Dark the default theme!"
		# Color scheme for Xcode (macOS only)
		# check if Xcode is installed first!
		xcode-select -p > /dev/null
		if [[ $? -eq 0 ]]; then
			rsync -a ${BACKUPDIR}/.themes/Solarized\ Dark.xccolortheme ~/Library/Developer/Xcode/UserData/FontAndColorThemes/
			echo "NB: open Xcode settings and make Solarized Dark the default theme!"; echo
		else
			echo "Cannot install theme: Xcode not installed."
		fi
	fi

	# bash settings
	rsync -a ${BACKUPDIR}/.bash_profile ~/.bash_profile
	rsync -a ${BACKUPDIR}/.bashrc ~/.bashrc
	rsync -a ${BACKUPDIR}/.inputrc ~/.inputrc

	# ViM settings
	rsync -a ${BACKUPDIR}/.vimrc ~/.vimrc
	# NB: If the source ends in a /, the contents of the directory are copied rather than the directory itself
	rsync -a ${BACKUPDIR}/.vim/ ~/.vim/

	# git settings
	rsync -a ${BACKUPDIR}/.gitconfig ~/.gitconfig
	mkdir -p ~/.config/git/ && rsync -a ${BACKUPDIR}/.config/git/ignore $_

	# screen settings
	rsync -a ${BACKUPDIR}/.screenrc ~/.screenrc

	# gpg settings
	rsync -a ${BACKUPDIR}/.gnupg/pubring.kbx ~/.gnupg/
	# possibly recreate trustdb if corrupted
	#mv ~/.gnupg/trustdb.gpg ~/.gnupg/trustdb.OLD
	#gpg --import-ownertrust < ${BACKUPDIR}/.gnupg/ownertrust.txt

	# ssh/sshd settings and keys
	rsync -a ${BACKUPDIR}/.ssh/ ~/.ssh/
	echo "Insert admin password to import sshd_config file"
	sudo rsync -a ${BACKUPDIR}/sshd/sshd_config /etc/ssh/sshd_config

	# personal scripts
	rsync -a ${BACKUPDIR}/.scripts/ ~/.scripts/

	# Crontab file
	# TODO: comment these lines if you are using launchd
	#crontab ${BACKUPDIR}/crontab_file

	. ~/.bashrc   # reload bash configuration

	echo "Bash settings correctly imported from ${BACKUPDIR}"

else
	echo "Backup folder cannot be created. Aborting..."
	exit 1
fi
