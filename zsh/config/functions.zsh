##
# Functions
##

# Fix cursor
function _fix_cursor() {
  echo -ne '\x1b[\x35 q'
}
precmd_functions+=(_fix_cursor)


# Tmux env vars
function _update_environment_from_tmux() {
  eval "$(tmux show-environment -s)"
}

if [ -n "${TMUX}" ]; then
  autoload -zU add-zsh-hook
  add-zsh-hook preexec _update_environment_from_tmux
fi


# Utils
function uuid_gen() {
  if [[ $+commands[fzf] ]]; then
    tr '[:upper:]' '[:lower:]' <<< $(uuidgen)
  else
    python3 -c 'import uuid; print(uuid.uuid4())'
  fi
}


# Tmux
function tmux_new() {
  if [ $# -eq 1 ]; then
    TMUX_ENV="${1}"
  else
    TMUX_ENV="local"
  fi

  tmux -L "${TMUX_ENV}" has-session -t "${TMUX_ENV}" 2>/dev/null \
    && tmux -L "${TMUX_ENV}" attach -t "${TMUX_ENV}" \
    || tmux -L "${TMUX_ENV}" new-session -s "${TMUX_ENV}" -c "${PWD}"
}

function tmux_kill() {
  if [ $# -eq 1 ]; then
    TMUX_ENV="${1}"
  else
    TMUX_ENV="local"
  fi

  tmux -L "${TMUX_ENV}" kill-server
}

# Theme

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
    export FZF_DEFAULT_OPTS=$FZF_OPTS_DARK_MODE

    if [[ "${OSTYPE}" == "darwin"* ]]; then
      _set_macos_dark_mode 1
    fi

    git config --global delta.features catppuccin-frappe

    if [[ "${THEME_MODE}" != "dark" ]]; then
      echo "dark" > ~/.theme_mode
      export THEME_MODE="dark"
    fi
  else
    export FZF_DEFAULT_OPTS=$FZF_OPTS_LIGHT_MODE

    if [[ "${OSTYPE}" == "darwin"* ]]; then
      _set_macos_dark_mode 0
    fi

    git config --global delta.features catppuccin-latte

    if [[ "${THEME_MODE}" != "light" ]]; then
      echo "light" > ~/.theme_mode
      export THEME_MODE="light"
    fi
  fi

  if [ -n "${TMUX}" ]; then
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

# FZF

_fzf_compgen_path() {
    rg --files --glob "!.git" . "$1"
}

_fzf_compgen_dir() {
   fd --type d --hidden --follow --exclude ".git" . "$1"
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'exa -T --icons {}' ;;
    *)            fzf "$@" ;;
  esac
}

function gr() {
  # Search in file (grep), show preview and enter is edit with neovim 
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  INITIAL_QUERY="${*:-}"
  fzf --delimiter=':' \
      --prompt='Ripgrep: ' \
      --wrap \
      --disabled \
      --query "$INITIAL_QUERY" \
      --color='hl:-1:underline,hl+:-1:underline:reverse' \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-label='[ Preview ]' \
      --preview-window=cycle \
      --preview-window '+{2}+3/3,~3' \
      --bind='ctrl-/:change-preview-window(75%||25%|hidden)' \
      --bind "start:reload:$RG_PREFIX {q}" \
      --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
      --bind 'enter:become(nvim {1} +{2})'
}

function fz() {
  # Search for files or directory, show preview (bat or exa) and enter is edit with neovim
  fd --hidden --exclude '.git' --type file |
  fzf --prompt='Files: ' \
      --header='CTRL-T: Switch between Files/Directories | CTRL+C or ESC to exit' \
      --delimiter=':' \
      --wrap \
      --bind='ctrl-t:transform:[[ ! $FZF_PROMPT =~ Files ]] &&
              echo "change-prompt(Files: )+reload(fd --hidden --exclude \".git\" --type file)+transform-preview-label(echo [ File Preview ])" ||
              echo "change-prompt(Directories: )+reload(fd --hidden --exclude \".git\" --type directory)+transform-preview-label(echo [ Directory Stats ])"' \
      --bind='ctrl-/:change-preview-window(75%||25%|hidden)' \
      --preview='[[ $FZF_PROMPT =~ Files ]] && bat --color=always {} || exa -RTFmahlUgu --octal-permissions --git --icons --long -F {}' \
      --preview-label='[ File Preview ]' \
      --bind='enter:become(nvim {1} +{2})'
}

function fztmux() {
  # List tmux sessions with fzf
  tmux list-sessions |
  sed -E 's/:.*$//' |
  grep -v \"^"$(tmux display-message -p '#S')"\$\" |
  fzf --reverse --ghost="Session name" --header="Available Sessions:" --height 10 --border-label=" Switch Tmux Session " |
  xargs tmux switch-client -t
}
