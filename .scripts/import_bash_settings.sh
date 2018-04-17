#!/bin/bash

# Import bash settings from BACKUPDIR

# TODO:choose your default BACKUDIR here
BACKUPDIR="/Volumes/MacOS-HDD_500GB/Installed/bash_mods"

if [ $# -eq 0 ]; then
	echo "Using default backup dir: ${BACKUPDIR}"; echo
elif [ $# -eq 1 ] && [ -d $1 ]; then
	BACKUPDIR=$1
else
	echo "Usage: $0 [backupdir]" >&2
	exit 1
fi

# backup existing settings before importing
if ! [ -d ./bak ]; then
	mkdir ./bak
fi
${BACKUPDIR}/scripts/export_bash_settings.sh ./bak
echo "Old settings were saved in ${BACKUPDIR}/bak"

# bash settings
cp -fp ${BACKUPDIR}/bash_profile ~/.bash_profile
cp -fp ${BACKUPDIR}/bashrc ~/.bashrc
cp -fp ${BACKUPDIR}/inputrc ~/.inputrc

# ViM settings
cp -fp ${BACKUPDIR}/vimrc ~/.vimrc
# NB: If the source_file ends in a /, the contents of the directory
# are copied rather than the directory itself
cp -Rfp ${BACKUPDIR}/vim/spell/ ~/.vim/spell

# git settings
cp -fp ${BACKUPDIR}/gitconfig ~/.gitconfig 
cp -fp ${BACKUPDIR}/config/git/ignore ~/.config/git/ignore

# screen settings
cp -fp ${BACKUPDIR}/screenrc ~/.screenrc

# gpg settings
cp -fp ${BACKUPDIR}/gnupg/pubring.kbx ~/.gnupg/pubring.kbx
# possibly recreate trustdb if corrupted
#mv ~/.gnupg/trustdb.gpg ~/.gnupg/trustdb.OLD
#gpg --import-ownertrust < ${BACKUPDIR}/ownertrust.txt

# install homebrew and its formulae
# check if homebrew is installed
brew help
if [ $? -ne 0 ]; then
	# install homebrew
	echo "Installing Homebrew..."
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
# install all formulae
echo "Installing brew formulae..."
brew install $(< list.txt)

# personal scripts
cp -Rfp ${BACKUPDIR}/scripts/ ~/.scripts

# personal Agents
cp -fp ${BACKUPDIR}/LaunchAgents/com.scripts.ExportBashSettings.plist ~/Library/LaunchAgents/
cp -fp ${BACKUPDIR}/LaunchAgents/com.scripts.HomebrewUpdate.plist ~/Library/LaunchAgents/
cp -fp ${BACKUPDIR}/LaunchAgents/com.scripts.MagpiDownload.plist ~/Library/LaunchAgents/

# Crontab file
#crontab ${BACKUPDIR}/crontab_file

# Color scheme for Terminal.app
open ${BACKUPDIR}/Solarized\ Dark\ -\ Patched.terminal
echo "NB: open Terminal settings and make Solarized Dark the default theme!"; echo
# Color scheme for Xcode
cp ${BACKUPDIR}/Solarized\ Dark.xccolortheme ~/Library/Developer/Xcode/UserData/FontAndColorThemes/
echo "NB: open Xcode settings and make Solarized Dark the default theme!"; echo

echo "Bash settings correctly imported from ${BACKUPDIR}"
