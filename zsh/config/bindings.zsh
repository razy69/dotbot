##
# Keymap
##

source "${ZSH}/keymaps/${TERM}-${${DISPLAY:t}:-${VENDOR}-${OSTYPE}}"


##
# Keybindings
##

bindkey -e
bindkey \^u backward-kill-line

# # [Home] - Start of line
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line

# # [End] - End of line
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line

# [Ctrl-X, Ctrl-E] - Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# [Esc-W] - Kill from the cursor to the mark
bindkey '\ew' kill-region