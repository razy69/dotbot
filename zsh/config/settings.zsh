##
# Settings
##

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt COMPLETE_IN_WORD
setopt MENU_COMPLETE
setopt NOFLOWCONTROL
setopt NO_LIST_AMBIGUOUS
setopt AUTOCD
setopt INTERACTIVE_COMMENTS

unsetopt BEEP
unsetopt MULTIBYTE

export HISTFILE="${ZSH}/.history"
export HISTSIZE=10000
export SAVEHIST=10000
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export EDITOR="nvim"
export MANPATH="/usr/local/man:${MANPATH}"
export VI_MODE_SET_CURSOR=false
export BAT_THEME="Monokai Extended Origin"
export COMPLETION_WAITING_DOTS="false"

autoload -U colors && colors
typeset -U path
