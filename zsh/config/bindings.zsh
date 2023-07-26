##
# Keymap
##

source "${ZSH}/keymaps/${TERM}-${${DISPLAY:t}:-${VENDOR}-${OSTYPE}}"


##
# Keybindings
##

bindkey -e
bindkey '^u' backward-kill-line

# [Home] - Start of line
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line

# [End] - End of line
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line

# [Delete] - Delete char
[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char

# [Up] - Previous command
[[ -n ${key[Up]} ]] && bindkey "${key[Up]}" up-line-or-local-history
up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history

# [Down] - Next command
[[ -n ${key[Down]} ]] && bindkey "${key[Down]}" down-line-or-local-history
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history

# [Ctrl-X, Ctrl-E] - Edit the current command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# [Ctrl-R] - History inc search
bindkey '^r' history-incremental-search-backward
bindkey '^f' history-incremental-search-forward

# [Ctrl-W] - Delete a full WORD (excluding: dot, comma, colon, underscore, dash, slash)
bindkey '^w' my-backward-kill-word
my-backward-kill-word () {
  local WORDCHARS='*?[]~=&;!#$%^(){}<>"'"'"
  zle -f kill # Append to the kill ring on subsequent kills.
  zle backward-kill-word
}
zle -N my-backward-kill-word
