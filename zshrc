# Zsh configuration file

# _OS_NAME="$(uname -s)"
# zsh set $OSTYPE, I can check it to know OS

# ======== Options ========
# colored ls output
if [[ "${OSTYPE}" == "darwin"* ]]; then
	# only in macOS
	# (for customization add LSCOLORS var)
	export CLICOLOR=1
	# opt out of Homebrew's analytics
	export HOMEBREW_NO_ANALYTICS=1
elif [[ "${OSTYPE}" == "linux"* ]]; then
	# under Linux
	alias ls='ls --color=auto'
fi

setopt AUTO_CD					# shell will automatically change directory
setopt HIST_EXPIRE_DUPS_FIRST 	# delete dups first if history has to be trimmered
setopt SHARE_HISTORY			# share history across multiple zsh sessions
setopt HIST_IGNORE_DUPS			# do not store duplications in history
setopt HIST_VERIFY				# when using history substitution (!!, !$, etc.) ask for confirmation
#setopt CORRECT					# commands correction
setopt CORRECT_ALL
setopt EXTENDED_GLOB            # enable extended globbing (i.e. ^)

# use the value of ZDOTDIR when it is set or value of HOME otherwise (default).
#HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history

# The following lines were added by compinstall
# enable completion system
# N.B. compinit should come after modifying the fpath in your .zshrc
# N.B.2 On macOS completions are stored in /usr/share/zsh/X.X.X/functions.
# It is in the default fpath but all the files with _ contain the completions.
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle :compinstall filename '/Users/roberto/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# key bindings
bindkey $'^[[A' up-line-or-search    # up arrow
bindkey $'^[[B' down-line-or-search  # down arrow

# change default location for personal mailbox for 'mail' command
export MBOX='~/.mbox'

# For gpg-agent
export GPG_TTY=$(tty)

# For SSH
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# ======== Aliases ========
if [[ "${OSTYPE}" == "darwin"* ]]; then
	# only in macOS
	# output lsusb-like
	alias lsusb='system_profiler SPUSBDataType'
	alias ytdl="cd ~/Downloads/ && youtube-dl -f 'bestaudio[ext=m4a]' -o '%(title)s.%(ext)s'"
	alias polito="cd /Volumes/MacOS-HDD_500GB/Data/Documents/Google\ Drive/Documents/Universita/polito/AA\ 2020-2021"
elif [[ `grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null` ]]; then
	# in Windows WSL
	alias polito="cd /mnt/d/Documents/Google\ Drive/Documents/Universita/polito/AA\ 2020-2021/"
fi
# (l)ong, (a)ll entries, (h)uman-readable, color (G)
alias la='ls -lahG'
alias grep='grep --color=auto'
# search for all git projects in user home folder and show their statuses
alias ggits='find -L ~ -type d -name .git -print -exec bash -c '\''cd -L $0 && cd .. && git status -s && echo'\'' {} \; -prune'

alias -s git='git clone'

# ======== Functions ========
if [[ "${OSTYPE}" == "darwin"* ]]; then
	# only in macOS
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
				mkdir "${HOME}/.Trash/${DATE}" &&\
				mv "${FILE}" ${HOME}/.Trash/${DATE} &&\
				echo "${FILE} trashed in ${DATE}/!"
			else
				mv "${FILE}" "${HOME}/.Trash/" &&\
				echo "${FILE} trashed!"
			fi
		done
	}

	# Check if a password has been disclosed on a 27GB archive
	chkpsw(){
		file="/Volumes/MacOS-HDD_500GB/Data/Downloads/Transmission/pwned-passwords-sha1-ordered-by-hash-v7.txt"
		if [[ $# -ne 1 ]]; then
			echo "Usage: chkpsw <password_to_check>"
			return 1
		fi
		printf "$1" | shasum | tr '[:lower:]' '[:upper:]' | sed 's/\-//g' | xargs -I {} look {} "$file"
	}

	# Open man page in Preview as pdf
	manpdf(){
		man -t "$@" | open -f -a "Preview"
		rm /private/tmp/open_*
	}

	# Open x-man pages
	xman(){
		open x-man-page://"$@"
	}
fi

# Wake-On-LAN a PC with a specified MAC address
wol() {
	if [[ $# -ne 1 ]]; then
		echo "Usage: wol <MAC-address>"
		return 1
	else
		echo -e $(echo $(printf 'f%.0s' {1..12}; printf "$(echo "$@"| sed 's/://g')%.0s" {1..16}) | sed -e 's/../\\x&/g') | socat - UDP-DATAGRAM:255.255.255.255:9,broadcast
	fi
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
	mv "$1" "$TMPFILE" &&\
	mv "$2" "$1" &&\
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

# ======== Prompt ========
# PROMPT1-4 is the same as PS1-4
# PS1 primary prompt : before command is read
# PS2 secondary prompt: printed when shell needs more info for command (default: "%_> ")
# PS3 selection prompt: used within a select loop (default: "?# ")
# PS4 execution prompt: (default: "+")
# %(?.√.?%?)  :  if return code `?` is 0, show `√`, else show `?%?`
# %?          :  exit code of previous command
# %1~         :  current working dir, shortening home to `~`, show the last `1` element
# %#          :  `#` if root, `%` otherwise
# %B %b       :  start/stop bold
# %F{...}     :  colors, see https://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
# %f          :  reset to default color
# %(!.        :  conditional depending on privileged user
# Alternatives to prompt: ❱›
#PROMPT='%(?..%F{red}?%? )%B%F{240}%2~%b%f %(?.%F{green}.%F{red})%(!.#.➜)%f '
#PROMPT='[%B%*%b] %(!.%B%F{red}%n%f%b.%B%F{blue}%n%f%b)@%B%F{blue}%m%f%b:%B%F{yellow}%2~%f%b [%B!%!%b|%(?.%F{green}%?%f.%F{red}%?%f)]
#╰─%B%F{blue}$%f%b '
PROMPT='[%*] %(!.%F{red}%n%f%b.%F{blue}%n%f%b):%F{yellow}%-80(l.%~.%60<...<%~%<<)%f%b
%(?.%F{green}›%f.%F{red}›%f) '
PROMPT2='%_› '
