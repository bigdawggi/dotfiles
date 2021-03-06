# Set VI to be the editor of choice
export EDITOR=vi
GREEN="\[\e[0;32m\]"
BLUE="\[\e[0;34m\]"
RED="\[\e[0;31m\]"
YELLOW="\[\e[0;33m\]"
COLOREND="\[\e[00m\]"

alias gs='git status'
alias gd='git diff'

# PATH config
export PATH=/usr/local/php5/bin:/usr/local/share/npm/bin:~/Library/bin:/usr/local/sbin:/usr/local/bin:$PATH;
export PATH=~/.composer/vendor/bin:$PATH;

# Cool Aliases
alias biggest='du -sm * | sort -nr | head -15';
alias flushdns='sudo dscacheutil -flushcache && say "Your DNS has been flushed."';
alias l='ls -lah';
alias elog='tail -f /var/log/apache2/error_log';
alias desk='cd ~/Desktop';
alias web='cd ~/web/';
alias url="open -a /Applications/Google\ Chrome.app http://$1";
alias ..='cd ../';
alias ..2='cd ../../';
alias ..3='cd ../../../';
alias locate-submodule='git submodule | grep $1';
alias git-toplevel='cd `git rev-parse --show-toplevel`';

# Add SSH Keys
ssh-add ~/.ssh/id_rsa

# Bash Completion-ness for command and hostname completion
# See http://superuser.com/a/288491/384228
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi
if [[ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]]; then
    PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
fi

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" 




# Responsive Prompt
parse_git_branch() {
	if [[ -f "$BASH_COMPLETION_DIR/git-completion.bash" ]]; then
		branch=`__git_ps1 "%s"`
	else
		ref=$(git-symbolic-ref HEAD 2> /dev/null) || return
		branch="${ref#refs/heads/}"
	fi

	if [[ `tput cols` -lt 110 ]]; then
		branch=`echo $branch | sed s/feature/f/1`
		branch=`echo $branch | sed s/hotfix/h/1`
		branch=`echo $branch | sed s/release/\r/1`

		branch=`echo $branch | sed s/master/mstr/1`
		branch=`echo $branch | sed s/develop/dev/1`
	fi

	if [[ $branch != "" ]]; then
		if [[ $(git status 2> /dev/null | tail -n1) == "nothing to commit, working directory clean" ]]; then
			echo "${GREEN}$branch${COLOREND} "
		else
			echo "${RED}$branch${COLROEND} "
		fi
	fi
}

working_directory() {
	dir=`pwd`
	in_home=0
	if [[ `pwd` =~ ^"$HOME"(/|$) ]]; then
		dir="~${dir#$HOME}"
		in_home=1
	fi

	workingdir=""
	if [[ `tput cols` -lt 110 ]]; then
		first="/`echo $dir | cut -d / -f 2`"
		letter=${first:0:2}
		if [[ $in_home == 1 ]]; then
			letter="~$letter"
		fi
		proj=`echo $dir | cut -d / -f 3`
		beginning="$letter/$proj"
		end=`echo "$dir" | rev | cut -d / -f1 | rev`

		if [[ $proj == "" ]]; then
			workingdir="$dir"
		elif [[ $proj == "~" ]]; then
			workingdir="$dir"
		elif [[ $dir =~ "$first/$proj"$ ]]; then
			workingdir="$beginning"
		elif [[ $dir =~ "$first/$proj/$end"$ ]]; then
			workingdir="$beginning/$end"
		else
			workingdir="$beginning/…/$end"
		fi
	else
		workingdir="$dir"
	fi

	echo -e "${YELLOW}$workingdir${COLOREND} "
}

parse_remote_state() {
	remote_state=$(git status -sb 2> /dev/null | grep -oh "\[.*\]")
	if [[ "$remote_state" != "" ]]; then
		out="${BLUE}[${COLOREND}"

		if [[ "$remote_state" == *ahead* ]] && [[ "$remote_state" == *behind* ]]; then
			behind_num=$(echo "$remote_state" | grep -oh "behind \d*" | grep -oh "\d*$")
			ahead_num=$(echo "$remote_state" | grep -oh "ahead \d*" | grep -oh "\d*$")
			out="$out${RED}$behind_num${COLOREND},${GREEN}$ahead_num${COLOREND}"
		elif [[ "$remote_state" == *ahead* ]]; then
			ahead_num=$(echo "$remote_state" | grep -oh "ahead \d*" | grep -oh "\d*$")
			out="$out${GREEN}$ahead_num${COLOREND}"
		elif [[ "$remote_state" == *behind* ]]; then
			behind_num=$(echo "$remote_state" | grep -oh "behind \d*" | grep -oh "\d*$")
			out="$out${RED}$behind_num${COLOREND}"
		fi

		out="$out${BLUE}]${COLOREND}"
		echo "$out "
	fi
}

prompt() {
	if [[ $? -eq 0 ]]; then
		exit_status="${BLUE}›${COLOREND} "
	else
		exit_status="${RED}›${COLOREND} "
	fi

	PS1="$(working_directory)$(parse_git_branch)$(parse_remote_state)$exit_status"
}

PROMPT_COMMAND=prompt
