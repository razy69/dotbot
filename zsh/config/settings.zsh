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
export THEME_MODE=$(cat ~/.theme_mode 2>/dev/null || echo "dark")
export FZF_DEFAULT_COMMAND="fd --hidden --exclude '.git'"
export FZF_CTRL_R_OPTS="--prompt='History: ' --height=10% --preview='echo {} | bat --color=always -l zsh -p --decorations never' --preview-window down:3:hidden:wrap --bind 'ctrl-/:toggle-preview'"

FZF_DEFAULT="
--ansi \
--cycle \
--tmux=100% \
--border=rounded \
--layout=reverse \
--prompt='Search: ' \
--header='CTRL-C or ESC to exit' \
--header-border=horizontal \
--separator='' \
--preview-window=border-left \
--info=inline-right \
--bind=ctrl-w:preview-up,ctrl-s:preview-down,ctrl-i:preview-half-page-up,ctrl-k:preview-half-page-down,ctrl-u:preview-top,ctrl-o:preview-bottom"

FZF_COLOR_DARK="
--color=bg+:#414559,bg:#303446,spinner:#F2D5CF,hl:#E78284 \
--color=fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF \
--color=marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284 \
--color=selected-bg:#51576D \
--color=border:#CA9EE6,label:#C6D0F5"

FZF_COLOR_LIGHT="
--color=bg+:#CCD0DA,bg:#EFF1F5,spinner:#DC8A78,hl:#D20F39 \
--color=fg:#4C4F69,header:#D20F39,info:#8839EF,pointer:#DC8A78 \
--color=marker:#7287FD,fg+:#4C4F69,prompt:#8839EF,hl+:#D20F39 \
--color=selected-bg:#BCC0CC \
--color=border:#FF9D00,label:#4C4F69"

FZF_OPTS_DARK_MODE="${FZF_DEFAULT}${FZF_COLOR_DARK}"
FZF_OPTS_LIGHT_MODE="${FZF_DEFAULT}${FZF_COLOR_LIGHT}"

export FZF_DEFAULT_OPTS=$FZF_OPTS_DARK_MODE

# GPG or SSH Agent
if [[ $+commands[gpg-agent] ]]; then
  unset GPG_AGENT_INFO SSH_AGENT_PID SSH_AUTH_SOCK

  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  export GPG_TTY=$(tty)

  if ! pgrep gpg-agent &> /dev/null; then
    gpgconf --launch gpg-agent 2>/dev/null
  fi

  gpg-connect-agent updatestartuptty /bye > /dev/null
else
  eval "$(ssh-agent -s)"
  ssh-add
fi

autoload -U colors && colors
typeset -U path
