##
# Plugins
##

# Auto Suggestions
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source "${ZSH}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ZSH Completions
source "${ZSH}/plugins/zsh-completions/zsh-completions.plugin.zsh"

# Fast Syntax Highlighting
source "${ZSH}/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
