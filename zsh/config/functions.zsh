##
# Functions
##

# Fix cursor
function _fix_cursor() {
  echo -ne '\x1b[\x35 q'
}
precmd_functions+=(_fix_cursor)


# Tmux env vars
function update_environment_from_tmux() {
  if [ -n "${TMUX}" ]; then
    eval "$(tmux show-environment -s)"
  fi
}

autoload -zU add-zsh-hook
add-zsh-hook precmd update_environment_from_tmux


# Utils
function uuid_gen() {
  if command -v uuidgen >/dev/null; then
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
      --disabled \
      --query "$INITIAL_QUERY" \
      --color='hl:-1:underline,hl+:-1:underline:reverse' \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-label='[ Preview ]' \
      --preview-window=cycle \
      --preview-window '+{2}+3/3,~3' \
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
      --bind='ctrl-t:transform:[[ ! $FZF_PROMPT =~ Files ]] &&
              echo "change-prompt(Files: )+reload(fd --hidden --exclude \".git\" --type file)+transform-preview-label(echo [ File Preview ])" ||
              echo "change-prompt(Directories: )+reload(fd --hidden --exclude \".git\" --type directory)+transform-preview-label(echo [ Directory Stats ])"' \
      --preview='[[ $FZF_PROMPT =~ Files ]] && bat --color=always {} || exa -ahHilgUmuS --octal-permissions --git --icons --long -F {}' \
      --preview-label='[ File Preview ]' \
      --bind='enter:become(nvim {1} +{2})'
}
