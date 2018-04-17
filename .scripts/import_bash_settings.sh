#!/bin/bash

# Import bash settings from BACKUPDIR

# TODO: choose your default BACKUDIR here
BACKUPDIR=".."

if [ $# -eq 0 ] && [ -d $BACKUPDIR ]; then
	echo "Using default backup dir: ${BACKUPDIR}"; echo
elif [ $# -eq 1 ] && [ -d $1 ]; then
	BACKUPDIR=$1
elif ! [ -d ${BACKUPDIR} ] || ! [ -d $1 ]; then
	echo "Invalid directory" >&2
	exit 1
else
	echo "Usage: $0 [backupdir]" >&2
	exit 1
fi

# backup existing settings before importing
if ! [ -d ${BACKUPDIR}/bak ]; then
	mkdir ${BACKUPDIR}/bak
fi
${BACKUPDIR}/scripts/export_bash_settings.sh ${BACKUPDIR}/bak
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

# install homebrew and its formulae
# check if homebrew is installed
brew help
if [ $? -ne 0 ]; then
	# install homebrew
	echo "Installing Homebrew..."
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
# install all formulae
if [ -f ${BACKUPDIR}/brew_installed.txt ]; then
	echo "Installing brew formulae..."
	brew install $(< ${BACKUPDIR}/brew_installed.txt)
else
	echo "No formulae previously installed (or exported)"
	echo "Launch 'brew leaves > ${BACKUPDIR}/brew_installed.txt' to export"
fi

# git settings
cp -fp ${BACKUPDIR}/gitconfig ~/.gitconfig
mkdir -p ~/.config/git/ && cp -fp ${BACKUPDIR}/config/git/ignore $_

# screen settings
cp -fp ${BACKUPDIR}/screenrc ~/.screenrc

# gpg settings
mkdir -p ~/.gnupg/ && cp -fp ${BACKUPDIR}/gnupg/pubring.kbx $_
# possibly recreate trustdb if corrupted
#mv ~/.gnupg/trustdb.gpg ~/.gnupg/trustdb.OLD
#gpg --import-ownertrust < ${BACKUPDIR}/gnupg/ownertrust.txt

# personal scripts
cp -Rfp ${BACKUPDIR}/scripts/ ~/.scripts

# personal launchd agents (macOS/launchd users only)
# TODO: comment these lines if you don't want this feature
# no need to create dir tree, already present on default
cp -fp ${BACKUPDIR}/LaunchAgents/com.scripts.ExportBashSettings.plist ~/Library/LaunchAgents/
cp -fp ${BACKUPDIR}/LaunchAgents/com.scripts.HomebrewUpdate.plist ~/Library/LaunchAgents/
cp -fp ${BACKUPDIR}/LaunchAgents/com.scripts.MagpiDownload.plist ~/Library/LaunchAgents/

# Crontab file
# TODO: comment these lines if you are using launchd
#crontab ${BACKUPDIR}/crontab_file

# Install 'Solarized Dark' color schemes
# Color scheme for Terminal.app (macOS only)
open ${BACKUPDIR}/Solarized\ Dark\ -\ Patched.terminal
echo "NB: open Terminal settings and make Solarized Dark the default theme!"; echo
# Color scheme for Xcode (macOS only)
cp ${BACKUPDIR}/Solarized\ Dark.xccolortheme ~/Library/Developer/Xcode/UserData/FontAndColorThemes/
echo "NB: open Xcode settings and make Solarized Dark the default theme!"; echo

echo "Bash settings correctly imported from ${BACKUPDIR}"
