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
export FZF_DEFAULT_COMMAND="fd --hidden --exclude '.git'"
export FZF_CTRL_R_OPTS="--prompt='History: ' --preview='echo {} | bat --color=always -l zsh -p --decorations never' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_DEFAULT_OPTS=" \
--ansi \
--layout=reverse \
--border=horizontal \
--prompt='Search: ' \
--header='CTRL-C or ESC to exit' \
--info=inline \
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
--color=selected-bg:#51576d \
--color=border:#414559,label:#c6d0f5 \
--bind=ctrl-w:preview-up,ctrl-s:preview-down,ctrl-i:,ctrl-k:"

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
