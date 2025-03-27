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

HISTFILE="${ZSH}/.history"
HISTORY_IGNORE="(cd(| *)|ls(| *)|pwd|exit)"
HISTSIZE=10000
SAVEHIST=10000
COMPLETION_WAITING_DOTS="false"

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export EDITOR="nvim"
export MANPATH="/usr/local/man:${MANPATH}"
export BAT_CONFIG_PATH="${HOME}/.config/bat/config"
export K9S_CONFIG_DIR="${HOME}/.config/k9s"

# GPG or SSH Agent
if command -v gpg-agent &> /dev/null; then
  gpg-connect-agent /bye &> /dev/null
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  export GPG_TTY=$(tty)
else
  eval "$(ssh-agent -s)"
  ssh-add
fi

autoload -U colors && colors
typeset -U path
