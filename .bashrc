. /home/antsva/.local/bin/functions.sh

# alias ssh="kitty +kitten ssh"
alias dots='git --git-dir=$HOME/.dots/ --work-tree=$HOME'
alias fd='fd --hidden'
alias ncdu='ncdu --color dark'

dots-sync() {
	commit_msg=$(date +"%Y%m%d-%H%M%S")
	dots commit -a -m "$commit_msg"
	dots push
}

# Suggest package when entering an unrecognized command
if [[ $(type pkgfile) ]]; then
	source /usr/share/doc/pkgfile/command-not-found.bash
fi

# if [[ $(which fzf) ]]; then
#	source /usr/share/fzf/key-bindings.bash
#	source /usr/share/fzf/completion.bash
# fi

# Disable ctrl+s and ctrl+q
stty -ixon

# Ignore duplicates in history
export HISTCONTROL=ignoreboth

# Store more  history
export HISTFILESIZE=500000
export HISTSIZE=100000

# Append rather than overwrite history on shell exit
shopt -s histappend

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}	# sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}	  ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh
