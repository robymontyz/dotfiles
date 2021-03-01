#!/bin/bash -e
## export_bash_settings
## Export shell and various settings into BACKUPDIR
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
## Usage: export_bash_settings.sh [backupdir]

# TODO: choose your default BACKUDIR here
BACKUPDIR="$HOME/dev/dotfiles"
_OS_NAME="$(uname -s)"

if [[ $# -eq 0 ]] && [[ -d ${BACKUPDIR} ]]; then
	echo "Using default backup dir: ${BACKUPDIR}"; echo
elif [[ $# -eq 1 ]] && [[ -d $1 ]]; then
	BACKUPDIR=$1
else
	echo "Usage: $0 [backupdir]" >&2
	exit 1
fi

echo "Exporting..."; echo

# bash settings
if [[ -f ~/.bash_profile ]]; then rsync -a ~/.bash_profile ${BACKUPDIR}/bash_profile; fi
if [[ -f ~/.bashrc ]]; then rsync -a ~/.bashrc ${BACKUPDIR}/bashrc; fi
if [[ -f ~/.inputrc ]]; then rsync -a ~/.inputrc ${BACKUPDIR}/inputrc; fi
echo "bash settings exported if exist."; echo

# zsh settings
if [[ -f ~/.zprofile ]]; then rsync -a ~/.zprofile ${BACKUPDIR}/zprofile; fi
if [[ -f ~/.zshrc ]]; then rsync -a ~/.zshrc ${BACKUPDIR}/zshrc; fi
echo "zsh settings exported if exist."; echo

# ViM settings
if [[ -f ~/.vimrc ]]; then rsync -a ~/.vimrc ${BACKUPDIR}/vimrc; fi
# NB: If the source_file ends in a /, the contents of the directory are copied rather than the directory itself
# NB2: create dir tree first! $_ is the last argument of previous command
if [[ -d ~/.vim ]]; then rsync -a ~/.vim/ ${BACKUPDIR}/vim/; fi
echo "ViM settings exported if exist."; echo

# git settings
if [[ -f ~/.gitconfig ]]; then rsync -a ~/.gitconfig ${BACKUPDIR}/gitconfig; fi
if [[ -f ~/.config/git/ignore ]]; then mkdir -p ${BACKUPDIR}/config/git/ && rsync -a ~/.config/git/ignore $_; fi
echo "git settings exported if exist."; echo

# screen settings
if [[ -f ~/.screenrc ]]; then rsync -a ~/.screenrc ${BACKUPDIR}/screenrc; fi
echo "screen settings exported if exist."; echo

# ssh/sshd settings and keys
if [[ -d ~/.ssh ]]; then rsync -a ~/.ssh/ ${BACKUPDIR}/ssh/; fi
if [[ -f /etc/ssh/sshd_config ]]; then rsync -a /etc/ssh/sshd_config ${BACKUPDIR}/sshd/; fi
echo "SSH settings exported if exist."; echo

# personal scripts
if [[ -d ~/.scripts ]]; then rsync -a ~/.scripts/ ${BACKUPDIR}/scripts/; fi
echo "Personal scripts exported if exist."; echo

# Crontab file
# TODO: comment these lines if you are using launchd
#crontab -l > ${BACKUPDIR}/crontab_file
#echo "crontab exported."; echo

# export specific setting on macOS
if [[ "${_OS_NAME}" ==  "Darwin" ]]; then
	# ======== macOS ONLY ======== #
	echo "-----------------------------------------"
	echo "macOS installed. Exporting specific setting..."; echo

	# ======== Homebrew ======== #
	# homebrew formulae and casks installed
	# check if homebrew is installed
	command -v brew > /dev/null
	if [[ $? -ne 0 ]]; then
		# install homebrew!
		echo "Homebrew not installed. Skipped."; echo >&2
	else
		#mkdir -p ~/.install/ && brew leaves > ~/.install/brew
		mkdir -p ${BACKUPDIR}/install/ && brew leaves > ${BACKUPDIR}/install/brew
		#brew list --casks > ~/.install/brew-casks
		brew list --casks > ${BACKUPDIR}/install/brew-casks
		echo "List of installed Homebrew packages and casks exported."; echo
	fi
	
	# ======== MAS ======== #
	# Mac App Store applications installed
	# check if mas utility is installed
	command -v mas > /dev/null
	if [[ $? -ne 0 ]]; then
		# install mas!
		echo "mas not installed. Skipped." >&2
		echo "Install Homebrew and then run: $ > brew install mas"; echo >&2
	else
		#mkdir -p ~/.install/ && mas list > ~/.install/mas
		mkdir -p ${BACKUPDIR}/install/ && mas list > ${BACKUPDIR}/install/mas
		echo "List of installed Mac App Store apps exported."; echo
	fi

	# ======== Plugins ======== #
	# Personal QuickLook plugins (macOS only)
	mkdir -p ${BACKUPDIR}/plugins/QL/ && rsync -a ~/Library/QuickLook/ $_
	echo "macOS plugins exported if exist."; echo

	# ======== launchd ======== #
	# personal launchd agents (macOS/launchd users only)
	# TODO: comment these lines if you don't want this feature
	ls ~/Library/LaunchAgents/com.scripts.* 1>/dev/null 2>&1 && rsync -a ~/Library/LaunchAgents/com.scripts.* ${BACKUPDIR}/LaunchAgents/
	echo "LaunchAgents exported if exist."; echo
	
	# ======== Themes ======== #
	# themes for various macOS apps
	if [[ -d ~/.themes ]]; then rsync -a ~/.themes/ ${BACKUPDIR}/themes/; fi
	echo "Themes exported if exist."; echo
	
	echo "End of macOS part."
	echo "-----------------------------------------"; echo
fi

# Sublime Text preferences
if [[ -d ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User ]]; then rsync -a ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/ ${BACKUPDIR}/SublimeText/; fi
echo "Sublime Text preferences exported if exist."; echo

# pip modules
command -v pip3 > /dev/null && mkdir -p ${BACKUPDIR}/install && pip3 list | cut -d " " -f 1 | tail -n +3 > ${BACKUPDIR}/install/pip
echo "List of installed Python Packages (PyP) exported if exist."; echo

# gpg settings
if [[ -f ~/.gnupg/pubring.kbx ]]; then rsync -a ~/.gnupg/pubring.kbx ${BACKUPDIR}/gnupg/; fi
if [[ -d ~/.gnupg/openpgp-revocs.d ]]; then rsync -a ~/.gnupg/openpgp-revocs.d/ ${BACKUPDIR}/gnupg/openpgp-revocs.d/; fi
if [[ -d ~/.gnupg/private-keys-v1.d ]]; then rsync -a ~/.gnupg/private-keys-v1.d/ ${BACKUPDIR}/gnupg/private-keys-v1.d/; fi
command -v gpg > /dev/null && gpg --export-ownertrust > ${BACKUPDIR}/gnupg/ownertrust.txt
echo "gpg keys and settings exported if exist."; echo

echo "Bash settings correctly saved in ${BACKUPDIR}"

