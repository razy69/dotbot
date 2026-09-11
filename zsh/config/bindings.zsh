##
# Keymap
##

zmodload zsh/terminfo 2>/dev/null


##
# Keybindings
##

bindkey -e
bindkey '^u' backward-kill-line

# [Home] - Start of line (terminfo + xterm variants)
for seq in "${terminfo[khome]:-}" '^[OH' '^[[H'; do
  [[ -n "${seq}" ]] && bindkey "${seq}" beginning-of-line
done

# [End] - End of line
for seq in "${terminfo[kend]:-}" '^[OF' '^[[F'; do
  [[ -n "${seq}" ]] && bindkey "${seq}" end-of-line
done

# [Delete] - Delete char
for seq in "${terminfo[kdch1]:-}" '^[[3~'; do
  [[ -n "${seq}" ]] && bindkey "${seq}" delete-char
done

# [Up] - Previous command
up-line-or-local-history() {
  zle set-local-history 1
  zle up-line-or-history
  zle set-local-history 0
}
zle -N up-line-or-local-history
for seq in "${terminfo[kcuu1]:-}" '^[OA' '^[[A'; do
  [[ -n "${seq}" ]] && bindkey "${seq}" up-line-or-local-history
done

# [Down] - Next command
down-line-or-local-history() {
  zle set-local-history 1
  zle down-line-or-history
  zle set-local-history 0
}
zle -N down-line-or-local-history
for seq in "${terminfo[kcud1]:-}" '^[OB' '^[[B'; do
  [[ -n "${seq}" ]] && bindkey "${seq}" down-line-or-local-history
done

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
