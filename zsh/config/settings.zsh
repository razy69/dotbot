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
export FZF_CTRL_R_OPTS="--prompt='History: ' --preview='echo {} | bat --color=always -l zsh -p --decorations never' --preview-window down:3:hidden:wrap --bind 'ctrl-/:toggle-preview'"
export FZF_DEFAULT_OPTS=" \
--ansi \
--layout=reverse \
--prompt='Search: ' \
--header='CTRL-C or ESC to exit' \
--info=inline \
--color=bg+:#414559,bg:#303446,spinner:#F2D5CF,hl:#E78284 \
--color=fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF \
--color=marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284 \
--color=selected-bg:#51576D \
--color=border:#737994,label:#C6D0F5 \
--bind=ctrl-w:preview-up,ctrl-s:preview-down,ctrl-i:preview-half-page-up,ctrl-k:preview-half-page-down,ctrl-u:preview-top,ctrl-o:preview-bottom"

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

export THEME_MODE=$(cat ~/.theme_mode 2>/dev/null || echo "dark")

function _set_macos_dark_mode {
  DM=$(osascript -e 'tell app "System Events" to tell appearance preferences to dark mode')

  if [[ $1 == 1 && "${DM}" == "false" ]]; then 
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'
  elif [[ $1 == 0 && "${DM}" == "true" ]]; then
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false'
  fi
}

function set_theme_mode {
  if [[ "${1}" == "dark" ]]; then
    export FZF_DEFAULT_OPTS=" \
    --ansi \
    --layout=reverse \
    --prompt='Search: ' \
    --header='CTRL-C or ESC to exit' \
    --info=inline \
    --color=bg+:#414559,bg:#303446,spinner:#F2D5CF,hl:#E78284 \
    --color=fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF \
    --color=marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284 \
    --color=selected-bg:#51576D \
    --color=border:#737994,label:#C6D0F5 \
    --bind=ctrl-w:preview-up,ctrl-s:preview-down,ctrl-i:preview-half-page-up,ctrl-k:preview-half-page-down,ctrl-u:preview-top,ctrl-o:preview-bottom"

    if [[ "${OSTYPE}" == "darwin"* ]]; then
      _set_macos_dark_mode 1
    fi

    git config --global delta.features catppuccin-frappe

    if [[ "${THEME_MODE}" != "dark" ]]; then
      echo "dark" > ~/.theme_mode
      export THEME_MODE="dark"
    fi
  else
    export FZF_DEFAULT_OPTS=" \
    --ansi \
    --layout=reverse \
    --prompt='Search: ' \
    --header='CTRL-C or ESC to exit' \
    --info=inline \
    --color=bg+:#CCD0DA,bg:#EFF1F5,spinner:#DC8A78,hl:#D20F39 \
    --color=fg:#4C4F69,header:#D20F39,info:#8839EF,pointer:#DC8A78 \
    --color=marker:#7287FD,fg+:#4C4F69,prompt:#8839EF,hl+:#D20F39 \
    --color=selected-bg:#BCC0CC \
    --color=border:#9CA0B0,label:#4C4F69 \
    --bind=ctrl-w:preview-up,ctrl-s:preview-down,ctrl-i:preview-half-page-up,ctrl-k:preview-half-page-down,ctrl-u:preview-top,ctrl-o:preview-bottom"

    if [[ "${OSTYPE}" == "darwin"* ]]; then
      _set_macos_dark_mode 0
    fi

    git config --global delta.features catppuccin-latte

    if [[ "${THEME_MODE}" != "light" ]]; then
      echo "light" > ~/.theme_mode
      export THEME_MODE="light"
    fi
  fi

  if [[ "${TERM_PROGRAM}" == "tmux" ]]; then
    tmux source-file "${HOME}/.tmux.${THEME_MODE}.theme.conf"
  fi
}

function tg {
  if [[ "${THEME_MODE}" == "dark" ]]; then 
    echo "Light Mode 󰛨 "
    set_theme_mode "light"
  else
    echo "Dark Mode 󰌶 "
    set_theme_mode "dark"
  fi
}
