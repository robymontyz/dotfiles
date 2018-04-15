#!/bin/bash

# Export bash settings to BACKUPDIR

BACKUPDIR="/Volumes/MacOS-HDD_500GB/Installed/bash_mods"

if [ $# -eq 0 ]; then
	echo "Using default backup dir: ${BACKUPDIR}"; echo
elif [ $# -eq 1 ] && [ -d $1 ]; then
	BACKUPDIR=$1
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
# NB: If the source_file ends in a /, the contents of the directory 
# are copied rather than the directory itself
cp -Rfp ~/.vim/ ${BACKUPDIR}/vim

# screen settings
cp -fp ~/.screenrc ${BACKUPDIR}/screenrc

# personal scripts
cp -Rfp ~/.scripts/ ${BACKUPDIR}/scripts

# personal Agents
cp -fp ~/Library/LaunchAgents/com.scripts.ExportBashSettings.plist ${BACKUPDIR}/LaunchAgents/
cp -fp ~/Library/LaunchAgents/com.scripts.HomebrewUpdate.plist ${BACKUPDIR}/LaunchAgents/
cp -fp ~/Library/LaunchAgents/com.scripts.MagpiDownload.plist ${BACKUPDIR}/LaunchAgents/

# Crontab file
#crontab -l > ${BACKUPDIR}/crontab_file

echo "Bash settings saved in ${BACKUPDIR}"
