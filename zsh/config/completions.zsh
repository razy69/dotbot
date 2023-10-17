##
# Completions
##

zstyle ':completion:*' rehash true
zstyle ':completion:::::default' menu yes select

zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s

zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

_comp_options+=(globdots)

zmodload zsh/complist

fpath=(
  ${ASDF_DIR}/completions
  ${ZSH}/plugins/zsh-completions/src
  ${ZSH}/completions
  $fpath
)

autoload -Uz compinit && compinit
