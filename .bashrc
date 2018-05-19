# Bash configuration file

# _OS_NAME="$(uname -s)"
# bash set $OSTYPE, I can check it to know OS

# ======== Options ========
# colored ls output
if [[ "${OSTYPE}" == "darwin"* ]]; then
	# under macOS
	# (for customization add LSCOLORS var)
	export CLICOLOR=1
elif [[ "${OSTYPE}" == "linux"* ]]; then
	# under Linux
	alias ls='ls --color=auto'
fi

# color grep matches (auto: no color when piping to other cmds)
# (for customization add GREP_COLOR var)
# DEPRECATED
#export GREP_OPTIONS='--color=auto'

# lines matching the previous history entry will not be saved
# previous same history entry will be deleted
# N.B. export not needed because is used by shell itself
HISTCONTROL=ignoredups:erasedups

# For gpg-agent
export GPG_TTY=$(tty)

# change default location for personal mailbox for 'mail' command
export MBOX='~/.mbox'

# shell options ("shopt -p" for a complete list)
shopt -s cdspell      # correct dir spelling errors on cd
shopt -s cmdhist      # save multi-line commands as one command
#shopt -s histappend  # append to the history file when shell exit
if [[ "${OSTYPE}" == "linux"* ]]; then
	# not available in macOS
	shopt -s autocd      # if a command is a dir name, cd to it
	shopt -s dirspell    # correct dir spelling errors on completion
fi

# highlighting inside man and less pages
#export LESS_TERMCAP_mb=$'\E[1;31m'    # begin blinking; (?)
#export LESS_TERMCAP_md=$'\E[1;34m'    # begin bold; titles and keywords
#export LESS_TERMCAP_me=$'\E[0m'       # end mode; text
#export LESS_TERMCAP_se=$'\E[0m'       # end standout-mode (?)
#export LESS_TERMCAP_so=$'\E[0;100m'   # begin standout-mode; info line
#export LESS_TERMCAP_ue=$'\E[0m'       # end underline; text
#export LESS_TERMCAP_us=$'\E[4;36m'    # begin underline; arguments


# ======== Aliases ========
if [[ "${OSTYPE}" == "darwin"* ]]; then
	# only in macOS
	# output lsusb-like
	alias lsusb='system_profiler SPUSBDataType'
fi
# (l)ong, (a)ll entries, (h)uman-readable, color (G)
alias la='ls -lahG'
alias grep='grep --color=auto'
# search for all git projects in user home folder and show their statuses
alias ggits='find -L ~ -type d -name .git -print -exec bash -c '\''cd -L $0 && cd .. && git status -s && echo'\'' {} \; -prune'

# ======== Functions ========
# moves file to ~/.Trash (use instead of rm)
trash(){
	if [[ $# -eq 0 ]]; then
		echo "Usage: trash <file> ..."
		return 1
	fi

	for FILE in "$@"; do
		local DATE=$(date +%Y%m%d%H%M%S)
		# if already in trash move it in a new folder with date
		if [[ -f "${HOME}/.Trash/${FILE}" ]]; then
			mkdir "${HOME}/.Trash/${DATE}"
			mv "${FILE}" ${HOME}/.Trash/${DATE}
			echo "${FILE} trashed in ${DATE}/!"
		else
			mv "${FILE}" "${HOME}/.Trash/"
			echo "${FILE} trashed!"
		fi
	done
}

# Make a directory and change to it (mkdir + cd)
mkcd() {
	if [[ $# -ne 1 ]]; then
		echo "Usage: mkcd <dir>"
		return 1
	else
		mkdir -p "$@" && cd "$_"
	fi
}

# Swap two files
swap(){
	if [[ $# -ne 2 ]]; then
		echo "Usage: swap <file1> <file2>"
		return 1
	fi
	local TMPFILE=$(mktemp $(dirname "$1")/XXXXXX)
	mv "$1" "$TMPFILE"
	mv "$2" "$1"
	mv "$TMPFILE" "$2"
}

# Calculate SHA and check if it is equal to a user specified one
chksum(){
	if [[ $# -lt 2 ]]; then
		echo "Usage: chksum [1,224,256,384,512,512224,512256] <file> <sha>"
		echo "Specify number to choose corresponding algorithm (default: 1)"
		return 1
	fi

	if [[ $# -eq 3 ]] && [[ $1 =~ ^(1|224|256|384|512|512224|512256)$ ]] && [[ -f $2 ]]; then
		alg="$1"
		file="$2"
		sha="$3"
	elif [[ $# -eq 2 ]] && [[ -f $1 ]]; then
		alg='1'
		file="$1"
		sha="$2"
	else
		echo "File or SHA algorithm are not valid."
		return 1
	fi

	sum=$(shasum -a "$alg" "$file" | cut -d " " -f 1)
	[[ $sum == $(echo "$sha" | tr '[:upper:]' '[:lower:]') ]]\
		&& echo "sha1 identical" \
		|| echo "WARNING: sha1 NOT identical!"
}


# ======== Prompts ========
# color codes
BOLD=$'\e[1m'
GREEN=$'\e[32m'
RED=$'\e[31m'
BRED=$'\e[1;31m'
BGREEN=$'\e[1;32m'
BORANGE=$'\e[1;33m'
BBLUE=$'\e[1;34m'
NONE=$'\e[m'

# trims long paths down to 30 chars
# Automatically trim long paths in the prompt (requires Bash 4.x)
if [[ "$BASH_VERSION" =~ ^4 ]]; then
	PROMPT_DIRTRIM=2
fi
# manual method if Bash <4.x
_get_path(){
	local x=$(pwd | sed -e "s:$HOME:~:")
	local len=${#x}
	local max=30
	if [[ $len -gt $max ]]; then
		mydir="...${x:((len-max+3))}"
	else
		mydir="${x}"
	fi
}

# prints a colour coded exit status
_get_exit_status(){
	local es=$?
	if [[ $es -eq 0 ]]; then
		exit_status="${GREEN}${es}${NONE}"
	else
		exit_status="${RED}${es}${NONE}"
	fi
}

if [[ $UID -eq 0 ]]; then
	# root user
	USER_COLOR="${BRED}"
else
	# normal user
	USER_COLOR="${BBLUE}"
fi

# can change due to the actual connected machine
# hostname -s
HOST_COLOR="${BBLUE}"

# executed everytime before bash show prompt
PROMPT_COMMAND="_get_exit_status;_get_path;history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
#history -c;history -r"

PS1='[\[${BOLD}\]\t\[${NONE}\]] \
\[${USER_COLOR}\]\u\[${NONE}\]@\[${HOST_COLOR}\]\h:\
\[${BORANGE}\]\[${mydir}\] \
\[${NONE}\][\[${BOLD}\]!\!\[${NONE}\]|\
\[${exit_status}\]]\n\
\[${USER_COLOR}\]\$\[${NONE}\] '

PS2='\[${USER_COLOR}\]>\[${NONE}\] '

PS4='$0:${LINENO}\[${USER_COLOR}\]+\[${NONE}\] '
