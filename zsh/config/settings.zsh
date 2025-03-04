##
# Settings
##

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

unsetopt BEEP
unsetopt MULTIBYTE

export HISTFILE="${ZSH}/.history"
export HISTSIZE=10000
export SAVEHIST=10000
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export EDITOR="nvim"
export MANPATH="/usr/local/man:${MANPATH}"
export TERM="xterm-256color"

# Completion
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors 'di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
autoload -Uz compinit && compinit