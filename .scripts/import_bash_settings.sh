#!/bin/bash

# Import bash settings from BACKUPDIR

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

# bash settings
cp -fp ${BACKUPDIR}/bash_profile ~/.bash_profile
cp -fp ${BACKUPDIR}/bashrc ~/.bashrc
cp -fp ${BACKUPDIR}/inputrc ~/.inputrc

# ViM settings
cp -fp ${BACKUPDIR}/vimrc ~/.vimrc
# NB: If the source_file ends in a /, the contents of the directory
# are copied rather than the directory itself
cp -Rfp ${BACKUPDIR}/vim/ ~/.vim

# screen settings
cp -fp ${BACKUPDIR}/screenrc ~/.screenrc 

# git settings
cp -fp ${BACKUPDIR}/gitconfig ~/.gitconfig 
cp -Rfp ${BACKUPDIR}/config/git/ ~/.config/git

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
echo "Old settings were saved in ${BACKUPDIR}/bak"
