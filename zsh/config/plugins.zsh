##
# Plugins
##

# fzf-tab
(( $+commands[fzf] )) && source "${ZSH}/plugins/fzf-tab/fzf-tab.plugin.zsh"

# Auto Suggestions
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste up-line-or-search down-line-or-search expand-or-complete accept-line push-line-or-edit)
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source "${ZSH}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Fast Syntax Highlighting
source "${ZSH}/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
