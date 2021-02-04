if [[ -f ~/.bashrc ]]; then
	source ~/.bashrc
fi

# P A T H
export PATH="/usr/local/opt/ruby/bin:$PATH"

# bash-completion support
if [[ "${OSTYPE}" == "darwin"* ]]; then
	# if under macOS, use homebrew's bash-completion location
	if [[ -f /usr/local/etc/bash_completion ]]; then
		source /usr/local/etc/bash_completion
	fi
elif [[ "${OSTYPE}" == "linux"* ]]; then
	# if under Linux, use standard bash-completion location
	if [[ -f /etc/bash_completion ]]; then
		source /etc/bash_completion
	fi
fi

