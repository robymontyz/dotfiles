#!/bin/bash
## export_bash_settings
## Export shell and various settings into BACKUPDIR
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
## Usage: export_bash_settings.sh [backupdir]

# TODO: choose your default BACKUDIR here
BACKUPDIR=""
_OS_NAME="$(uname -s)"

if [[ $# -eq 0 ]] && [[ -d ${BACKUPDIR} ]]; then
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

# bash settings
cp -fp ~/.bash_profile ${BACKUPDIR}/bash_profile
cp -fp ~/.bashrc ${BACKUPDIR}/bashrc
cp -fp ~/.inputrc ${BACKUPDIR}/inputrc

# ViM settings
cp -fp ~/.vimrc ${BACKUPDIR}/vimrc
# NB: If the source_file ends in a /, the contents of the directory are copied rather than the directory itself
# NB2: create dir tree first! $_ is the last argument of previous command
mkdir -p ${BACKUPDIR}/vim/ && cp -Rfp ~/.vim/ $_

# export specific setting on macOS
if [[ "${_OS_NAME}" ==  "Darwin" ]]; then
	# ======== macOS ONLY ======== #
	echo "macOS installed. Loading specific setting..."

	# ======== Homebrew ======== #
	# homebrew formulae installed
	# check if homebrew is installed
	brew help > /dev/null
	if [[ $? -ne 0 ]]; then
		# install homebrew!
		echo "Homebrew not installed" >&2
	else
		brew leaves > ${BACKUPDIR}/brew_installed.txt
	fi

	# ======== launchd ======== #
	# personal launchd agents (macOS/launchd users only)
	# TODO: comment these lines if you don't want this feature
	mkdir -p ${BACKUPDIR}/LaunchAgents/
	cp -fp ~/Library/LaunchAgents/com.scripts.ExportBashSettings.plist ${BACKUPDIR}/LaunchAgents/
	cp -fp ~/Library/LaunchAgents/com.scripts.HomebrewUpdate.plist ${BACKUPDIR}/LaunchAgents/
	cp -fp ~/Library/LaunchAgents/com.scripts.MagpiDownload.plist ${BACKUPDIR}/LaunchAgents/

	# ======== Themes ======== #
	# themes for various macOS apps
	mkdir -p ${BACKUPDIR}/themes/ && cp -Rfp ~/.themes/ $_
fi

# git settings
cp -fp ~/.gitconfig ${BACKUPDIR}/gitconfig
mkdir -p ${BACKUPDIR}/config/git/ && cp -fp ~/.config/git/ignore $_

# screen settings
cp -fp ~/.screenrc ${BACKUPDIR}/screenrc

# gpg settings
mkdir -p ${BACKUPDIR}/gnupg/ && cp -fp ~/.gnupg/pubring.kbx $_
gpg --export-ownertrust > ${BACKUPDIR}/gnupg/ownertrust.txt

# ssh/sshd settings and keys
mkdir -p ${BACKUPDIR}/ssh/ && cp -Rfp ~/.ssh/ $_
mkdir -p ${BACKUPDIR}/sshd/ && cp -fp /etc/ssh/sshd_config $_

# personal scripts
mkdir -p ${BACKUPDIR}/scripts/ && cp -Rfp ~/.scripts/ $_

# Crontab file
# TODO: comment these lines if you are using launchd
#crontab -l > ${BACKUPDIR}/crontab_file

echo "Bash settings correctly saved in ${BACKUPDIR}"
