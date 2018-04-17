# color ls
# (to customize colors add LSCOLORS var)
export CLICOLOR=1

# color grep matches (auto: no color when piping to other cmds)
# (to customize colors add GREP_COLOR var)
export GREP_OPTIONS='--color=auto'

# lines matching the previous history entry will not be saved
export HISTCONTROL=ignoredups

# For gpg-agent
export GPG_TTY=$(tty)

# shell options ("shopt -p" for a complete list)
shopt -s cdspell		# correct dir spelling errors on cd
# not available in macOS
#shopt -s autocd     # if a command is a dir name, cd to it
#shopt -s dirspell   # correct dir spelling errors on completion

# alias
alias lsusb='system_profiler SPUSBDataType'    # output lsusb-like



# ------------------------------------------------------------
# Prompts
# ------------------------------------------------------------

# color codes
BOLD=$'\e[1m'
GREEN=$'\e[32m'
RED=$'\e[31m'
BRED=$'\e[31;1m'
BGREEN=$'\e[32;1m'
BORANGE=$'\e[33;1m'
BBLUE=$'\e[34;1m'
NONE=$'\e[m'

# trims long paths down to 80 chars
_get_path(){
	local x=$(pwd | sed -e "s:$HOME:~:")
	local len=${#x}
	local max=40
	if [ $len -gt $max ]; then
		echo "...${x:((len-max+3))}"
	else
		echo "${x}"
	fi
}
 
# prints a colour coded exit status
_get_exit_status(){
	local es=$?
		if [ $es -eq 0 ]; then
			echo "${GREEN}${es}${NONE}"
		else
			echo "${RED}${es}${NONE}"
		fi
}

if [ $UID -eq 0 ]; then
	# root user
	USER_COLOR="${BRED}"
else
	# normal user
	USER_COLOR="${BBLUE}"
fi

# can change due to the actual connected machine
HOST_COLOR="${BBLUE}"

PROMPT_COMMAND='exit_status=$(_get_exit_status); mydir=$(_get_path);'

export PS1='[\[${BOLD}\]\t\[${NONE}\]] \
\[${USER_COLOR}\]\u\[${NONE}\]@\[${HOST_COLOR}\]\h:\
\[${BORANGE}\]\[${mydir}\] \
\[${NONE}\][\[${BOLD}\]!\!\[${NONE}\]|\
\[${exit_status}\]]\n\
\[${USER_COLOR}\]\$\[${NONE}\] '

export PS2='\[${USER_COLOR}\]>\[${NONE}\] '

export PS4='$0:${LINENO}\[${USER_COLOR}\]+\[${NONE}\] '



# ------------------------------------------------------------ 
# Functions
# ------------------------------------------------------------

# moves file to ~/.Trash (use instead of rm)
trash(){
	if [ $# -eq 0 ]; then
		echo Usage: trash FILE...
		return 1
	fi

	for FILE in "$@"; do
		local DATE=$(date +%Y%m%d%H%M%S)
		# if already in trash move it in a new folder with date
		if [ -f "${HOME}/.Trash/${FILE}" ]; then
			mkdir "${HOME}/.Trash/${DATE}"
			mv "${FILE}" ${HOME}/.Trash/${DATE}
			echo "${FILE} trashed in ${DATE}/!"
		else
			mv "${FILE}" "${HOME}/.Trash/"
			echo "${FILE} trashed!"
		fi
	done
}

# Make a directory and change to it
mkcd() {
  if [ $# -ne 1 ]; then
         echo "Usage: mkcd <dir>"
         return 1
  else
         mkdir -p "$@" && cd "$_"
  fi
}

# Swap two files
swap(){
    if [ $# -ne 2 ]; then
        echo "Usage: swap <file1> <file2>"
        return 1
    fi
    local TMPFILE=$(mktemp $(dirname "$1")/XXXXXX)
    mv "$1" "$TMPFILE"
    mv "$2" "$1"
    mv "$TMPFILE" "$2"
}

chksum(){
	if [ $# -ne 2 ]; then
		echo "Usage: chksum [-md5] <file> <sha1>"
		return 1
	fi

	#[ $1 == "-md5"] && 
	shasum $1 |
	while read -r sum _ ; do
		[[ $sum == $(echo "$2" | tr '[:upper:]' '[:lower:]') ]]\
			&& echo "sha1 identical" \
			|| echo "WARNING: sha1 NOT identical!"
	done
}
